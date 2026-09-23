import 'package:core_common/core_common.dart';

export 'package:mocktail/mocktail.dart';

final class FakeCredentialStore implements CredentialStore {
  String? token;
  bool failWrites = false;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async {
    if (failWrites) throw StateError('Storage unavailable');
    token = value;
  }

  @override
  Future<void> clear() async => token = null;
}

final class FakePreferenceStore implements PreferenceStore {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
