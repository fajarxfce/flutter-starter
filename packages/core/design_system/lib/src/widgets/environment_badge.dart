import 'package:fluent_ui/fluent_ui.dart';

class EnvironmentBadge extends StatelessWidget {
  const EnvironmentBadge({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Environment: $label',
    child: InfoBadge(source: Text(label.toUpperCase())),
  );
}
