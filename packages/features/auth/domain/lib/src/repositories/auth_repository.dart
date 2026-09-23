import 'package:auth_domain/src/entities/user.dart';
import 'package:core_common/core_common.dart';

abstract interface class AuthRepository {
  User? get currentUser;
  Stream<User?> get sessionChanges;
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User?>> restoreSession();
  Future<Result<void>> logout();
}
