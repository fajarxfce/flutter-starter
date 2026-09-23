import 'package:auth_domain/auth_domain.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_starter/routing/guards/session_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this.repository);
  final AuthRepository repository;
  @override
  List<AutoRoute> get routes => [
    RedirectRoute(path: '/', redirectTo: '/home'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      guards: [SessionGuard(repository)],
    ),
    RedirectRoute(path: '*', redirectTo: '/home'),
  ];
}
