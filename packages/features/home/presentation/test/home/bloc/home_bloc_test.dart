import 'package:flutter_test/flutter_test.dart';
import 'package:home_presentation/home_presentation.dart';

import '../../support/fake_home_session.dart';

void main() {
  test(
    'reads the current session and follows subsequent state changes',
    () async {
      const initial = HomeState(displayName: 'Alex', email: 'alex@example.com');
      final session = FakeHomeSession(initial);
      final bloc = HomeBloc(session);
      addTearDown(session.close);
      addTearDown(bloc.close);
      expect(bloc.state, initial);

      final checking = initial.copyWith(busy: true);
      final checked = initial.copyWith(message: 'Session checked');
      const cleared = HomeState();
      final updates = expectLater(
        bloc.stream,
        emitsInOrder([checking, checked, cleared]),
      );
      session.update(checking);
      session.update(checked);
      session.update(cleared);
      await updates;
    },
  );

  test(
    'forwards session actions and blocks expiry outside demo mode',
    () async {
      final session = FakeHomeSession();
      final bloc = HomeBloc(session);
      addTearDown(session.close);
      addTearDown(bloc.close);
      bloc
        ..add(const HomeSessionCheckRequested())
        ..add(const HomeLogoutRequested())
        ..add(const HomeSessionExpiryRequested());
      await pumpEventQueue();
      expect(session.actions, ['check', 'logout']);

      final demo = bloc.stream.firstWhere((state) => state.isDemo);
      session.update(const HomeState(isDemo: true));
      await demo;
      bloc.add(const HomeSessionExpiryRequested());
      await pumpEventQueue();
      expect(session.actions, ['check', 'logout', 'expire']);
    },
  );

  test('closing a route Bloc releases its session subscription', () async {
    final session = FakeHomeSession();
    addTearDown(session.close);
    final bloc = HomeBloc(session);
    expect(session.hasListener, isTrue);
    await bloc.close();
    expect(session.hasListener, isFalse);
    session.update(const HomeState(displayName: 'Another user'));
    expect(bloc.state.displayName, isEmpty);
  });
}
