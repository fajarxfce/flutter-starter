import 'dart:async';
import 'dart:typed_data';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

DioException _httpError({
  String method = 'GET',
  int status = 503,
  String? retryAfter,
}) {
  final options = RequestOptions(
    path: '/resource?secret=private',
    method: method,
  );
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    message: 'private server details',
    response: Response<Object>(
      requestOptions: options,
      statusCode: status,
      data: {'secret': 'private response'},
      headers: Headers.fromMap({
        if (retryAfter != null) 'retry-after': [retryAfter],
      }),
    ),
  );
}

class _PendingAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  final response = Completer<ResponseBody>();
  final cancelled = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    started.complete();
    unawaited(cancelFuture?.then((_) => cancelled.complete()));
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late SafeApiCall safeApiCall;
  setUp(
    () => safeApiCall = SafeApiCall(
      const NetworkConfig(baseUrl: 'https://example.invalid'),
    ),
  );
  final retry = ApiRetryPolicy.readOnly(
    initialDelay: Duration.zero,
    maxDelay: Duration.zero,
  );

  test(
    'supports ordinary callbacks with sync, async, nullable and void results',
    () async {
      final result = await safeApiCall(() => 42);
      expect((result as Success<int>).value, 42);
      expect(
        (await safeApiCall(() async => 'value') as Success<String>).value,
        'value',
      );
      expect(
        (await safeApiCall<String?>(() => null) as Success<String?>).value,
        isNull,
      );
      expect(await safeApiCall<void>(() async {}), isA<Success<void>>());
    },
  );

  test('never retries unless explicitly enabled', () async {
    var attempts = 0;
    final result = await safeApiCall<void>(() {
      attempts++;
      throw _httpError();
    });
    expect(attempts, 1);
    expect((result as FailureResult<void>).failure.kind, FailureKind.server);
  });

  test('authentication, validation, cancellation, certificate and decoding errors are never retried', () async {
    final options = RequestOptions(path: '/me');
    for (final error in <Object>[
      _httpError(status: 401),
      _httpError(status: 403),
      _httpError(status: 422),
      const FormatException('bad JSON'),
      DioException(requestOptions: options, type: DioExceptionType.cancel),
      DioException(
        requestOptions: options,
        type: DioExceptionType.transformTimeout,
      ),
      DioException(
        requestOptions: options,
        type: DioExceptionType.badCertificate,
      ),
    ]) {
      var attempts = 0;
      expect(
        await safeApiCall<void>(() {
          attempts++;
          throw error;
        }, retry: retry),
        isA<FailureResult<void>>(),
      );
      expect(attempts, 1);
    }
  });

  test('transient read connection failures can recover', () async {
    var attempts = 0;
    final result = await safeApiCall(() {
      attempts++;
      if (attempts == 1) {
        throw DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.connectionError,
        );
      }
      return 'ready';
    }, retry: retry);
    expect((result as Success<String>).value, 'ready');
    expect(attempts, 2);
  });

  for (final method in ['GET', 'HEAD', 'OPTIONS']) {
    test(
      'retries transient $method reads up to the configured limit',
      () async {
        var attempts = 0;
        final result = await safeApiCall(() {
          attempts++;
          if (attempts < 3) throw _httpError(method: method);
          return 'ready';
        }, retry: retry);
        expect((result as Success<String>).value, 'ready');
        expect(attempts, 3);
      },
    );
  }

  for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
    test(
      'does not replay $method even when read retries are enabled',
      () async {
        var attempts = 0;
        await safeApiCall<void>(() {
          attempts++;
          throw _httpError(method: method);
        }, retry: retry);
        expect(attempts, 1);
      },
    );
  }

  test(
    'retry exhaustion reports the final failure once with its original stack',
    () async {
      var attempts = 0;
      final reported = <Failure>[];
      final traces = <StackTrace>[];
      final stack = StackTrace.fromString('original stack');
      final call = SafeApiCall(
        NetworkConfig(
          baseUrl: 'https://example.invalid',
          onFailure: (failure, trace) {
            reported.add(failure);
            traces.add(trace);
          },
        ),
      );
      final result = await call<void>(() {
        attempts++;
        Error.throwWithStackTrace(_httpError(), stack);
      }, retry: retry);
      expect(attempts, 3);
      expect(reported, hasLength(1));
      expect(traces.single.toString(), stack.toString());
      expect(reported.single, same((result as FailureResult<void>).failure));
      expect(reported.single.message, isNot(contains('private')));
    },
  );

  test(
    'reporter errors do not escape or replace the request failure',
    () async {
      final call = SafeApiCall(
        NetworkConfig(
          baseUrl: 'https://example.invalid',
          onFailure: (_, _) => throw StateError('reporter failed'),
        ),
      );
      final result = await call<void>(
        () => throw TimeoutException('private request'),
      );
      expect((result as FailureResult<void>).failure.kind, FailureKind.timeout);
    },
  );

  test('pre-cancelled calls never execute the operation', () async {
    final token = CancelToken()..cancel('private reason');
    var called = false;
    final result = await safeApiCall(() {
      called = true;
      return 42;
    }, cancelToken: token);
    expect(called, isFalse);
    expect((result as FailureResult<int>).failure.kind, FailureKind.cancelled);
  });

  test(
    'cancellation wins when an operation finishes in the same turn',
    () async {
      final token = CancelToken();
      final result = await safeApiCall(() {
        token.cancel();
        return 42;
      }, cancelToken: token);
      expect(
        (result as FailureResult<int>).failure.kind,
        FailureKind.cancelled,
      );
    },
  );

  test(
    'cancellation reaches Dio and late adapter errors are observed',
    () async {
      final adapter = _PendingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      final token = CancelToken();
      final pending = safeApiCall(
        () => dio.get<Object>('/pending', cancelToken: token),
        cancelToken: token,
      );
      await adapter.started.future;
      token.cancel();
      final result = await pending.timeout(const Duration(seconds: 1));
      await adapter.cancelled.future;
      expect(
        (result as FailureResult<Response<Object>>).failure.kind,
        FailureKind.cancelled,
      );
      adapter.response.completeError(StateError('late adapter error'));
      await Future<void>.delayed(Duration.zero);
    },
  );

  test(
    'cancelling during backoff stops promptly without another attempt',
    () async {
      final token = CancelToken();
      final started = Completer<void>();
      var attempts = 0;
      final pending = safeApiCall<void>(
        () {
          attempts++;
          started.complete();
          throw _httpError();
        },
        cancelToken: token,
        retry: ApiRetryPolicy.readOnly(
          initialDelay: const Duration(seconds: 10),
          maxDelay: const Duration(seconds: 10),
        ),
      );
      await started.future;
      await Future<void>.delayed(Duration.zero);
      token.cancel();
      final result = await pending.timeout(const Duration(seconds: 1));
      expect(
        (result as FailureResult<void>).failure.kind,
        FailureKind.cancelled,
      );
      expect(attempts, 1);
    },
  );

  test('backoff is exponential with bounded jitter', () {
    final policy = ApiRetryPolicy.readOnly(
      maxAttempts: 5,
      initialDelay: const Duration(milliseconds: 100),
      maxDelay: const Duration(milliseconds: 250),
    );
    expect(
      policy.delayAfter(_httpError(), 1)!.inMicroseconds,
      inInclusiveRange(50000, 100000),
    );
    expect(
      policy.delayAfter(_httpError(), 2)!.inMicroseconds,
      inInclusiveRange(100000, 200000),
    );
    expect(
      policy.delayAfter(_httpError(), 3)!.inMicroseconds,
      inInclusiveRange(125000, 250000),
    );
    expect(policy.delayAfter(_httpError(), 5), isNull);
  });

  test(
    'Retry-After seconds and HTTP dates are respected within the budget',
    () {
      final policy = ApiRetryPolicy.readOnly(
        initialDelay: Duration.zero,
        maxDelay: const Duration(seconds: 10),
      );
      expect(
        policy.delayAfter(_httpError(status: 429, retryAfter: '2'), 1),
        const Duration(seconds: 2),
      );
      final date = formatHttpDate(
        DateTime.now().toUtc().add(const Duration(seconds: 5)),
      );
      expect(
        policy.delayAfter(_httpError(retryAfter: date), 1)!.inMilliseconds,
        inInclusiveRange(3000, 5000),
      );
      expect(
        policy.delayAfter(_httpError(retryAfter: 'not a date'), 1),
        Duration.zero,
      );
      expect(
        policy.delayAfter(
          _httpError(retryAfter: '9999999999999999999999999'),
          1,
        ),
        isNull,
      );
    },
  );

  test('a server delay beyond the budget surfaces the failure without retrying early', () async {
    var attempts = 0;
    final result = await safeApiCall<void>(() {
      attempts++;
      throw _httpError(status: 429, retryAfter: '60');
    }, retry: retry);
    expect(attempts, 1);
    expect(
      (result as FailureResult<void>).failure.kind,
      FailureKind.rateLimited,
    );
  });

  test('invalid retry limits fail before any request starts', () {
    expect(() => ApiRetryPolicy.readOnly(maxAttempts: 0), throwsArgumentError);
    expect(() => ApiRetryPolicy.readOnly(maxAttempts: 11), throwsArgumentError);
    expect(
      () => ApiRetryPolicy.readOnly(initialDelay: const Duration(seconds: -1)),
      throwsArgumentError,
    );
    expect(
      () => ApiRetryPolicy.readOnly(maxDelay: const Duration(seconds: 61)),
      throwsArgumentError,
    );
  });
}
