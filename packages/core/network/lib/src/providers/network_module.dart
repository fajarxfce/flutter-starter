import 'package:core_network/src/config/network_config.dart';
import 'package:core_network/src/interceptors/credential_interceptor.dart';
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart';
import 'package:core_network/src/providers/dio_disposer.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  BaseOptions options(NetworkConfig config) => BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    sendTimeout: config.sendTimeout,
    contentType: Headers.jsonContentType,
  );

  @LazySingleton(dispose: disposeDio)
  Dio dio(
    BaseOptions options,
    HttpClientAdapter adapter,
    CredentialInterceptor credentials,
    SafeLoggingInterceptor logging,
  ) => Dio(options)
    ..httpClientAdapter = adapter
    ..interceptors.addAll([credentials, logging]);
}
