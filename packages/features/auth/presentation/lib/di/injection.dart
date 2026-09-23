import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    GetIt,
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
