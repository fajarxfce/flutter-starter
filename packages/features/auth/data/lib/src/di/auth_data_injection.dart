import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Dio, CredentialStore],
  throwOnMissingDependencies: true,
)
void configureAuthDataPackage() {}
