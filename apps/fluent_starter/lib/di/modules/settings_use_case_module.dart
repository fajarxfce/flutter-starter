import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';

@module
abstract class SettingsUseCaseModule {
  @injectable
  LoadTheme loadTheme(SettingsRepository repository) => LoadTheme(repository);

  @injectable
  SaveTheme saveTheme(SettingsRepository repository) => SaveTheme(repository);
}
