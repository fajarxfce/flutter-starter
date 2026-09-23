import 'package:auth_presentation/auth_presentation.dart';
import 'package:home_presentation/home_presentation.dart';
import 'package:injectable/injectable.dart';

/// Connects home to auth without a dependency between presentation packages.
@LazySingleton(as: HomeSession)
class AppHomeSession implements HomeSession {
  AppHomeSession(this._session);
  final SessionBloc _session;

  @override
  HomeState get state => _map(_session.state);

  @override
  Stream<HomeState> get states => _session.stream.map(_map);

  @override
  void check() => _session.add(const SessionCheckRequested());

  @override
  void logout() => _session.add(const SessionLogoutRequested());

  @override
  void expire() => _session.add(const SessionExpiryRequested());

  HomeState _map(SessionState state) => HomeState(
    displayName: state.displayName,
    email: state.email,
    environment: state.environment,
    busy: state.busy,
    isDemo: state.isDemo,
    message: state.message,
  );
}
