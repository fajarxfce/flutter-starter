import 'package:auth_domain/auth_domain.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
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
