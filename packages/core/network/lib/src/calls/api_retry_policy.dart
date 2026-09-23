import 'dart:math';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

/// Bounded retries for GET/HEAD/OPTIONS. The operation must be replayable.
final class ApiRetryPolicy {
  const ApiRetryPolicy.none()
    : maxAttempts = 1,
      initialDelay = Duration.zero,
      maxDelay = Duration.zero;

  factory ApiRetryPolicy.readOnly({
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 200),
    Duration maxDelay = const Duration(seconds: 2),
  }) {
    if (maxAttempts < 1 || maxAttempts > 10) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'Must be 1 to 10');
    }
    if (initialDelay.isNegative ||
        maxDelay < initialDelay ||
        maxDelay > const Duration(minutes: 1)) {
      throw ArgumentError('Require 0 <= initialDelay <= maxDelay <= 1 minute');
    }
    return ApiRetryPolicy._(maxAttempts, initialDelay, maxDelay);
  }

  const ApiRetryPolicy._(this.maxAttempts, this.initialDelay, this.maxDelay);

  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  static final _random = Random();

  /// Returns null when the error must be surfaced instead of replaying the call.
  Duration? delayAfter(Object error, int failedAttempts) {
    if (failedAttempts < 1 ||
        failedAttempts >= maxAttempts ||
        error is! DioException ||
        !{
          'GET',
          'HEAD',
          'OPTIONS',
        }.contains(error.requestOptions.method.toUpperCase())) {
      return null;
    }
    final transient = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => {
        408,
        429,
        502,
        503,
        504,
      }.contains(error.response?.statusCode),
      _ => false,
    };
    if (!transient) return null;

    final ceiling = min(
      initialDelay.inMicroseconds * (1 << (failedAttempts - 1)),
      maxDelay.inMicroseconds,
    );
    // Equal jitter avoids synchronized retries while keeping a minimum delay.
    var delay = Duration(
      microseconds: (ceiling * (0.5 + _random.nextDouble() / 2)).round(),
    );
    final header = error.response?.headers['retry-after']?.firstOrNull;
    final retryAfter = _retryAfter(header);
    // Never retry earlier than requested by the server to fit our delay budget.
    if (retryAfter != null) {
      if (retryAfter > maxDelay) return null;
      if (retryAfter > delay) delay = retryAfter;
    }
    return delay;
  }

  Duration? _retryAfter(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    final seconds = int.tryParse(trimmed);
    if (seconds == null && RegExp(r'^\d+$').hasMatch(trimmed)) {
      return maxDelay + const Duration(seconds: 1);
    }
    if (seconds != null) {
      if (seconds < 0) return null;
      // Compare before converting to microseconds to avoid oversized durations.
      if (seconds > maxDelay.inSeconds) {
        return maxDelay + const Duration(seconds: 1);
      }
      return Duration(seconds: seconds);
    }
    try {
      final delay = parseHttpDate(value).difference(DateTime.now().toUtc());
      return delay.isNegative ? Duration.zero : delay;
    } on FormatException {
      return null;
    }
  }
}
