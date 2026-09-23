import 'package:core_common/core_common.dart';
import 'package:core_network/src/config/network_config.dart';
import 'package:core_network/src/interceptors/credential_interceptor.dart';
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [NetworkConfig, CredentialStore, HttpClientAdapter],
  throwOnMissingDependencies: true,
)
void configureNetworkPackage() {}

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

void disposeDio(Dio dio) => dio.close(force: true);
