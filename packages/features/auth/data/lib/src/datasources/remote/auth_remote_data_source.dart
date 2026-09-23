import 'package:auth_data/src/datasources/remote/auth_api.dart';
import 'package:auth_data/src/dto/user_dto.dart';
import 'package:auth_data/src/requests/login_request.dart';
import 'package:auth_data/src/responses/login_response.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);
  final AuthApi _api;

  Future<LoginResponse> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) => _api.login(request, cancelToken: cancelToken);
  Future<UserDto> currentUser({CancelToken? cancelToken}) =>
      _api.me(cancelToken: cancelToken);
}
