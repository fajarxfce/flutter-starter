import 'dart:async';

import 'package:auth_data/src/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/src/di/auth_repository_disposer.dart';
import 'package:auth_data/src/mappers/user_mapper.dart';
import 'package:auth_data/src/requests/login_request.dart';
import 'package:auth_data/src/responses/login_response.dart';
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

  static const _storageFailure = Failure(
    FailureKind.storage,
    'Unable to access secure storage. Please try again.',
  );
  static const _cancelled = Failure(
    FailureKind.unexpected,
    'The session changed. Please sign in again.',
  );

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final generation = ++_generation;
    late final LoginResponse response;
    try {
      response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
    } on Object catch (error) {
      return FailureResult(mapNetworkFailure(error));
    }
    if (generation != _generation || _disposed) {
      return const FailureResult(_cancelled);
    }
    if (response.accessToken.isEmpty) {
      return const FailureResult(
        Failure(
          FailureKind.unexpected,
          'The service returned an empty session.',
        ),
      );
    }
    try {
      await _credentials.write(response.accessToken);
      if (generation != _generation || _disposed) {
        await _credentials.clear();
        return const FailureResult(_cancelled);
      }
    } on Object {
      return const FailureResult(_storageFailure);
    }
    final user = response.user.toEntity();
    _publish(user);
    return Success(user);
  }

  @override
  Future<Result<User?>> restoreSession() async {
    final generation = _generation;
    try {
      if (await _credentials.read() == null) return const Success(null);
    } on Object {
      return const FailureResult(_storageFailure);
    }
    try {
      final user = (await _remote.currentUser()).toEntity();
      if (generation != _generation || _disposed) {
        return const FailureResult(_cancelled);
      }
      _publish(user);
      return Success(user);
    } on Object catch (error) {
      final failure = mapNetworkFailure(error);
      if (failure.kind == FailureKind.unauthorized &&
          generation == _generation) {
        await logout();
      }
      return FailureResult(failure);
    }
  }

  @override
  Future<Result<void>> logout() async {
    ++_generation;
    _publish(null);
    try {
      await _credentials.clear();
      return const Success(null);
    } on Object {
      return const FailureResult(_storageFailure);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    ++_generation;
    await _sessions.close();
  }
}
