// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:auth_data/src/datasources/remote/auth_api.dart' as _i42;
import 'package:auth_data/src/datasources/remote/auth_remote_data_source.dart'
    as _i471;
import 'package:auth_data/src/di/injection.dart' as _i570;
import 'package:auth_data/src/repositories/adapter_demo_session_repository.dart'
    as _i574;
import 'package:auth_data/src/repositories/remote_auth_repository.dart'
    as _i168;
import 'package:auth_domain/auth_domain.dart' as _i470;
import 'package:core_common/core_common.dart' as _i699;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

class AuthDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final authModule = _$AuthModule();
    gh.lazySingleton<_i470.DemoSessionRepository>(
      () => _i574.AdapterDemoSessionRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i42.AuthApi>(() => _i42.AuthApi(gh<_i361.Dio>()));
    gh.factory<_i470.ExpireDemoSession>(
      () => authModule.expireDemoSession(gh<_i470.DemoSessionRepository>()),
    );
    gh.lazySingleton<_i471.AuthRemoteDataSource>(
      () => _i471.AuthRemoteDataSource(gh<_i42.AuthApi>()),
    );
    gh.lazySingleton<_i470.AuthRepository>(
      () => _i168.RemoteAuthRepository(
        gh<_i471.AuthRemoteDataSource>(),
        gh<_i699.CredentialStore>(),
      ),
      dispose: _i570.disposeAuthRepository,
    );
    gh.factory<_i470.Login>(() => authModule.login(gh<_i470.AuthRepository>()));
    gh.factory<_i470.RestoreSession>(
      () => authModule.restoreSession(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.Logout>(
      () => authModule.logout(gh<_i470.AuthRepository>()),
    );
    gh.factory<_i470.WatchSession>(
      () => authModule.watchSession(gh<_i470.AuthRepository>()),
    );
  }
}

class _$AuthModule extends _i570.AuthModule {}
