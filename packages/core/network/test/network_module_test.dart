import 'dart:typed_data';

import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:core_testing/core_testing.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' show GetItHelper;
import 'package:test/test.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  bool closed = false;
  bool forceClosed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {
    closed = true;
    forceClosed = force;
  }
}

void main() {
  late GetIt container;
  late _RecordingAdapter adapter;
  late List<String> logs;

  setUp(() async {
    container = GetIt.asNewInstance();
    adapter = _RecordingAdapter();
    logs = [];
    container.registerSingleton(
      NetworkConfig(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 4),
        log: logs.add,
      ),
    );
    container.registerSingleton<CredentialStore>(
      FakeCredentialStore()..token = 'private-token',
    );
    container.registerSingleton<HttpClientAdapter>(adapter);
    await CoreNetworkPackageModule().init(GetItHelper(container));
  });
  tearDown(() => container.reset());

  test('generated providers share the configured client and transport', () {
    final dio = container<Dio>();
    expect(container<Dio>(), same(dio));
    expect(container<SafeApiCall>(), same(container<SafeApiCall>()));
    expect(dio.httpClientAdapter, same(adapter));
    expect(dio.options, same(container<BaseOptions>()));
    expect(dio.options.baseUrl, 'https://api.example.com');
    expect(dio.options.connectTimeout, const Duration(seconds: 2));
    expect(dio.options.receiveTimeout, const Duration(seconds: 3));
    expect(dio.options.sendTimeout, const Duration(seconds: 4));
    expect(dio.options.contentType, Headers.jsonContentType);
  });

  test('credentials are attached only to authenticated API requests', () async {
    final dio = container<Dio>();
    await dio.get<Object>('/auth/me');
    await dio.post<Object>('/auth/login');
    await dio.post<Object>('https://api.example.com/auth/login?source=test');
    await dio.get<Object>('https://other.example.com/auth/me');
    await dio.get<Object>('https://api.example.com:8443/auth/me');
    expect(
      adapter.requests.first.headers['Authorization'],
      'Bearer private-token',
    );
    for (final request in adapter.requests.skip(1)) {
      expect(request.headers, isNot(contains('Authorization')));
    }
  });

  test('success and error logs omit request and credential details', () async {
    final dio = container<Dio>();
    await dio.post<Object>(
      '/auth/login?email=private@example.com',
      data: {'password': 'private-password'},
    );
    adapter.status = 401;
    await expectLater(
      dio.get<Object>('/auth/me'),
      throwsA(isA<DioException>()),
    );
    expect(logs, [
      'HTTP POST',
      'HTTP 200',
      'HTTP GET',
      'HTTP failure badResponse 401',
    ]);
  });

  test(
    'reset runs the generated Dio disposer and closes its transport',
    () async {
      container<Dio>();
      expect(adapter.closed, isFalse);
      await container.reset();
      expect(adapter.closed, isTrue);
      expect(adapter.forceClosed, isTrue);
    },
  );
}
