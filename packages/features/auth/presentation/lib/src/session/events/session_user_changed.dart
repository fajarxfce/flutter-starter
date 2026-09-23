part of 'session_event.dart';

final class SessionUserChanged extends SessionEvent {
  const SessionUserChanged(this.user);
  final User? user;
}
