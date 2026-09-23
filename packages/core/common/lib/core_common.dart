/// Framework-independent contracts shared by all layers.
library;

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}

enum FailureKind { unauthorized, network, timeout, server, storage, unexpected }

final class Failure {
  const Failure(this.kind, this.message);
  final FailureKind kind;
  final String message;
}

abstract interface class CredentialStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

abstract interface class PreferenceStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
