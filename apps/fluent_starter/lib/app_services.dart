import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_ui/fluent_ui.dart';

final class AppServices {
  AppServices({
    required this.config,
    required this.repository,
    required this.login,
    required this.restore,
    required this.logout,
    required this.preferences,
    required this.dio,
    required this.dispose,
    required this.createLoginBloc,
    required this.createRouter,
  });
  final AppConfig config;
  final AuthRepository repository;
  final Login login;
  final RestoreSession restore;
  final Logout logout;
  final PreferenceStore preferences;
  final Dio dio;
  final Future<void> Function() dispose;
  final LoginBloc Function() createLoginBloc;
  final AppRouter Function() createRouter;
  final theme = ValueNotifier(ThemeMode.system);
  String? sessionMessage;
  Future<void> prepare() async {
    try {
      final saved = await preferences.read('theme');
      theme.value =
          ThemeMode.values.where((mode) => mode.name == saved).firstOrNull ??
          ThemeMode.system;
    } on Object {
      /* Preferences must not prevent startup. */
    }
    final result = await restore();
    if (result case FailureResult<User?>(:final failure)) {
      sessionMessage = failure.message;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    theme.value = mode;
    try {
      await preferences.write('theme', mode.name);
    } on Object {
      /* Keep the chosen theme for this session. */
    }
  }

  Future<String?> checkSession() async {
    final result = await restore();
    return switch (result) {
      FailureResult<User?>(:final failure) => failure.message,
      _ => null,
    };
  }

  Future<void> signOut() async {
    final result = await logout();
    sessionMessage = switch (result) {
      FailureResult<void>(:final failure) => failure.message,
      _ => null,
    };
  }

  Future<void> expireDemoSession() async {
    final adapter = dio.httpClientAdapter;
    if (adapter is DemoAdapter) {
      adapter.expireSession = true;
      await checkSession();
    }
  }
}
