import 'package:auth_domain/src/entities/user.dart';
import 'package:auth_domain/src/repositories/auth_repository.dart';

final class WatchSession {
  const WatchSession(this._repository);
  final AuthRepository _repository;
  Stream<User?> call() => _repository.sessionChanges;
}
