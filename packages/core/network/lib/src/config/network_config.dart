import 'package:core_common/core_common.dart';

final class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.log,
    this.onFailure,
  });
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final void Function(String message)? log;

  /// Receives final failures and their stack traces; no request/body is passed.
  final void Function(Failure failure, StackTrace stackTrace)? onFailure;
}
