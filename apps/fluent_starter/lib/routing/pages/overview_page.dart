import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/app_scope.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/home_presentation.dart';

@RoutePage()
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _busy = false;
  String? _message;

  Future<void> _checkSession() async {
    if (_busy) return;
    setState(() => _busy = true);
    final message = await AppScope.of(context).checkSession();
    if (mounted) {
      setState(() {
        _busy = false;
        _message = message ?? 'Your session is up to date.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final user = services.repository.currentUser;
    if (user == null) return const SizedBox.shrink();
    return HomeOverview(
      displayName: user.displayName,
      email: user.email,
      environment: services.config.label,
      busy: _busy,
      message: _message,
      onCheckSession: _checkSession,
      onLogout: services.signOut,
      onExpireDemoSession: services.config.isDemo
          ? services.expireDemoSession
          : null,
    );
  }
}
