import 'package:core_common/core_common.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:injectable/injectable.dart';

@module
abstract class EnvironmentModule {
  @lazySingleton
  AppEnvironment environment(AppConfig config) =>
      AppEnvironment(label: config.label, isDemo: config.isDemo);
}
