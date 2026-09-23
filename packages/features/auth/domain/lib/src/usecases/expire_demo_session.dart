import 'package:auth_domain/src/repositories/demo_session_repository.dart';
import 'package:core_common/core_common.dart';

final class ExpireDemoSession {
  const ExpireDemoSession(this._repository);
  final DemoSessionRepository _repository;
  Future<Result<void>> call() => _repository.expireSession();
}
