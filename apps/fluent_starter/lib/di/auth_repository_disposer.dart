import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';

Future<void> disposeRepository(AuthRepository repository) =>
    (repository as RemoteAuthRepository).dispose();
