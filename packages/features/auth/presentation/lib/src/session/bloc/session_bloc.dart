import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/session/events/session_event.dart';
import 'package:auth_presentation/src/session/state/session_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(
    this._restore,
    this._logout,
    this._expire,
    WatchSession watch,
    AppEnvironment environment,
  ) : super(
        SessionState(
          environment: environment.label,
          isDemo: environment.isDemo,
        ),
      ) {
    on<SessionEvent>(_onEvent, transformer: sequential());
    _subscription = watch().listen((user) => add(SessionUserChanged(user)));
  }

  final RestoreSession _restore;
  final Logout _logout;
  final ExpireDemoSession _expire;
  late final StreamSubscription<User?> _subscription;

  Future<void> _onEvent(SessionEvent event, Emitter<SessionState> emit) async {
    switch (event) {
      case SessionStarted():
        await _restoreSession(emit, showSuccess: false);
      case SessionCheckRequested():
        await _restoreSession(emit, showSuccess: true);
      case SessionLogoutRequested():
        emit(state.copyWith(busy: true));
        final result = await _logout();
        emit(
          state.copyWith(
            busy: false,
            user: null,
            message: switch (result) {
              FailureResult<void>(:final failure) => failure.message,
              Success<void>() => null,
            },
          ),
        );
      case SessionExpiryRequested():
        if (!state.isDemo) return;
        emit(state.copyWith(busy: true));
        final result = await _expire();
        if (result case FailureResult<void>(:final failure)) {
          emit(state.copyWith(busy: false, message: failure.message));
          return;
        }
        await _restoreSession(emit, showSuccess: false);
      case SessionUserChanged(:final user):
        emit(
          state.copyWith(
            user: user,
            message: !state.isAuthenticated && user != null
                ? null
                : state.message,
          ),
        );
    }
  }

  Future<void> _restoreSession(
    Emitter<SessionState> emit, {
    required bool showSuccess,
  }) async {
    emit(state.copyWith(busy: true));
    final result = await _restore();
    switch (result) {
      case Success<User?>(:final value):
        emit(
          state.copyWith(
            initialized: true,
            busy: false,
            user: value,
            message: showSuccess ? 'Your session is up to date.' : null,
          ),
        );
      case FailureResult<User?>(:final failure):
        emit(
          state.copyWith(
            initialized: true,
            busy: false,
            user: failure.kind == FailureKind.unauthorized ? null : state.user,
            message: failure.message,
          ),
        );
    }
  }

  @override
  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
