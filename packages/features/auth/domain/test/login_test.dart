import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:test/test.dart';

class RecordingRepository implements AuthRepository {
  String? submittedEmail;
  String? submittedPassword;
  @override
  User? get currentUser => null;
  @override
  Stream<User?> get sessionChanges => const Stream.empty();
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    submittedEmail = email;
    submittedPassword = password;
    return Success(User(id: '1', email: email, displayName: 'Demo'));
  }

  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<User?>> restoreSession() async => const Success(null);
}

void main() {
  test('login trims email but preserves password verbatim', () async {
    final repository = RecordingRepository();
    await Login(repository)(email: ' demo@example.com ', password: ' secret ');
    expect(repository.submittedEmail, 'demo@example.com');
    expect(repository.submittedPassword, ' secret ');
  });
}
