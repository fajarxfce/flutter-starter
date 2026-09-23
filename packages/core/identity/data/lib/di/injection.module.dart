// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_common/core_common.dart' as _i699;
import 'package:dio/dio.dart' as _i361;
import 'package:identity_data/di/injection.dart' as _i439;
import 'package:identity_data/src/config/oauth_configuration.dart' as _i356;
import 'package:identity_data/src/datasources/local/auth_local_data_source.dart'
    as _i474;
import 'package:identity_data/src/datasources/remote/auth_api.dart' as _i70;
import 'package:identity_data/src/datasources/remote/auth_remote_data_source.dart'
    as _i484;
import 'package:identity_data/src/datasources/remote/oauth_remote_data_source.dart'
    as _i163;
import 'package:identity_data/src/oauth/oauth_browser.dart' as _i79;
import 'package:identity_data/src/repositories/adapter_demo_session_repository.dart'
    as _i345;
import 'package:identity_data/src/repositories/remote_identity_repository.dart'
    as _i572;
import 'package:identity_domain/identity_domain.dart' as _i516;
import 'package:injectable/injectable.dart' as _i526;

class IdentityDataPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final identityModule = _$IdentityModule();
    gh.lazySingleton<_i79.OAuthBrowser>(
      () => identityModule.oauthBrowser(
        gh<_i699.AppEnvironment>(),
        gh<_i361.Dio>(instanceName: 'mainApi'),
      ),
    );
    gh.lazySingleton<_i474.AuthLocalDataSource>(
      () => _i474.AuthLocalDataSource(gh<_i699.CredentialStore>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i70.AuthApi>(
      () => _i70.AuthApi(gh<_i361.Dio>(instanceName: 'mainApi')),
    );
    gh.lazySingleton<_i516.DemoSessionRepository>(
      () => _i345.AdapterDemoSessionRepository(
        gh<_i361.Dio>(instanceName: 'mainApi'),
      ),
    );
    gh.lazySingleton<_i163.OAuthRemoteDataSource>(
      () => _i163.OAuthRemoteDataSource(
        gh<_i70.AuthApi>(),
        gh<_i79.OAuthBrowser>(),
        gh<_i356.OAuthConfiguration>(),
      ),
    );
    gh.lazySingleton<_i484.AuthRemoteDataSource>(
      () => _i484.AuthRemoteDataSource(gh<_i70.AuthApi>()),
    );
    gh.factory<_i516.ExpireDemoSession>(
      () => identityModule.expireDemoSession(gh<_i516.DemoSessionRepository>()),
    );
    gh.lazySingleton<_i516.IdentityRepository>(
      () => _i572.RemoteIdentityRepository(
        gh<_i484.AuthRemoteDataSource>(),
        gh<_i474.AuthLocalDataSource>(),
        gh<_i163.OAuthRemoteDataSource>(),
      ),
    );
    gh.factory<_i516.GetIdentityProviders>(
      () => identityModule.getIdentityProviders(gh<_i516.IdentityRepository>()),
    );
    gh.factory<_i516.Login>(
      () => identityModule.login(gh<_i516.IdentityRepository>()),
    );
    gh.factory<_i516.RestoreSession>(
      () => identityModule.restoreSession(gh<_i516.IdentityRepository>()),
    );
    gh.factory<_i516.Logout>(
      () => identityModule.logout(gh<_i516.IdentityRepository>()),
    );
    gh.factory<_i516.WatchSession>(
      () => identityModule.watchSession(gh<_i516.IdentityRepository>()),
    );
    gh.factory<_i516.GetCurrentSession>(
      () => identityModule.getCurrentSession(gh<_i516.IdentityRepository>()),
    );
    gh.lazySingleton<_i516.LoginWithProvider>(
      () => identityModule.loginWithProvider(gh<_i516.IdentityRepository>()),
    );
  }
}

class _$IdentityModule extends _i439.IdentityModule {}
