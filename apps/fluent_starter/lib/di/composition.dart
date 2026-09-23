import 'package:core_common/core_common.dart';
import 'package:core_data/core_data.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/composition.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(ignoreUnregisteredTypes: [AppConfig, CredentialStore])
GetIt initializeDependencies(GetIt container) => container.init();

GetIt configureDependencies(
  AppConfig config, {
  CredentialStore? credentials,
  PreferenceStore? preferences,
}) {
  final container = GetIt.asNewInstance();
  container.registerSingleton(config);
  container.registerSingleton<CredentialStore>(
    credentials ?? createCredentialStore(config.storageNamespace),
  );
  container.registerSingleton<PreferenceStore>(
    preferences ?? LocalPreferenceStore.create(config.storageNamespace),
  );
  return initializeDependencies(container);
}
