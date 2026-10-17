import '../error/failure.dart';

/// The result of a repository / use case call: either data or a [Failure].
///
/// ```dart
/// final result = await loginUseCase(params);
/// result.fold(
///   (failure) => emit(LoginFailure(failure.message)),
///   (_) => emit(LoginSuccess()),
/// );
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = SuccessResult<T>;

  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      SuccessResult<T>(:final data) => onSuccess(data),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }
}

final class SuccessResult<T> extends Result<T> {
  const SuccessResult(this.data);

  final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
