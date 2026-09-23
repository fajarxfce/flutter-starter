import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_network/src/calls/api_retry_policy.dart';
import 'package:core_network/src/config/network_config.dart';
import 'package:core_network/src/mappers/network_failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Exception boundary for transport, decoding and DTO-to-domain mapping.
@lazySingleton
final class SafeApiCall {
  SafeApiCall(this._config);
  final NetworkConfig _config;

  static const _cancelled = Failure(
    FailureKind.cancelled,
    'The request was cancelled.',
  );

  /// Forward the supplied token to Dio/Retrofit to abort the underlying request.
  /// Retried callbacks must contain only replayable reads and pure mapping.
  Future<Result<T>> call<T>(
    FutureOr<T> Function(CancelToken token) operation, {
    CancelToken? cancelToken,
    ApiRetryPolicy retry = const ApiRetryPolicy.none(),
  }) async {
    final token = cancelToken ?? CancelToken();
    var attempts = 0;
    while (true) {
      if (token.isCancelled) {
        _report(_cancelled, StackTrace.current);
        return const FailureResult(_cancelled);
      }
      attempts++;
      try {
        final value = await Future.any<T>([
          Future<T>.sync(() => operation(token)),
          token.whenCancel.then<T>((error) => throw error),
        ]);
        if (token.isCancelled) {
          _report(_cancelled, StackTrace.current);
          return const FailureResult(_cancelled);
        }
        return Success(value);
      } on Object catch (error, stackTrace) {
        final failure = token.isCancelled
            ? _cancelled
            : mapNetworkFailure(error);
        final delay = token.isCancelled
            ? null
            : retry.delayAfter(error, attempts);
        if (delay == null) {
          _report(failure, stackTrace);
          return FailureResult(failure);
        }
        await _wait(delay, token);
      }
    }
  }

  Future<void> _wait(Duration duration, CancelToken token) async {
    final elapsed = Completer<void>();
    final timer = Timer(duration, elapsed.complete);
    try {
      await Future.any<void>([
        elapsed.future,
        token.whenCancel.then<void>((_) {}),
      ]);
    } finally {
      timer.cancel();
    }
  }

  void _report(Failure failure, StackTrace stackTrace) {
    try {
      _config.onFailure?.call(failure, stackTrace);
    } on Object {
      // Observability must not replace the original operation result.
    }
  }
}
