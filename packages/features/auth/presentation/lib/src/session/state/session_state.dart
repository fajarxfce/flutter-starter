import 'package:auth_domain/auth_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

@freezed
abstract class SessionState with _$SessionState {
  const SessionState._();
  const factory SessionState({
    @Default(false) bool initialized,
    @Default(false) bool busy,
    @Default('') String environment,
    @Default(false) bool isDemo,
    User? user,
    String? message,
  }) = _SessionState;

  bool get isAuthenticated => user != null;
  String get displayName => user?.displayName ?? '';
  String get email => user?.email ?? '';
}
