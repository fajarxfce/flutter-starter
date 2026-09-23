import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockDemoSessionRepository extends Mock implements DemoSessionRepository {}

void main() {
  const user = User(id: '1', email: 'demo@example.com', displayName: 'Demo');
  late MockAuthRepository repository;
  late MockDemoSessionRepository demo;
  late StreamController<User?> changes;
  late SessionBloc bloc;

  setUp(() {
    repository = MockAuthRepository();
    demo = MockDemoSessionRepository();
    changes = StreamController<User?>.broadcast();
    when(() => repository.sessionChanges).thenAnswer((_) => changes.stream);
    when(repository.restoreSession)
        .thenAnswer((_) async => const Success(null));
    bloc = SessionBloc(
      RestoreSession(repository),
      Logout(repository),
      ExpireDemoSession(demo),
      WatchSession(repository),
      const AppEnvironment(label: 'dev · demo', isDemo: true),
    );
  });
  tearDown(() async {
    await bloc.close();
    await changes.close();
  });

  test('startup failure is exposed as initialized session state', () async {
    when(repository.restoreSession).thenAnswer(
      (_) async => const FailureResult(Failure(FailureKind.network, 'Offline')),
    );
    final ready = bloc.stream.firstWhere((state) => state.initialized);
    bloc.add(const SessionStarted());
    final state = await ready;
    expect(state.isAuthenticated, isFalse);
    expect(state.busy, isFalse);
    expect(state.message, 'Offline');
  });

  test('repository login and logout updates are reflected without widget subscriptions', () async {
    final signedIn = bloc.stream.firstWhere((state) => state.isAuthenticated);
    changes.add(user);
    expect((await signedIn).displayName, 'Demo');
    when(repository.logout).thenAnswer((_) async {
      changes.add(null);
      return const Success(null);
    });
    final signedOut = bloc.stream.firstWhere((state) => !state.isAuthenticated);
    bloc.add(const SessionLogoutRequested());
    await signedOut;
    verify(repository.logout).called(1);
  });

  test('session checking owns loading and success feedback', () async {
    final response = Completer<Result<User?>>();
    when(repository.restoreSession).thenAnswer((_) => response.future);
    final loading = bloc.stream.firstWhere((state) => state.busy);
    bloc.add(const SessionCheckRequested());
    await loading;
    final checked = bloc.stream.firstWhere((state) => !state.busy);
    response.complete(const Success(user));
    expect((await checked).message, 'Your session is up to date.');
    changes.add(user);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.message, 'Your session is up to date.');
  });

  test(
    'demo expiry goes through its use case then verifies the session',
    () async {
      when(demo.expireSession).thenAnswer((_) async => const Success(null));
      when(repository.restoreSession).thenAnswer(
        (_) async => const FailureResult(
          Failure(FailureKind.unauthorized, 'Session expired'),
        ),
      );
      final checked = bloc.stream.firstWhere(
        (state) => state.message == 'Session expired',
      );
      bloc.add(const SessionExpiryRequested());
      expect((await checked).isAuthenticated, isFalse);
      verifyInOrder([demo.expireSession, repository.restoreSession]);
    },
  );

  test(
    'logout storage failure still removes authentication and exposes feedback',
    () async {
      final signedIn = bloc.stream.firstWhere((state) => state.isAuthenticated);
      changes.add(user);
      await signedIn;
      when(repository.logout).thenAnswer(
        (_) async => const FailureResult(
          Failure(FailureKind.storage, 'Cannot clear storage'),
        ),
      );
      final signedOut = bloc.stream.firstWhere(
        (state) => !state.isAuthenticated,
      );
      bloc.add(const SessionLogoutRequested());
      expect((await signedOut).message, 'Cannot clear storage');
    },
  );
}
