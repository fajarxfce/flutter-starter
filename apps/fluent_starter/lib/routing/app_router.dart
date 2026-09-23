import 'dart:async';

import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_starter/routing/guards/session_guard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this.sessionGuard, SessionBloc session, this._container)
    : _authenticated = session.state.isAuthenticated {
    _subscription = session.stream.listen(_onSessionChanged);
  }
  final SessionGuard sessionGuard;
  final GetIt _container;
  late final StreamSubscription<SessionState> _subscription;
  bool _authenticated;

  void _onSessionChanged(SessionState state) {
    if (_authenticated == state.isAuthenticated) return;
    _authenticated = state.isAuthenticated;
    if (!_authenticated) {
      sessionGuard.cancelPendingNavigation();
      unawaited(replaceAll([const LoginRoute()]));
    } else if (!sessionGuard.resumePendingNavigation()) {
      unawaited(replaceAll([const HomeRoute()]));
    }
  }

  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    sessionGuard.cancelPendingNavigation();
    super.dispose();
  }

  @override
  List<AutoRoute> get routes => [
    RedirectRoute(path: '/', redirectTo: '/home'),
    AutoRoute(
      page: LoginRoute.page.copyWith(
        builder: (data) => BlocProvider(
          create: (_) => _container<LoginBloc>(),
          child: LoginRoute.page.builder(data),
        ),
      ),
      path: '/login',
    ),
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
