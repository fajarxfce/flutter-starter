import 'package:core_common/core_common.dart';
import 'package:core_network/src/interceptors/credential_interceptor.dart';
import 'package:core_network/src/interceptors/safe_logging_interceptor.dart';
import 'package:dio/dio.dart';

Dio createDio({
  required String baseUrl,
  required CredentialStore credentials,
  void Function(String message)? log,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(
    CredentialInterceptor(
      credentials: credentials,
      origin: Uri.parse(baseUrl).origin,
    ),
  );
  if (log != null) dio.interceptors.add(SafeLoggingInterceptor(log));
  return dio;
}
