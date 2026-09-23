import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_presentation/src/home/bloc/home_event.dart';
import 'package:home_presentation/src/home/bloc/home_state.dart';
import 'package:home_presentation/src/home/session/home_session.dart';
import 'package:injectable/injectable.dart';

@injectable
final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._session) : super(_session.state) {
    on<HomeEvent>(_onEvent);
    _subscription = _session.states.listen(
      (state) => add(HomeSessionChanged(state)),
    );
  }

  final HomeSession _session;
  late final StreamSubscription<HomeState> _subscription;

  void _onEvent(HomeEvent event, Emitter<HomeState> emit) {
    switch (event) {
      case HomeSessionCheckRequested():
        _session.check();
      case HomeLogoutRequested():
        _session.logout();
      case HomeSessionExpiryRequested():
        if (state.isDemo) _session.expire();
      case HomeSessionChanged(:final state):
        emit(state);
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
