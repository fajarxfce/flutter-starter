import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    Login,
    RestoreSession,
    Logout,
    WatchSession,
    ExpireDemoSession,
    AppEnvironment,
  ],
  throwOnMissingDependencies: true,
)
void configureAuthPresentationPackage() {}
