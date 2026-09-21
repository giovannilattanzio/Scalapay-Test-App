import 'failure.dart';

/// Outcome of an operation: either a value or a [Failure].
class Result<T> {
  const Result.success(T value) : ok = value, failure = null;

  const Result.error(Failure value) : failure = value, ok = null;

  final T? ok;
  final Failure? failure;

  bool get isSuccess => failure == null;

  bool get isError => failure != null;
}

extension ResultExtension<T> on Result<T> {
  /// Runs [action] when the result is a success.
  void onSuccess(void Function(T value) action) {
    if (isSuccess) action(ok as T);
  }

  /// Runs [action] when the result is an error.
  void onError(void Function(Failure failure) action) {
    if (isError) action(failure!);
  }

  /// Transforms the success value, keeping the failure untouched.
  Result<R> map<R>(R Function(T value) mapper) =>
      isSuccess ? Result.success(mapper(ok as T)) : Result.error(failure!);

  /// Collapses both outcomes into a single value.
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(Failure failure) onError,
  ) => isSuccess ? onSuccess(ok as T) : onError(failure!);
}
