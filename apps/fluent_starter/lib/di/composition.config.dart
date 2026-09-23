// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auth_data/auth_data.dart' as _i1005;
import 'package:auth_domain/auth_domain.dart' as _i470;
import 'package:core_common/core_common.dart' as _i699;
import 'package:dio/dio.dart' as _i361;
import 'package:fluent_starter/config/app_config.dart' as _i209;
import 'package:fluent_starter/di/composition.dart' as _i90;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final compositionModule = _$CompositionModule();
    gh.lazySingleton<_i361.Dio>(
      () => compositionModule.dio(
        gh<_i209.AppConfig>(),
        gh<_i699.CredentialStore>(),
      ),
    );
    gh.lazySingleton<_i1005.AuthApi>(
      () => compositionModule.api(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i470.AuthRepository>(
      () => compositionModule.repository(
        gh<_i1005.AuthApi>(),
        gh<_i699.CredentialStore>(),
      ),
      dispose: _i90.disposeRepository,
    );
    gh.factory<_i470.Login>(
      () => compositionModule.login(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.RestoreSession>(
      () => compositionModule.restore(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.Logout>(
      () => compositionModule.logout(gh<_i470.AuthRepository>()),
    );
    return this;
  }
}

class _$CompositionModule extends _i90.CompositionModule {}
