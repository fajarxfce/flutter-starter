import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/app_services.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/composition.dart';
import 'package:fluent_ui/fluent_ui.dart';

Future<AppServices> createAppServices(
  AppConfig config, {
  CredentialStore? credentials,
  PreferenceStore? preferences,
}) async {
  final container = configureDependencies(
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
    dio: container<Dio>(),
    dispose: () async {
      container<Dio>().close(force: true);
      await container.reset();
    },
  );
  await services.prepare();
  return services;
}

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await createAppServices(config);
  runApp(FluentStarterApp(services: services));
}
