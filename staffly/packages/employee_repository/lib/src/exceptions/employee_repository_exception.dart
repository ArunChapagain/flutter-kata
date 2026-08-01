/// {@template employee_repository_exception}
/// The base of every failure this package reports.
///
/// The data layer has its own family of exceptions. This one exists so that
/// none of them escape upwards: everything the api throws is translated here,
/// which is what lets the app depend on `employee_repository` without ever
/// importing `employee_api`.
///
/// Sealed on purpose: a bloc switching over the subtypes to pick a message
/// gets exhaustiveness checking from the compiler, so adding a subtype later
/// breaks the build until every handler accounts for it.
/// {@endtemplate}
sealed class EmployeeRepositoryException implements Exception {
  /// {@macro employee_repository_exception}
  const EmployeeRepositoryException([this.cause]);

  /// The underlying error this exception was translated from, when there
  /// was one. Kept for logging — never for display.
  final Object? cause;
}

/// {@template employee_not_found_exception}
/// Thrown when an operation names an employee the store does not hold.
/// {@endtemplate}
final class EmployeeNotFoundException extends EmployeeRepositoryException {
  /// {@macro employee_not_found_exception}
  const EmployeeNotFoundException([super.cause]);
}

/// {@template employee_storage_exception}
/// Thrown when the underlying store fails.
/// {@endtemplate}
final class EmployeeStorageException extends EmployeeRepositoryException {
  /// {@macro employee_storage_exception}
  const EmployeeStorageException([super.cause]);
}
