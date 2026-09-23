import 'package:fluent_starter/app_services.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppScope extends InheritedWidget {
  const AppScope({required this.services, required super.child, super.key});
  final AppServices services;
  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;
  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
