import 'package:sqflite_common/sqlite_api.dart';

/// The `CREATE TABLE` statement backing the employee resource.
///
/// Every column the brief requires is `NOT NULL`, so an incomplete employee is
/// rejected by the database itself and not only by the Dart constructor.
/// `id` spells out `NOT NULL` because SQLite does not imply it for a
/// non-`INTEGER` primary key.
const _createEmployeesTable = '''
CREATE TABLE employees (
  id                 TEXT    PRIMARY KEY NOT NULL,
  full_name          TEXT    NOT NULL,
  job_title          TEXT    NOT NULL,
  country            TEXT    NOT NULL,
  salary_minor_units INTEGER NOT NULL
)''';

/// {@template sqlite_employee_api}
/// An employee store backed by SQLite.
///
/// The [DatabaseFactory] is injected rather than created, which is what keeps
/// this package free of Flutter: production passes `databaseFactory` from
/// `package:sqflite`, tests pass `databaseFactoryFfi` opened in memory.
/// {@endtemplate}
class SqliteEmployeeApi {
  /// {@macro sqlite_employee_api}
  /// Callers pass `databaseFactory:` and `path:` — the fields stay private.
  SqliteEmployeeApi({
    required this._databaseFactory,
    this._path = 'employees.db',
  });

  final DatabaseFactory _databaseFactory;
  final String _path;

  /// Opens the database, creating the `employees` table on first run.
  ///
  /// Must be awaited before any other method.
  Future<void> open() async {
    await _databaseFactory.openDatabase(
      _path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) => database.execute(
          _createEmployeesTable,
        ),
      ),
    );
  }
}
