import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Dio, CredentialStore],
  throwOnMissingDependencies: true,
)
void configureIdentityDataPackage() {}

/// Identity owns its use-case bindings while domain stays free of DI annotations.
@module
abstract class IdentityModule {
  @injectable
  Login login(IdentityRepository repository) => Login(repository);

  @injectable
  RestoreSession restoreSession(IdentityRepository repository) =>
      RestoreSession(repository);

  @injectable
  Logout logout(IdentityRepository repository) => Logout(repository);

  @injectable
  WatchSession watchSession(IdentityRepository repository) =>
      WatchSession(repository);

  @injectable
  GetCurrentSession getCurrentSession(IdentityRepository repository) =>
      GetCurrentSession(repository);

  @injectable
  ExpireDemoSession expireDemoSession(DemoSessionRepository repository) =>
      ExpireDemoSession(repository);
}
