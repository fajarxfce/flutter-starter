// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:fluent_starter/routing/pages/home_page.dart' as _i1;
import 'package:fluent_starter/routing/pages/login_page.dart' as _i2;
import 'package:fluent_ui/fluent_ui.dart' as _i4;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i3.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    String section = 'overview',
    _i4.Key? key,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         HomeRoute.name,
         args: HomeRouteArgs(section: section, key: key),
         rawQueryParams: {'section': section},
         initialChildren: children,
       );

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<HomeRouteArgs>(
        orElse: () => HomeRouteArgs(
          section: queryParams.getString('section', 'overview'),
        ),
      );
      return _i1.HomePage(section: args.section, key: args.key);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.section = 'overview', this.key});

  final String section;

  final _i4.Key? key;

  @override
  String toString() {
    return 'HomeRouteArgs{section: $section, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteArgs) return false;
    return section == other.section && key == other.key;
  }

  @override
  int get hashCode => section.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i3.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    void Function(bool)? onResult,
    _i4.Key? key,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(onResult: onResult, key: key),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i3.PageInfo page = _i3.PageInfo(
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

  final _i4.Key? key;

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
