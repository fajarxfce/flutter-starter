import 'package:dio/dio.dart';
import 'package:identity_data/src/datasources/remote/auth_api.dart';
import 'package:identity_data/src/dto/user_dto.dart';
import 'package:identity_data/src/requests/login_request.dart';
import 'package:identity_data/src/responses/login_response.dart';
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
