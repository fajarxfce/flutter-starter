// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_common/core_common.dart' as _i699;
import 'package:injectable/injectable.dart' as _i526;
import 'package:settings_data/src/repositories/local_settings_repository.dart'
    as _i72;
import 'package:settings_domain/settings_domain.dart' as _i406;

class SettingsDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i406.SettingsRepository>(
      () => _i72.LocalSettingsRepository(gh<_i699.PreferenceStore>()),
    );
  }
}
