import '../utils/result.dart';

/// Every use case does one job and is called like a function:
/// `await loginUseCase(LoginParams(...))`.
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// For use cases that don't need any input.
class NoParams {
  const NoParams();
}
