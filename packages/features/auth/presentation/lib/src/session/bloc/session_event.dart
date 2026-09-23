import 'package:auth_domain/auth_domain.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionStarted extends SessionEvent {
  const SessionStarted();
}

final class SessionCheckRequested extends SessionEvent {
  const SessionCheckRequested();
}

final class SessionLogoutRequested extends SessionEvent {
  const SessionLogoutRequested();
}

final class SessionExpiryRequested extends SessionEvent {
  const SessionExpiryRequested();
}

final class SessionUserChanged extends SessionEvent {
  const SessionUserChanged(this.user);
  final User? user;
}
