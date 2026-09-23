import 'package:auth_domain/auth_domain.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Login],
  throwOnMissingDependencies: true,
)
void configureAuthPresentationPackage() {}
