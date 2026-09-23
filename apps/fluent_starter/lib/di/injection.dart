import 'package:auth_data/auth_data.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_common/core_common.dart';
import 'package:core_data/core_data.dart';
import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/injection.config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_presentation/settings_presentation.dart';

@InjectableInit(
  ignoreUnregisteredTypes: [AppConfig, CredentialStore, PreferenceStore, GetIt],
  externalPackageModulesBefore: [
    ExternalModule(CoreNetworkPackageModule),
    ExternalModule(AuthDataPackageModule),
    ExternalModule(AuthPresentationPackageModule),
    ExternalModule(SettingsDataPackageModule),
    ExternalModule(SettingsPresentationPackageModule),
  ],
  throwOnMissingDependencies: true,
)
Future<GetIt> initializeDependencies(GetIt container) => container.init();

Future<GetIt> configureDependencies(
  AppConfig config, {
  CredentialStore? credentials,
  PreferenceStore? preferences,
}) async {
  final container = GetIt.asNewInstance();
  // Runtime configuration and platform stores are the composition boundary.
  // All network, data, domain, presentation and routing services are generated.
  container.registerSingleton(config);
  container.registerSingleton<GetIt>(container);
  container.registerSingleton<CredentialStore>(
    credentials ?? createCredentialStore(config.storageNamespace),
  );
  container.registerSingleton<PreferenceStore>(
    preferences ?? LocalPreferenceStore.create(config.storageNamespace),
  );
  await initializeDependencies(container);
  final session = container<SessionBloc>();
  final appearance = container<AppearanceBloc>();
  final ready = Future.wait([
    session.stream.firstWhere((state) => state.initialized),
    appearance.stream.firstWhere((state) => state.initialized),
  ]);
  session.add(const SessionStarted());
  appearance.add(const AppearanceStarted());
  await ready;
  return container;
}

/// Runtime and platform dependencies shared by the feature modules.
@module
abstract class AppModule {
  @lazySingleton
  AppEnvironment environment(AppConfig config) =>
      AppEnvironment(label: config.label, isDemo: config.isDemo);

  @lazySingleton
  NetworkConfig networkConfig(AppConfig config) => NetworkConfig(
    baseUrl: config.baseUrl,
    log: kDebugMode ? debugPrint : null,
  );

  @lazySingleton
  HttpClientAdapter httpClientAdapter(AppConfig config) =>
      config.isDemo ? DemoAdapter() : HttpClientAdapter();
}
