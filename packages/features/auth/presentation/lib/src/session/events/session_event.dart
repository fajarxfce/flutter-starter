import 'package:auth_domain/auth_domain.dart';

part 'session_started.dart';
part 'session_check_requested.dart';
part 'session_logout_requested.dart';
part 'session_expiry_requested.dart';
part 'session_user_changed.dart';

sealed class SessionEvent {
  const SessionEvent();
}
