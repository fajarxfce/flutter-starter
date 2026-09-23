import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';
import 'package:settings_domain/settings_domain.dart';

@LazySingleton(as: SettingsRepository)
final class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._preferences);
  final PreferenceStore _preferences;

  @override
  Future<Result<AppThemeMode>> loadTheme() async {
    try {
      final saved = await _preferences.read('theme');
      return Success(
        AppThemeMode.values.where((mode) => mode.name == saved).firstOrNull ??
            AppThemeMode.system,
      );
    } on Object {
      return const FailureResult(
        Failure(FailureKind.storage, 'Unable to load appearance preferences.'),
      );
    }
  }

  @override
  Future<Result<void>> saveTheme(AppThemeMode mode) async {
    try {
      await _preferences.write('theme', mode.name);
      return const Success(null);
    } on Object {
      return const FailureResult(
        Failure(
          FailureKind.storage,
          'Appearance changed for this session, but could not be saved.',
        ),
      );
    }
  }
}
