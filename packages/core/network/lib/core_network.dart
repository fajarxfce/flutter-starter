import 'package:core_common/core_common.dart';
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
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Credentials are never attached to login or a different origin.
          if (options.path != '/auth/login' &&
              options.uri.origin == Uri.parse(baseUrl).origin) {
            final token = await credentials.read();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          log?.call('HTTP ${options.method}');
          handler.next(options);
        } on Object catch (error) {
          handler.reject(DioException(requestOptions: options, error: error));
        }
      },
      onResponse: (response, handler) {
        log?.call('HTTP ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        // No URL, headers, bodies, tokens, passwords or exception details.
        log?.call(
          'HTTP failure ${error.type.name} ${error.response?.statusCode ?? '-'}',
        );
        handler.next(error);
      },
    ),
  );
  return dio;
}

Failure mapNetworkFailure(Object error) {
  if (error is! DioException) {
    return const Failure(
      FailureKind.unexpected,
      'An unexpected response was received.',
    );
  }
  if (error.response?.statusCode == 401) {
    return const Failure(
      FailureKind.unauthorized,
      'Your credentials or session are no longer valid.',
    );
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const Failure(
      FailureKind.timeout,
      'The request timed out. Please try again.',
    ),
    DioExceptionType.connectionError => const Failure(
      FailureKind.network,
      'Unable to connect. Check your connection.',
    ),
    DioExceptionType.badResponse => const Failure(
      FailureKind.server,
      'The service is unavailable. Please try again.',
    ),
    _ => const Failure(
      FailureKind.unexpected,
      'Something went wrong. Please try again.',
    ),
  };
}
