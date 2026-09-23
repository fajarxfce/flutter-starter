import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
