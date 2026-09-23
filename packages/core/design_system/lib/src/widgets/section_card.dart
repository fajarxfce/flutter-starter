import 'package:core_design_system/src/tokens/app_spacing.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Card(padding: const EdgeInsets.all(AppSpacing.large), child: child);
}
