import 'package:employee_repository/employee_repository.dart';

/// Route path constants for the app.
abstract final class Routes {
  /// The employee list (home) screen.
  static const home = '/';

  /// The add/edit employee screen.
  ///
  /// Pass an [Employee] via `extra` to edit; omit for creating.
  static const upsert = '/upsert';
}
