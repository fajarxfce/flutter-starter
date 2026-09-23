import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
              body: _overview(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Preferences'),
              body: _preferences(),
            ),
          ],
        ),
      );
    },
  );
  Widget _overview() => PageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome, ${widget.displayName}',
          style: FluentTheme.of(context).typography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(widget.email),
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: Alignment.centerLeft,
          child: EnvironmentBadge(label: widget.environment),
        ),
        const SizedBox(height: AppSpacing.large),
        const SectionCard(
          child: BrandHeader(
            subtitle: 'Your workspace is ready. Make it your own.',
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Wrap(
          spacing: AppSpacing.medium,
          runSpacing: AppSpacing.medium,
          children: [
            FilledButton(
              onPressed: _busy ? null : () => unawaited(_check()),
              child: const Text('Check session'),
            ),
            Button(
              key: const Key('logout'),
              onPressed: () => unawaited(widget.onLogout()),
              child: const Text('Sign out'),
            ),
            if (widget.onExpireDemoSession != null)
              Button(
                onPressed: () => unawaited(widget.onExpireDemoSession!()),
                child: const Text('Expire demo session'),
              ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.medium),
          InfoBar(title: const Text('Session'), content: Text(_message!)),
        ],
      ],
    ),
  );
  Widget _preferences() => PageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: FluentTheme.of(context).typography.title),
        const SizedBox(height: AppSpacing.large),
        InfoLabel(
          label: 'Appearance',
          child: ComboBox<ThemeMode>(
            value: widget.themeMode,
            items: const [
              ComboBoxItem(
                value: ThemeMode.system,
                child: Text('Use system setting'),
              ),
              ComboBoxItem(value: ThemeMode.light, child: Text('Light')),
              ComboBoxItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (mode) {
              if (mode != null) widget.onThemeChanged(mode);
            },
          ),
        ),
      ],
    ),
  );
}
