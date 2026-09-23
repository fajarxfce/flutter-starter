import 'package:fluent_ui/fluent_ui.dart';

abstract final class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double page = 32;
  static const double compactBreakpoint = 720;
}

abstract final class AppTheme {
  static FluentThemeData light() => FluentThemeData(
    brightness: Brightness.light,
    accentColor: Colors.blue,
    visualDensity: VisualDensity.standard,
  );
  static FluentThemeData dark() => FluentThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.blue,
    visualDensity: VisualDensity.standard,
  );
}

class PageBody extends StatelessWidget {
  const PageBody({required this.child, this.maxWidth = 1040, super.key});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.all(
          constraints.maxWidth < AppSpacing.compactBreakpoint
              ? AppSpacing.medium
              : AppSpacing.page,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  const SectionCard({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Card(padding: const EdgeInsets.all(AppSpacing.large), child: child);
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({required this.subtitle, super.key});
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        FluentIcons.app_icon_default,
        size: 36,
        color: FluentTheme.of(context).accentColor,
      ),
      const SizedBox(height: AppSpacing.medium),
      Text('Fluent Starter', style: FluentTheme.of(context).typography.title),
      const SizedBox(height: AppSpacing.small),
      Text(subtitle, style: FluentTheme.of(context).typography.body),
    ],
  );
}

class EnvironmentBadge extends StatelessWidget {
  const EnvironmentBadge({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Environment: $label',
    child: InfoBadge(source: Text(label.toUpperCase())),
  );
}
