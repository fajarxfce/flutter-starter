import 'package:core_testing/core_testing.dart';
import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/app_services.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/app_services_factory.dart';
import 'package:fluent_starter/routing/app_router.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppServices services;
  late AppRouter router;
  setUp(() async {
    services = await createAppServices(
      AppConfig.parse(flavor: 'dev', backend: 'demo'),
      credentials: FakeCredentialStore(),
      preferences: FakePreferenceStore(),
    );
    router = services.createRouter();
  });
  tearDown(() async {
    services.theme.dispose();
    await services.dispose();
  });
  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'Demo123!');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('login, protected home, logout and back navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      FluentStarterApp(services: services, router: router),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    await signIn(tester);
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(router.stack.length, 1);
    expect(services.repository.currentUser, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('protected deep link retains query after login', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/home?section=preferences';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await tester.pumpWidget(
      FluentStarterApp(services: services, router: router),
    );
    await tester.pumpAndSettle();
    await signIn(tester);
    expect(find.text('Appearance'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('expired session removes the protected page', (tester) async {
    await tester.runAsync(
      () => services.login(email: 'demo@example.com', password: 'Demo123!'),
    );
    await tester.pumpWidget(
      FluentStarterApp(services: services, router: router),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expire demo session'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(router.stack.length, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('compact login supports large text and exposes validation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await tester.pumpWidget(
      FluentStarterApp(services: services, router: router),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('login_submit')));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('theme persists through app services recreation', () async {
    final preferences = FakePreferenceStore();
    final first = await createAppServices(
      services.config,
      credentials: FakeCredentialStore(),
      preferences: preferences,
    );
    await first.setTheme(ThemeMode.dark);
    final second = await createAppServices(
      services.config,
      credentials: FakeCredentialStore(),
      preferences: preferences,
    );
    expect(second.theme.value, ThemeMode.dark);
    first.theme.dispose();
    second.theme.dispose();
    await first.dispose();
    await second.dispose();
  });
}
