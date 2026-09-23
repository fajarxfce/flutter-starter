import 'package:core_common/core_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uses memory on web; native platforms use OS credential storage.
CredentialStore createCredentialStore(String namespace) => kIsWeb
    ? MemoryCredentialStore()
    : SecureCredentialStore(const FlutterSecureStorage(), namespace);

final class MemoryCredentialStore implements CredentialStore {
  String? _token;
  @override
  Future<String?> read() async => _token;
  @override
  Future<void> write(String token) async => _token = token;
  @override
  Future<void> clear() async => _token = null;
}

final class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore(this._storage, String namespace)
    : _key = '$namespace.access_token';
  final FlutterSecureStorage _storage;
  final String _key;
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}

final class LocalPreferenceStore implements PreferenceStore {
  LocalPreferenceStore(this._preferences, this.namespace);
  final SharedPreferencesAsync _preferences;
  final String namespace;
  factory LocalPreferenceStore.create(String namespace) =>
      LocalPreferenceStore(SharedPreferencesAsync(), namespace);
  @override
  Future<String?> read(String key) => _preferences.getString('$namespace.$key');
  @override
  Future<void> write(String key, String value) =>
      _preferences.setString('$namespace.$key', value);
}
