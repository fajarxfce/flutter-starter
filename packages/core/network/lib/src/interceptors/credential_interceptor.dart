import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';

final class CredentialInterceptor extends Interceptor {
  CredentialInterceptor(this.credentials, {required String baseUrl})
    : origin = Uri.parse(baseUrl).origin;
  final CredentialStore credentials;
  final String origin;
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Credentials are never attached to login or a different origin.
      if (options.uri.path != '/auth/login' && options.uri.origin == origin) {
        final token = await credentials.read();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } on Object catch (_, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const Failure(
            FailureKind.storage,
            'Unable to access secure storage. Please try again.',
          ),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
