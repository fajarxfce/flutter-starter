import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/app_scope.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/home_presentation.dart';

@RoutePage()
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: services.theme,
      builder: (context, mode, _) => HomePreferences(
        themeMode: mode,
        onThemeChanged: (mode) => unawaited(services.setTheme(mode)),
      ),
    );
  }
}
