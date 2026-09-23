import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_presentation/src/bloc/appearance_bloc.dart';
import 'package:settings_presentation/src/events/appearance_event.dart';
import 'package:settings_presentation/src/state/appearance_state.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppearanceBloc, AppearanceState>(
        builder: (context, state) => PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferences',
                style: FluentTheme.of(context).typography.title,
              ),
              const SizedBox(height: AppSpacing.large),
              InfoLabel(
                label: 'Appearance',
                child: ComboBox<ThemeMode>(
                  key: const Key('appearance_theme'),
                  value: state.mode,
                  items: const [
                    ComboBoxItem(
                      value: ThemeMode.system,
                      child: Text('Use system setting'),
                    ),
                    ComboBoxItem(value: ThemeMode.light, child: Text('Light')),
                    ComboBoxItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (mode) => context.read<AppearanceBloc>().add(
                    AppearanceThemeSelected(mode),
                  ),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.medium),
                InfoBar(
                  title: const Text('Appearance'),
                  content: Text(state.error!),
                  severity: InfoBarSeverity.warning,
                ),
              ],
            ],
          ),
        ),
      );
}
