import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

Failure mapNetworkFailure(Object error) {
  if (error is DioException) {
    // Interceptors can preserve failures from local infrastructure.
    if (error.error case Failure failure) return failure;
    if (error.type == DioExceptionType.cancel) {
      return const Failure(FailureKind.cancelled, 'The request was cancelled.');
    }
    if (error.type == DioExceptionType.badCertificate) {
      return const Failure(
        FailureKind.network,
        'A secure connection could not be established.',
      );
    }
    final statusFailure = switch (error.response?.statusCode) {
      400 || 422 => const Failure(
        FailureKind.validation,
        'The submitted information was rejected.',
      ),
      401 => const Failure(
        FailureKind.unauthorized,
        'Your credentials or session are no longer valid.',
      ),
      403 => const Failure(
        FailureKind.forbidden,
        'You do not have permission to perform this action.',
      ),
      404 => const Failure(
        FailureKind.notFound,
        'The requested resource was not found.',
      ),
      408 => const Failure(
        FailureKind.timeout,
        'The request timed out. Please try again.',
      ),
      409 => const Failure(
        FailureKind.conflict,
        'The resource changed. Refresh and try again.',
      ),
      429 => const Failure(
        FailureKind.rateLimited,
        'Too many requests. Please try again later.',
      ),
      int status when status >= 500 && status <= 599 => const Failure(
        FailureKind.server,
        'The service is unavailable. Please try again.',
      ),
      _ => null,
    };
    if (statusFailure != null) return statusFailure;
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
      _ => _responseFailure(error.error ?? error),
    };
  }
  return _responseFailure(error);
}

Failure _responseFailure(Object error) => switch (error) {
  FormatException() ||
  CheckedFromJsonException() ||
  TypeError() => const Failure(
    FailureKind.invalidResponse,
    'The service returned an invalid response.',
  ),
  TimeoutException() => const Failure(
    FailureKind.timeout,
    'The request timed out. Please try again.',
  ),
  _ => const Failure(
    FailureKind.unexpected,
    'Something went wrong. Please try again.',
  ),
};
