/// A readable error returned from the data layer to the presentation layer.
class Failure {
  const Failure(this.message, {this.statusCode});

  const Failure.unexpected()
    : message = 'Something went wrong. Please try again.',
      statusCode = null;

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
