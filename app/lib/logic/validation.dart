// local validations
// validation functions must be fast as they are often evaluated on every key press

typedef ValidationFunction<T> = Future<ValidationResult> Function(T input);

ValidationFunction<T> alwaysValid<T>(Function(T input) callback) {
  return (input) async {
    callback(input);
    return ValidResult();
  };
}

sealed class ValidationResult {
  String? get errorMessage => switch (this) {
    ValidResult() => null,
    InvalidResult(errorMessage: final m) => m,
  };

  bool get isValid => this is ValidResult;
}

class ValidResult extends ValidationResult {}

class InvalidResult extends ValidationResult {
  @override
  final String? errorMessage;

  InvalidResult({required this.errorMessage});
}
