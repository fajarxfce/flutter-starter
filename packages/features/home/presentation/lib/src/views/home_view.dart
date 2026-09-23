import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/src/widgets/home_overview.dart';
import 'package:home_presentation/src/widgets/home_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required this.displayName,
    required this.email,
    required this.environment,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLogout,
    required this.onCheckSession,
    this.onExpireDemoSession,
    this.initialSection = 'overview',
    super.key,
  });
  final String displayName;
  final String email;
  final String environment;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Future<void> Function() onLogout;
  final Future<String?> Function() onCheckSession;
  final Future<void> Function()? onExpireDemoSession;
  final String initialSection;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _selected = widget.initialSection == 'preferences' ? 1 : 0;
  bool _busy = false;
  String? _message;
  Future<void> _check() async {
    if (_busy) return;
    setState(() => _busy = true);
    final message = await widget.onCheckSession();
    if (mounted) {
      setState(() {
        _busy = false;
        _message = message ?? 'Your session is up to date.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < AppSpacing.compactBreakpoint;
      return NavigationView(
        titleBar: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Fluent Starter'),
        ),
        pane: NavigationPane(
          displayMode: compact
              ? PaneDisplayMode.minimal
              : PaneDisplayMode.expanded,
          selected: _selected,
          onChanged: (value) => setState(() => _selected = value),
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Overview'),
              body: HomeOverview(
                displayName: widget.displayName,
                email: widget.email,
                environment: widget.environment,
                busy: _busy,
                message: _message,
                onCheckSession: _check,
                onLogout: widget.onLogout,
                onExpireDemoSession: widget.onExpireDemoSession,
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Preferences'),
              body: HomePreferences(
                themeMode: widget.themeMode,
                onThemeChanged: widget.onThemeChanged,
              ),
            ),
          ],
        ),
      );
    },
  );
}
