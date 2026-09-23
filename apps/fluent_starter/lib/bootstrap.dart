import 'package:fluent_starter/app.dart';
import 'package:fluent_starter/config/app_config.dart';
import 'package:fluent_starter/di/app_services_factory.dart';
import 'package:fluent_ui/fluent_ui.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await createAppServices(config);
  runApp(FluentStarterApp(services: services));
}
