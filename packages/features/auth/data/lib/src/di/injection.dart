import 'package:auth_data/src/repositories/remote_auth_repository.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Dio, CredentialStore, SafeApiCall],
  throwOnMissingDependencies: true,
)
void configureAuthDataPackage() {}

/// Auth owns its use-case bindings while domain stays free of DI annotations.
@module
abstract class AuthModule {
  @injectable
  Login login(AuthRepository repository) => Login(repository);

  @injectable
  RestoreSession restoreSession(AuthRepository repository) =>
      RestoreSession(repository);

  @injectable
  Logout logout(AuthRepository repository) => Logout(repository);

  @injectable
  WatchSession watchSession(AuthRepository repository) =>
      WatchSession(repository);

  @injectable
  ExpireDemoSession expireDemoSession(DemoSessionRepository repository) =>
      ExpireDemoSession(repository);
}

// Injectable registers the domain interface. Lifecycle stays in the data layer.
Future<void> disposeAuthRepository(AuthRepository repository) =>
    (repository as RemoteAuthRepository).dispose();
