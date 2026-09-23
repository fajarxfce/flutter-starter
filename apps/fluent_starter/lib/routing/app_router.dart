import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/app_services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_presentation/home_presentation.dart';

part 'app_router.gr.dart';

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

class SessionGuard extends AutoRouteGuard {
  SessionGuard(this.repository);
  final AuthRepository repository;
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (repository.currentUser != null) {
      resolver.next();
      return;
    }
    resolver.redirectUntil(
      LoginRoute(
        onResult: (success) {
          resolver.resolveNext(success, reevaluateNext: false);
        },
      ),
    );
  }
}

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({this.onResult, super.key});
  final void Function(bool)? onResult;
  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return BlocProvider(
      create: (_) => LoginCubit(services.login),
      child: LoginView(
        environment: services.config.label,
        isDemo: services.config.isDemo,
        sessionMessage: services.sessionMessage,
        onSignedIn: () {
          services.sessionMessage = null;
          if (onResult != null) {
            onResult!(true);
          } else {
            unawaited(context.router.replaceAll([HomeRoute()]));
          }
        },
      ),
    );
  }
}

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({@QueryParam('section') this.section = 'overview', super.key});
  final String section;
  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final user = services.repository.currentUser;
    if (user == null) return const SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: services.theme,
      builder: (context, mode, _) => HomeView(
        displayName: user.displayName,
        email: user.email,
        environment: services.config.label,
        initialSection: section,
        themeMode: mode,
        onThemeChanged: (mode) => unawaited(services.setTheme(mode)),
        onLogout: services.signOut,
        onCheckSession: services.checkSession,
        onExpireDemoSession: services.config.isDemo
            ? services.expireDemoSession
            : null,
      ),
    );
  }
}
