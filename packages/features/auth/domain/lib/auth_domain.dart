import 'package:core_common/core_common.dart';

final class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
  });
  final String id;
  final String email;
  final String displayName;
}

abstract interface class AuthRepository {
  User? get currentUser;
  Stream<User?> get sessionChanges;
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User?>> restoreSession();
  Future<Result<void>> logout();
}

final class Login {
  const Login(this._repository);
  final AuthRepository _repository;
  Future<Result<User>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email.trim(), password: password);
}

final class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;
  Future<Result<User?>> call() => _repository.restoreSession();
}

final class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;
  Future<Result<void>> call() => _repository.logout();
}
