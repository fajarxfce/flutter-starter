import 'package:auth_domain/src/entities/user.dart';
import 'package:auth_domain/src/repositories/auth_repository.dart';
import 'package:core_common/core_common.dart';

final class Login {
  const Login(this._repository);
  final AuthRepository _repository;
  Future<Result<User>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email.trim(), password: password);
}
