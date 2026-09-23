import 'package:auth_domain/auth_domain.dart';

/// Validated login data awaiting local persistence.
final class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final User user;
}
