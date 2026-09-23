import 'dart:async';

import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:test/test.dart';

class _MockCredentials extends Mock implements CredentialStore {}

const _first = AuthSession(
  accessToken: 'first-token',
  user: User(id: 'first', email: 'first@example.com', displayName: 'First'),
);
const _second = AuthSession(
  accessToken: 'second-token',
  user: User(id: 'second', email: 'second@example.com', displayName: 'Second'),
);

void main() {
  late _MockCredentials credentials;
  late AuthLocalDataSource local;
  late Completer<void> writing;
  late Completer<void> releaseWrite;
  late List<String> writes;
  String? token;

  setUp(() {
    credentials = _MockCredentials();
    local = AuthLocalDataSource(credentials);
    writing = Completer<void>();
    releaseWrite = Completer<void>();
    writes = [];
    token = null;
    when(credentials.read).thenAnswer((_) async => token);
    when(credentials.clear).thenAnswer((_) async => token = null);
    when(() => credentials.write(any())).thenAnswer((invocation) async {
      final value = invocation.positionalArguments.first as String;
      writes.add(value);
      if (value == _first.accessToken) {
        writing.complete();
        await releaseWrite.future;
      }
      token = value;
    });
  });
  tearDown(() async {
    if (!releaseWrite.isCompleted) releaseWrite.complete();
    await local.dispose();
  });

  test('stale write rollback cannot erase a newer committed session', () async {
    final published = <User?>[];
    final subscription = local.sessionChanges.listen(published.add);
    addTearDown(subscription.cancel);
    final first = local.saveSession(_first, revision: local.beginLogin());
    await writing.future;
    final second = local.saveSession(_second, revision: local.beginLogin());
    await Future<void>.delayed(Duration.zero);
    expect(writes, ['first-token']);
    expect(local.currentUser, isNull);
    releaseWrite.complete();
    expect(
      (await first as FailureResult<User>).failure.kind,
      FailureKind.cancelled,
    );
    expect((await second as Success<User>).value, same(_second.user));
    await Future<void>.delayed(Duration.zero);
    expect(published, [_second.user]);
    expect(token, 'second-token');
    expect(local.currentUser, same(_second.user));
  });

  test(
    'queued logout clears the old token before a newer login writes',
    () async {
      final first = local.saveSession(_first, revision: local.beginLogin());
      await writing.future;
      final logout = local.clearSession();
      final second = local.saveSession(_second, revision: local.beginLogin());
      releaseWrite.complete();
      expect(await first, isA<FailureResult<User>>());
      expect(await logout, isA<Success<void>>());
      expect(await second, isA<Success<User>>());
      expect(token, 'second-token');
      expect(local.currentUser, same(_second.user));
    },
  );

  test('a storage failure does not block subsequent session commits', () async {
    when(() => credentials.write(_first.accessToken))
        .thenThrow(StateError('locked'));
    final first = await local.saveSession(_first, revision: local.beginLogin());
    expect((first as FailureResult<User>).failure.kind, FailureKind.storage);
    expect(local.currentUser, isNull);
    final second = await local.saveSession(
      _second,
      revision: local.beginLogin(),
    );
    expect(second, isA<Success<User>>());
    expect(token, 'second-token');
  });

  test(
    'disposal waits for pending rollback and closes session notifications',
    () async {
      final first = local.saveSession(_first, revision: local.beginLogin());
      await writing.future;
      final notifications = expectLater(local.sessionChanges, emitsDone);
      var disposed = false;
      final closing = local.dispose().then((_) => disposed = true);
      await Future<void>.delayed(Duration.zero);
      expect(disposed, isFalse);
      releaseWrite.complete();
      expect(
        (await first as FailureResult<User>).failure.kind,
        FailureKind.cancelled,
      );
      await closing;
      await notifications;
      expect(token, isNull);
      expect(local.currentUser, isNull);
    },
  );
}
