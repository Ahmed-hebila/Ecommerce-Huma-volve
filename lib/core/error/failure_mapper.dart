import '../network/api_exception.dart';
import '../utils/result.dart';
import 'failure.dart';

/// Runs a repository action and converts any thrown error into a [Failure],
/// so the domain and presentation layers never deal with exceptions.
Future<Result<T>> guardResult<T>(Future<T> Function() action) async {
  try {
    return Result.success(await action());
  } on ApiException catch (e) {
    return Result.failure(Failure(e.message, statusCode: e.statusCode));
  } catch (_) {
    // Not `const`: T is a type parameter.
    return Result.failure(const Failure.unexpected());
  }
}
