import 'package:core_common/core_common.dart';
import 'package:core_network/src/config/network_config.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class CredentialInterceptor extends Interceptor {
  CredentialInterceptor(this.credentials, NetworkConfig config)
    : origin = Uri.parse(config.baseUrl).origin;
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
    } on Object catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }
}
