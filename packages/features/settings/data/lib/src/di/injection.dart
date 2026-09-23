import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [PreferenceStore],
  throwOnMissingDependencies: true,
)
void configureSettingsDataPackage() {}
