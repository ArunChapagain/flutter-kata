/// Route path constants for the app.
abstract final class Routes {
  /// The employee list (home) screen.
  static const home = '/';

  /// The add-new employee screen (no employee id needed).
  static const upsert = '/upsert';

  /// The edit employee screen — deeplink-safe path with an [employeeId] segment.
  ///
  /// Use [upsertEdit] to build a full path from an id:
  /// ```dart
  /// context.push(Routes.upsertEdit(employee.id));
  /// ```
  static const upsertEditTemplate = '/upsert/:employeeId';

  /// Returns the concrete edit path for the given [employeeId].
  static String upsertEdit(String employeeId) => '/upsert/$employeeId';
}
