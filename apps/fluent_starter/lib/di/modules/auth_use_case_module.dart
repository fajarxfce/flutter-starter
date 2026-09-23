import 'package:auth_domain/auth_domain.dart';
import 'package:injectable/injectable.dart';

/// Registers domain use cases without importing DI into the domain package.
@module
abstract class AuthUseCaseModule {
  @injectable
  Login login(AuthRepository repository) => Login(repository);

  @injectable
  RestoreSession restoreSession(AuthRepository repository) =>
      RestoreSession(repository);

  @injectable
  Logout logout(AuthRepository repository) => Logout(repository);
}
