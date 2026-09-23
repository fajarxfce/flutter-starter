import 'package:auth_domain/src/entities/user.dart';
import 'package:auth_domain/src/repositories/auth_repository.dart';
import 'package:core_common/core_common.dart';

final class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;
  Future<Result<User?>> call() => _repository.restoreSession();
}
