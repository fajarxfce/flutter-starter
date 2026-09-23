import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HomePreferences extends StatelessWidget {
  const HomePreferences({
    required this.themeMode,
    required this.onThemeChanged,
    super.key,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  Widget build(BuildContext context) => PageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: FluentTheme.of(context).typography.title),
        const SizedBox(height: AppSpacing.large),
        InfoLabel(
          label: 'Appearance',
          child: ComboBox<ThemeMode>(
            value: themeMode,
            items: const [
              ComboBoxItem(
                value: ThemeMode.system,
                child: Text('Use system setting'),
              ),
              ComboBoxItem(value: ThemeMode.light, child: Text('Light')),
              ComboBoxItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (mode) {
              if (mode != null) onThemeChanged(mode);
            },
          ),
        ),
      ],
    ),
  );
}
