// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:auth_domain/auth_domain.dart' as _i470;
import 'package:auth_presentation/src/bloc/login_bloc.dart' as _i328;
import 'package:auth_presentation/src/session/bloc/session_bloc.dart' as _i278;
import 'package:core_common/core_common.dart' as _i699;
import 'package:injectable/injectable.dart' as _i526;

class AuthPresentationPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.factory<_i328.LoginBloc>(() => _i328.LoginBloc(gh<_i470.Login>()));
    gh.lazySingleton<_i278.SessionBloc>(
      () => _i278.SessionBloc(
        gh<_i470.RestoreSession>(),
        gh<_i470.Logout>(),
        gh<_i470.ExpireDemoSession>(),
        gh<_i470.WatchSession>(),
        gh<_i699.AppEnvironment>(),
      ),
      dispose: (i) => i.close(),
    );
  }
}
