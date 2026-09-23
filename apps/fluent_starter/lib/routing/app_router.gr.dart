// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:fluent_starter/routing/pages/home_page.dart' as _i1;
import 'package:fluent_starter/routing/pages/login_page.dart' as _i2;
import 'package:fluent_starter/routing/pages/overview_page.dart' as _i3;
import 'package:fluent_starter/routing/pages/preferences_page.dart' as _i4;
import 'package:fluent_ui/fluent_ui.dart' as _i6;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    void Function(bool)? onResult,
    _i6.Key? key,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(onResult: onResult, key: key),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i2.LoginPage(onResult: args.onResult, key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.onResult, this.key});

  final void Function(bool)? onResult;

  final _i6.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{onResult: $onResult, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i3.OverviewPage]
class OverviewRoute extends _i5.PageRouteInfo<void> {
  const OverviewRoute({List<_i5.PageRouteInfo>? children})
    : super(OverviewRoute.name, initialChildren: children);

  static const String name = 'OverviewRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.OverviewPage();
    },
  );
}

/// generated route for
/// [_i4.PreferencesPage]
class PreferencesRoute extends _i5.PageRouteInfo<void> {
  const PreferencesRoute({List<_i5.PageRouteInfo>? children})
    : super(PreferencesRoute.name, initialChildren: children);

  static const String name = 'PreferencesRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.PreferencesPage();
    },
  );
}
