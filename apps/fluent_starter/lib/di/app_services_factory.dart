import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/app_services.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/composition.dart';
import 'package:fluent_starter/routing/app_router.dart';

Future<AppServices> createAppServices(
  AppConfig config, {
  CredentialStore? credentials,
  PreferenceStore? preferences,
}) async {
  final container = await configureDependencies(
    config,
    credentials: credentials,
    preferences: preferences,
  );
  final services = AppServices(
    config: config,
    repository: container<AuthRepository>(),
    login: container<Login>(),
    restore: container<RestoreSession>(),
    logout: container<Logout>(),
    preferences: container<PreferenceStore>(),
    createLoginBloc: () => container<LoginBloc>(),
    createRouter: () => container<AppRouter>(),
    dio: container<Dio>(),
    dispose: () async {
      await container.reset();
    },
  );
  await services.prepare();
  return services;
}
