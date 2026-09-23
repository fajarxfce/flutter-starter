import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_starter/app_scope.dart';
import 'package:fluent_starter/app_services.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FluentStarterApp extends StatefulWidget {
  const FluentStarterApp({required this.services, this.router, super.key});
  final AppServices services;
  final AppRouter? router;
  @override
  State<FluentStarterApp> createState() => _FluentStarterAppState();
}

class _FluentStarterAppState extends State<FluentStarterApp> {
  late final AppRouter _router;
  late final StreamSubscription<User?> _subscription;
  User? _previous;
  @override
  void initState() {
    super.initState();
    _router = widget.router ?? AppRouter(widget.services.repository);
    _previous = widget.services.repository.currentUser;
    _subscription = widget.services.repository.sessionChanges.listen((user) {
      if (_previous != null && user == null) {
        unawaited(_router.replaceAll([LoginRoute()]));
      }
      _previous = user;
    });
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    services: widget.services,
    child: ValueListenableBuilder(
      valueListenable: widget.services.theme,
      builder: (context, mode, _) => FluentApp.router(
        title: 'Fluent Starter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router.config(),
      ),
    ),
  );
}
