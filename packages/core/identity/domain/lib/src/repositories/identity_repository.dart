import 'package:core_common/core_common.dart';
import 'package:identity_domain/src/entities/session.dart';
import 'package:identity_domain/src/entities/user.dart';

abstract interface class IdentityRepository {
  Session get session;

  /// Emits the current snapshot on subscription, then every session change.
  Stream<Session> get sessionChanges;
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User?>> restoreSession();
  Future<Result<void>> logout();
}
