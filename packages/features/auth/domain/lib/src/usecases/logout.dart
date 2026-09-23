import 'package:auth_domain/src/repositories/auth_repository.dart';
import 'package:core_common/core_common.dart';

final class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;
  Future<Result<void>> call() => _repository.logout();
}
