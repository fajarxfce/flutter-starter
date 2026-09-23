import 'package:core_common/core_common.dart';
import 'package:core_network/core_network.dart';
import 'package:identity_data/src/datasources/local/auth_local_data_source.dart';
import 'package:identity_data/src/datasources/remote/auth_remote_data_source.dart';
import 'package:identity_data/src/mappers/auth_session_mapper.dart';
import 'package:identity_data/src/mappers/user_mapper.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IdentityRepository)
final class RemoteIdentityRepository implements IdentityRepository {
  RemoteIdentityRepository(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Session get session => _local.session;

  @override
  Stream<Session> get sessionChanges => _local.sessionChanges;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) {
    final revision = _local.beginLogin();
    final request = LoginRequest(email: email, password: password);
    return networkBoundResource(
      fetch: () async => (await _remote.login(request)).toSession(),
      save: (session) => _local.saveSession(session, revision: revision),
    );
  }

  @override
  Future<Result<User?>> restoreSession() async {
    final revision = _local.revision;
    final stored = await _local.hasToken(revision: revision);
    return stored.flatMap((hasToken) async {
      if (!hasToken) return const Success(null);
      final result = await networkBoundResource<User, User?>(
        fetch: () async => (await _remote.currentUser()).toEntity(),
        save: (user) => _local.restoreUser(user, revision: revision),
      );
      if (result case FailureResult<User?>(:final failure)
          when failure.kind == FailureKind.unauthorized) {
        final cleared = await _local.clearIfCurrent(revision: revision);
        return cleared.flatMap((_) => result);
      }
      return result;
    });
  }

  @override
  Future<Result<void>> logout() => _local.clearSession();
}
