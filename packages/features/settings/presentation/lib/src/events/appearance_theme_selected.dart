part of 'appearance_event.dart';

final class AppearanceThemeSelected extends AppearanceEvent {
  const AppearanceThemeSelected(this.mode);
  final ThemeMode? mode;
}
