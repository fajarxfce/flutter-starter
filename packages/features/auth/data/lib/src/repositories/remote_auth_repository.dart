import 'dart:async';

import 'package:auth_data/src/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/src/di/injection.dart';
import 'package:auth_data/src/mappers/user_mapper.dart';
import 'package:auth_data/src/requests/login_request.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository, dispose: disposeAuthRepository)
final class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._remote, this._credentials);
  final AuthRemoteDataSource _remote;
  final CredentialStore _credentials;
  final _sessions = StreamController<User?>.broadcast();
  User? _user;
  int _generation = 0;
  bool _disposed = false;
  @override
  User? get currentUser => _user;
  @override
  Stream<User?> get sessionChanges => _sessions.stream;
  void _publish(User? user) {
    if (_disposed) return;
    _user = user;
    _sessions.add(user);
  }

  static const _storageMessage =
      'Unable to access secure storage. Please try again.';
  static const _cancelled = Failure(
    FailureKind.cancelled,
    'The session changed. Please sign in again.',
  );

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final generation = ++_generation;
    final response = await safeApiCall(() async {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      return (
        accessToken: response.accessToken,
        user: response.user.toEntity(),
      );
    });
    return response.flatMap((response) async {
      if (_isStale(generation)) {
        return const FailureResult(_cancelled);
      }
      if (response.accessToken.isEmpty) {
        return const FailureResult(
          Failure(
            FailureKind.invalidResponse,
            'The service returned an empty session.',
          ),
        );
      }
      final saved = await safeStorageCall(() async {
        await _credentials.write(response.accessToken);
        if (_isStale(generation)) {
          await _credentials.clear();
          return false;
        }
        return true;
      }, message: _storageMessage);
      return saved.flatMap((isCurrent) {
        if (!isCurrent || _isStale(generation)) {
          return const FailureResult<User>(_cancelled);
        }
        _publish(response.user);
        return Success(response.user);
      });
    });
  }

  @override
  Future<Result<User?>> restoreSession() async {
    final generation = _generation;
    final stored = await safeStorageCall(
      _credentials.read,
      message: _storageMessage,
    );
    return stored.flatMap((stored) async {
      if (_isStale(generation)) {
        return const FailureResult(_cancelled);
      }
      if (stored == null) return const Success(null);
      final result = await safeApiCall(
        () async => (await _remote.currentUser()).toEntity(),
      );
      if (result case FailureResult<User>(:final failure)) {
        if (failure.kind == FailureKind.unauthorized && !_isStale(generation)) {
          final cleared = await logout();
          if (cleared case FailureResult<void>(:final failure)) {
            return FailureResult<User?>(failure);
          }
        }
        return FailureResult<User?>(failure);
      }
      return result.flatMap<User?>((user) {
        if (_isStale(generation)) return const FailureResult(_cancelled);
        _publish(user);
        return Success(user);
      });
    });
  }

  @override
  Future<Result<void>> logout() async {
    ++_generation;
    _publish(null);
    return safeStorageCall(_credentials.clear, message: _storageMessage);
  }

  bool _isStale(int generation) => generation != _generation || _disposed;

  Future<void> dispose() async {
    _disposed = true;
    ++_generation;
    await _sessions.close();
  }
}
