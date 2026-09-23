import 'package:auth_data/src/repositories/remote_auth_repository.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [Dio, CredentialStore],
  throwOnMissingDependencies: true,
)
void configureAuthDataPackage() {}

// Injectable registers the domain interface. Lifecycle stays in the data layer.
Future<void> disposeAuthRepository(AuthRepository repository) =>
    (repository as RemoteAuthRepository).dispose();
