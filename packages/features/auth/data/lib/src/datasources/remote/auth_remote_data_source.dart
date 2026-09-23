import 'package:auth_data/src/datasources/remote/auth_api.dart';
import 'package:auth_data/src/dto/user_dto.dart';
import 'package:auth_data/src/requests/login_request.dart';
import 'package:auth_data/src/responses/login_response.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);
  final AuthApi _api;

  Future<LoginResponse> login(LoginRequest request) => _api.login(request);
  Future<UserDto> currentUser() => _api.me();
}
