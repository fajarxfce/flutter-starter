import 'dart:async';

import 'package:auth_data/src/models/auth_session.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:injectable/injectable.dart';

/// Owns local session state and serializes access to persisted credentials.
@lazySingleton
final class AuthLocalDataSource {
  AuthLocalDataSource(this._credentials);

  final CredentialStore _credentials;
  final _changes = StreamController<User?>.broadcast();
  Future<void>? _pendingStorage;
  User? _user;
  int _revision = 0;
  bool _disposed = false;

  static const _storageMessage =
      'Unable to access secure storage. Please try again.';
  static const _cancelled = Failure(
    FailureKind.cancelled,
    'The session changed. Please sign in again.',
  );

  User? get currentUser => _user;
  Stream<User?> get sessionChanges => _changes.stream;
  int get revision => _revision;

  /// Invalidates older login and restore operations before starting a request.
  int beginLogin() => ++_revision;

  Future<Result<bool>> hasToken({required int revision}) =>
      _serialize(() async {
        if (!_isCurrent(revision)) return const FailureResult(_cancelled);
        final stored = await safeStorageCall(
          _credentials.read,
          message: _storageMessage,
        );
        return stored.flatMap((token) {
          if (!_isCurrent(revision)) return const FailureResult(_cancelled);
          return Success(token != null);
        });
      });

  Future<Result<User>> saveSession(
    AuthSession session, {
    required int revision,
  }) => _serialize(() async {
    if (!_isCurrent(revision)) return const FailureResult(_cancelled);
    final stored = await safeStorageCall(() async {
      await _credentials.write(session.accessToken);
      // Rollback runs before any newer queued write can commit its token.
      if (!_isCurrent(revision)) await _credentials.clear();
    }, message: _storageMessage);
    return stored.flatMap((_) => restoreUser(session.user, revision: revision));
  });

  Result<User> restoreUser(User user, {required int revision}) {
    if (!_isCurrent(revision)) return const FailureResult(_cancelled);
    _publish(user);
    return Success(user);
  }

  /// An old unauthorized response must not invalidate a newer session.
  Future<Result<void>> clearIfCurrent({required int revision}) {
    if (!_isCurrent(revision)) return Future.value(const Success(null));
    return clearSession();
  }

  Future<Result<void>> clearSession() {
    if (_disposed) return Future.value(const FailureResult(_cancelled));
    ++_revision;
    _publish(null);
    return _serialize(
      () => safeStorageCall(_credentials.clear, message: _storageMessage),
    );
  }

  bool _isCurrent(int revision) => !_disposed && revision == _revision;

  void _publish(User? user) {
    _user = user;
    _changes.add(user);
  }

  Future<Result<T>> _serialize<T>(
    Future<Result<T>> Function() operation,
  ) async {
    final previous = _pendingStorage;
    final completed = Completer<void>();
    _pendingStorage = completed.future;
    if (previous != null) await previous;
    try {
      return await operation();
    } finally {
      if (identical(_pendingStorage, completed.future)) _pendingStorage = null;
      completed.complete();
    }
  }

  @disposeMethod
  Future<void> dispose() async {
    _disposed = true;
    ++_revision;
    final pending = _pendingStorage;
    if (pending != null) await pending;
    await _changes.close();
  }
}
