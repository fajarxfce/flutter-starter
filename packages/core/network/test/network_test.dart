import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

void main() {
  for (final entry in {
    400: FailureKind.validation,
    401: FailureKind.unauthorized,
    403: FailureKind.forbidden,
    404: FailureKind.notFound,
    408: FailureKind.timeout,
    409: FailureKind.conflict,
    422: FailureKind.validation,
    429: FailureKind.rateLimited,
    500: FailureKind.server,
    503: FailureKind.server,
  }.entries) {
    test(
      'HTTP ${entry.key} maps to ${entry.value.name} without server details',
      () {
        final options = RequestOptions(path: '/private?token=secret');
        final failure = mapNetworkFailure(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            message: 'private exception',
            response: Response<Object>(
              requestOptions: options,
              statusCode: entry.key,
              data: 'private response',
            ),
          ),
        );
        expect(failure.kind, entry.value);
        expect(failure.message, isNot(contains('private')));
        expect(failure.message, isNot(contains('secret')));
      },
    );
  }

  test('transport failure kinds remain distinct', () {
    final options = RequestOptions(path: '/me');
    for (final entry in {
      DioExceptionType.connectionTimeout: FailureKind.timeout,
      DioExceptionType.sendTimeout: FailureKind.timeout,
      DioExceptionType.receiveTimeout: FailureKind.timeout,
      DioExceptionType.connectionError: FailureKind.network,
      DioExceptionType.badCertificate: FailureKind.network,
      DioExceptionType.cancel: FailureKind.cancelled,
    }.entries) {
      expect(
        mapNetworkFailure(
          DioException(requestOptions: options, type: entry.key),
        ).kind,
        entry.value,
      );
    }
    expect(
      mapNetworkFailure(TimeoutException('private')).kind,
      FailureKind.timeout,
    );
  });

  test(
    'decoding and mapping exceptions are caught by the API boundary',
    () async {
      final call = SafeApiCall(
        const NetworkConfig(baseUrl: 'https://example.invalid'),
      );
      final checked = CheckedFromJsonException(
        {'secret': 'private'},
        'id',
        'User',
        'bad value',
      );
      for (final operation in <String Function()>[
        () => throw const FormatException('private JSON'),
        () => throw checked,
        () {
          final Object value = 42;
          return value as String;
        },
        () => throw DioException(
          requestOptions: RequestOptions(path: '/me'),
          error: checked,
        ),
      ]) {
        final result = await call((_) => operation());
        final failure = (result as FailureResult<String>).failure;
        expect(failure.kind, FailureKind.invalidResponse);
        expect(failure.message, isNot(contains('private')));
      }
    },
  );

  test('local infrastructure failures retain their original kind', () {
    const failure = Failure(FailureKind.storage, 'Storage unavailable');
    final error = DioException(
      requestOptions: RequestOptions(path: '/me'),
      error: failure,
    );
    expect(mapNetworkFailure(error), same(failure));
    expect(
      mapNetworkFailure(StateError('private bug')).kind,
      FailureKind.unexpected,
    );
  });

  test('classifies timeout, authorization and server failures', () {
    final request = RequestOptions(path: '/me');
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        ),
      ).kind,
      FailureKind.timeout,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          response: Response<Object>(requestOptions: request, statusCode: 401),
        ),
      ).kind,
      FailureKind.unauthorized,
    );
    expect(
      mapNetworkFailure(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<Object>(requestOptions: request, statusCode: 503),
        ),
      ).kind,
      FailureKind.server,
    );
  });
}
