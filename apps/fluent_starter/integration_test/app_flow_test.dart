import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/app_services_factory.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native login survives app services recreation and logs out', (
    tester,
  ) async {
    final config = AppConfig.fromEnvironment();
    final services = await createAppServices(config);
    await services.signOut();
    await tester.pumpWidget(FluentStarterApp(services: services));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'demo@example.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'Demo123!');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Welcome, Alex Morgan'), findsOneWidget);
    final restored = await createAppServices(config);
    expect(restored.repository.currentUser?.email, 'demo@example.com');
    await restored.dispose();
    restored.theme.dispose();
    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await services.dispose();
    services.theme.dispose();
  });
}
