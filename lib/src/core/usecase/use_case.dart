import 'dart:async';

/// A single business action. One class per action, invoked through [call].
// ignore: one_member_abstracts
abstract class UseCase<T, Params> {
  FutureOr<T> call({required Params params});
}

/// Same as [UseCase] but for actions that emit over time.
// ignore: one_member_abstracts
abstract class StreamUseCase<T, Params> {
  Stream<T> call({required Params params});
}

/// Params for use cases that need no input: `call(params: const NoParams())`.
class NoParams {
  const NoParams();
}
