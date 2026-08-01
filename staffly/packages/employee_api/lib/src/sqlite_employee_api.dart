import 'package:employee_api/src/exceptions/exceptions.dart';
import 'package:employee_api/src/models/models.dart';
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

  late Database _database;

  /// Opens the database, creating the `employees` table on first run.
  ///
  /// Must be awaited before any other method.
  ///
  /// Throws an [EmployeeStorageApiException] if the database cannot be opened.
  Future<void> open() async {
    _database = await _guardStorage(
      () => _databaseFactory.openDatabase(
        _path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) => database.execute(
            _createEmployeesTable,
          ),
        ),
      ),
    );
  }

  /// Inserts [record] into the `employees` table.
  ///
  /// Throws an [EmployeeStorageApiException] if the insert fails.
  Future<void> create(EmployeeRecord record) async {
    await _guardStorage(() => _database.insert('employees', record.toRow()));
  }

  /// Overwrites the stored employee whose id matches [record]'s.
  ///
  /// Throws an [EmployeeNotFoundApiException] if no row has that id, and an
  /// [EmployeeStorageApiException] if the update fails.
  Future<void> update(EmployeeRecord record) async {
    final updated = await _guardStorage(
      () => _database.update(
        'employees',
        record.toRow(),
        where: 'id = ?',
        whereArgs: [record.id],
      ),
    );

    if (updated == 0) throw const EmployeeNotFoundApiException();
  }

  /// Removes the stored employee with the given [id].
  ///
  /// Throws an [EmployeeNotFoundApiException] if no row has that id, and an
  /// [EmployeeStorageApiException] if the delete fails.
  Future<void> delete(String id) async {
    final deleted = await _guardStorage(
      () => _database.delete(
        'employees',
        where: 'id = ?',
        whereArgs: [id],
      ),
    );

    if (deleted == 0) throw const EmployeeNotFoundApiException();
  }

  /// Returns every stored employee.
  ///
  /// Throws an [EmployeeStorageApiException] if the query fails.
  Future<List<EmployeeRecord>> readAll() async {
    final rows = await _guardStorage(() => _database.query('employees'));
    return rows.map(EmployeeRecord.fromRow).toList();
  }

  /// Runs [action], translating any `sqflite` failure into an
  /// [EmployeeStorageApiException].
  ///
  /// This is the single place that catches [DatabaseException], and the
  /// reason no `sqflite` type reaches `employee_repository` or the app. The
  /// original error is kept as `cause` and the original stack trace is
  /// rethrown with it, so nothing is lost to the logs.
  Future<T> _guardStorage<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        EmployeeStorageApiException(error),
        stackTrace,
      );
    }
  }

  /// Releases the database. No other method may be called afterwards.
  Future<void> close() => _database.close();
}
