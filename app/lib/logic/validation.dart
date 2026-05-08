// local validations
// validation functions must be fast as they are often evaluated on every key press

typedef ValidationFunction<T> = ValidationResult Function(T input);
typedef FutureValidationFunction<T> =
    Future<ValidationResult> Function(T input);

FutureValidationFunction<T> alwaysValid<T>(
  Future<void> Function(T input) callback,
) {
  return (input) async {
    await callback(input);
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
