import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_starter/routing/guards/session_guard.dart';
import 'package:injectable/injectable.dart';

@injectable
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this.sessionGuard);
  final SessionGuard sessionGuard;
  @override
  List<AutoRoute> get routes => [
    RedirectRoute(path: '/', redirectTo: '/home'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      guards: [sessionGuard],
      children: [
        AutoRoute(page: OverviewRoute.page, path: ''),
        AutoRoute(page: PreferencesRoute.page, path: 'preferences'),
      ],
    ),
    RedirectRoute(path: '*', redirectTo: '/home'),
  ];
}
