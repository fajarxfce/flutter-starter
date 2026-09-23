// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:core_common/core_common.dart' as _i699;
import 'package:core_network/src/config/network_config.dart' as _i129;
import 'package:core_network/src/di/injection.dart' as _i833;
import 'package:core_network/src/interceptors/credential_interceptor.dart'
    as _i155;
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart'
    as _i231;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

class CoreNetworkPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.BaseOptions>(
      () => networkModule.options(gh<_i129.NetworkConfig>()),
    );
    gh.lazySingleton<_i231.SafeLoggingInterceptor>(
      () => _i231.SafeLoggingInterceptor(gh<_i129.NetworkConfig>()),
    );
    gh.lazySingleton<_i155.CredentialInterceptor>(
      () => _i155.CredentialInterceptor(
        gh<_i699.CredentialStore>(),
        gh<_i129.NetworkConfig>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i361.BaseOptions>(),
        gh<_i361.HttpClientAdapter>(),
        gh<_i155.CredentialInterceptor>(),
        gh<_i231.SafeLoggingInterceptor>(),
      ),
      dispose: _i833.disposeDio,
    );
  }
}

class _$NetworkModule extends _i833.NetworkModule {}
