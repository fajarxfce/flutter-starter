import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';

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
