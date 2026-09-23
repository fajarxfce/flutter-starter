import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/auth_repository_disposer.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CompositionModule {
  @lazySingleton
  Dio dio(AppConfig config, CredentialStore credentials) {
    final dio = createDio(
      baseUrl: config.baseUrl,
      credentials: credentials,
      log: kDebugMode ? debugPrint : null,
    );
    if (config.isDemo) dio.httpClientAdapter = DemoAdapter();
    return dio;
  }

  @lazySingleton
  AuthApi api(Dio dio) => AuthApi(dio);
  @LazySingleton(dispose: disposeRepository)
  AuthRepository repository(AuthApi api, CredentialStore credentials) =>
      RemoteAuthRepository(api, credentials);
  @injectable
  Login login(AuthRepository repository) => Login(repository);
  @injectable
  RestoreSession restore(AuthRepository repository) =>
      RestoreSession(repository);
  @injectable
  Logout logout(AuthRepository repository) => Logout(repository);
}
