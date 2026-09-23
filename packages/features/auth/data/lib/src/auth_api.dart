import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });
  final String id;
  final String email;
  final String displayName;
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class LoginRequest {
  const LoginRequest({required this.email, required this.password});
  final String email;
  final String password;
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  checked: true,
  explicitToJson: true,
)
class LoginResponse {
  const LoginResponse({required this.accessToken, required this.user});
  final String accessToken;
  final UserDto user;
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;
  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginRequest request);
  @GET('/auth/me')
  Future<UserDto> me();
}
