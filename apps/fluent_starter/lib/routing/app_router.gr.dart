// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    String section = 'overview',
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         HomeRoute.name,
         args: HomeRouteArgs(section: section, key: key),
         rawQueryParams: {'section': section},
         initialChildren: children,
       );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<HomeRouteArgs>(
        orElse: () => HomeRouteArgs(
          section: queryParams.getString('section', 'overview'),
        ),
      );
      return HomePage(section: args.section, key: args.key);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.section = 'overview', this.key});

  final String section;

  final Key? key;

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
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    void Function(bool)? onResult,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(onResult: onResult, key: key),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginPage(onResult: args.onResult, key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.onResult, this.key});

  final void Function(bool)? onResult;

  final Key? key;

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
