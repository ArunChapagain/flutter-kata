/// {@template employee_api_exception}
/// The base of every failure this package reports.
///
/// Sealed on purpose: a consumer switching over the subtypes gets
/// exhaustiveness checking from the compiler, so adding a subtype later
/// breaks the build until every handler accounts for it.
/// {@endtemplate}
sealed class EmployeeApiException implements Exception {
  /// {@macro employee_api_exception}
  const EmployeeApiException([this.cause]);

  /// The underlying error this exception was translated from, when there
  /// was one. Kept for logging — never for display.
  final Object? cause;
}

/// {@template employee_not_found_api_exception}
/// Thrown when an operation names an employee id the table does not hold.
/// {@endtemplate}
final class EmployeeNotFoundApiException extends EmployeeApiException {
  /// {@macro employee_not_found_api_exception}
  const EmployeeNotFoundApiException([super.cause]);
}

/// {@template employee_storage_api_exception}
/// Thrown when the underlying SQLite storage fails.
///
/// This is the type a `sqflite` `DatabaseException` becomes, which is what
/// keeps sqflite out of every package downstream of this one.
/// {@endtemplate}
final class EmployeeStorageApiException extends EmployeeApiException {
  /// {@macro employee_storage_api_exception}
  const EmployeeStorageApiException([super.cause]);
}
