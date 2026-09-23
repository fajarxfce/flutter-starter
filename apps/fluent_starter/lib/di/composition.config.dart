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
import 'package:auth_presentation/auth_presentation.dart' as _i612;
import 'package:core_network/core_network.dart' as _i309;
import 'package:dio/dio.dart' as _i361;
import 'package:fluent_starter/config/app_config.dart' as _i209;
import 'package:fluent_starter/di/modules/auth_use_case_module.dart' as _i1;
import 'package:fluent_starter/di/modules/http_transport_module.dart' as _i687;
import 'package:fluent_starter/routing/app_router.dart' as _i902;
import 'package:fluent_starter/routing/guards/session_guard.dart' as _i749;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i309.CoreNetworkPackageModule().init(gh);
    await _i1005.AuthDataPackageModule().init(gh);
    await _i612.AuthPresentationPackageModule().init(gh);
    final httpTransportModule = _$HttpTransportModule();
    final authUseCaseModule = _$AuthUseCaseModule();
    gh.lazySingleton<_i309.NetworkConfig>(
      () => httpTransportModule.networkConfig(gh<_i209.AppConfig>()),
    );
    gh.lazySingleton<_i361.HttpClientAdapter>(
      () => httpTransportModule.httpClientAdapter(gh<_i209.AppConfig>()),
    );
    gh.lazySingleton<_i749.SessionGuard>(
      () => _i749.SessionGuard(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.Login>(
      () => authUseCaseModule.login(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.RestoreSession>(
      () => authUseCaseModule.restoreSession(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.Logout>(
      () => authUseCaseModule.logout(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i902.AppRouter>(
      () => _i902.AppRouter(gh<_i749.SessionGuard>()),
    );
    return this;
  }
}

class _$HttpTransportModule extends _i687.HttpTransportModule {}

class _$AuthUseCaseModule extends _i1.AuthUseCaseModule {}
