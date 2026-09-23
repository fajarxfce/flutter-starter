import 'package:dio/dio.dart';

final class SafeLoggingInterceptor extends Interceptor {
  SafeLoggingInterceptor(this.log);
  final void Function(String message) log;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('HTTP ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log('HTTP ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // No URL, headers, bodies, tokens, passwords or exception details.
    log('HTTP failure ${err.type.name} ${err.response?.statusCode ?? '-'}');
    handler.next(err);
  }
}
