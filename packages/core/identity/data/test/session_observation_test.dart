import 'package:core_testing/core_testing.dart';
import 'package:identity_data/identity_data.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:test/test.dart';

const user = User(id: '1', email: 'alex@example.com', displayName: 'Alex');
const saved = AuthSession(accessToken: 'token', user: user);

void main() {
  test(
    'new observers receive the current session, then ordered changes',
    () async {
      final local = AuthLocalDataSource(FakeCredentialStore());
      addTearDown(local.dispose);
      final first = expectLater(
        local.sessionChanges,
        emitsInOrder([
          isA<SessionUninitialized>(),
          isA<SessionAuthenticated>().having((s) => s.user, 'user', same(user)),
          isA<SessionUnauthenticated>(),
        ]),
      );
      await local.saveSession(saved, revision: local.beginLogin());
      final late = await local.sessionChanges.first;
      expect(late.user, same(user));
      await local.clearSession();
      await first;
      expect(await local.sessionChanges.first, isA<SessionUnauthenticated>());
    },
  );

  test(
    'observers have independent lifetimes and disposal closes the stream',
    () async {
      final local = AuthLocalDataSource(FakeCredentialStore());
      final disposable = local.sessionChanges.listen((_) {});
      await disposable.cancel();
      final remaining = expectLater(
        local.sessionChanges,
        emitsInOrder([
          isA<SessionUninitialized>(),
          isA<SessionAuthenticated>(),
          emitsDone,
        ]),
      );
      await local.saveSession(saved, revision: local.beginLogin());
      await local.dispose();
      await remaining;
      await expectLater(local.sessionChanges, emitsDone);
    },
  );

  test(
    'restoring without a stored token publishes a signed-out snapshot',
    () async {
      final local = AuthLocalDataSource(FakeCredentialStore());
      addTearDown(local.dispose);
      await local.hasToken(revision: local.revision);
      expect(local.session, isA<SessionUnauthenticated>());
      expect(await local.sessionChanges.first, same(local.session));
    },
  );
}
