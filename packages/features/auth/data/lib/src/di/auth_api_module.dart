import 'package:auth_data/src/datasources/remote/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AuthApiModule {
  @lazySingleton
  AuthApi authApi(Dio dio) => AuthApi(dio);
}
