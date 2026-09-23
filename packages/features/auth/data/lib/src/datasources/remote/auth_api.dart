import 'package:auth_data/src/dto/user_dto.dart';
import 'package:auth_data/src/requests/login_request.dart';
import 'package:auth_data/src/responses/login_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;
  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest request);
  @GET('/auth/me')
  Future<UserDto> me();
}
