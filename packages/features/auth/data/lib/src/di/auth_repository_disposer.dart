import 'package:auth_data/src/repositories/remote_auth_repository.dart';
import 'package:auth_domain/auth_domain.dart';

// Injectable registers the domain interface. Lifecycle stays in the data layer.
Future<void> disposeAuthRepository(AuthRepository repository) =>
    (repository as RemoteAuthRepository).dispose();
