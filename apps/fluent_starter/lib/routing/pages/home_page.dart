import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/app_scope.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/home_presentation.dart';

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
