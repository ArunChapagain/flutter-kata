import 'package:employee_api/src/employee_api.dart';
import 'package:employee_api/src/employees_table.dart';
import 'package:employee_api/src/exceptions/exceptions.dart';
import 'package:employee_api/src/models/models.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Matches the row whose primary key is the first `whereArg`.
const _whereId = '${EmployeesTable.id} = ?';

/// {@template sqlite_employee_api}
/// An [EmployeeApi] backed by SQLite.
///
/// The [DatabaseFactory] is injected rather than created, which is what keeps
/// this package free of Flutter: production passes `databaseFactory` from
/// `package:sqflite`, tests pass `databaseFactoryFfi` opened in memory.
/// {@endtemplate}
class SqliteEmployeeApi implements EmployeeApi {
  /// {@macro sqlite_employee_api}
  /// Callers pass `databaseFactory:` and `path:` — the fields stay private.
  SqliteEmployeeApi({
    required this._databaseFactory,
    this._path = 'employees.db',
  });

  final DatabaseFactory _databaseFactory;
  final String _path;

  late Database _database;

  /// Creates the `employees` table on first run.
  @override
  Future<void> open() async {
    _database = await _guardStorage(
      () => _databaseFactory.openDatabase(
        _path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) => database.execute(
            EmployeesTable.createStatement,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> create(EmployeeRecord record) async {
    await _guardStorage(
      () => _database.insert(EmployeesTable.name, record.toRow()),
    );
  }

  /// The affected row count is checked outside [_guardStorage], so a missing
  /// id is reported as not-found rather than reclassified as a storage fault.
  @override
  Future<void> update(EmployeeRecord record) async {
    final updated = await _guardStorage(
      () => _database.update(
        EmployeesTable.name,
        record.toRow(),
        where: _whereId,
        whereArgs: [record.id],
      ),
    );

    if (updated == 0) throw const EmployeeNotFoundApiException();
  }

  /// As with [update], the affected row count is checked outside
  /// [_guardStorage].
  @override
  Future<void> delete(String id) async {
    final deleted = await _guardStorage(
      () => _database.delete(
        EmployeesTable.name,
        where: _whereId,
        whereArgs: [id],
      ),
    );

    if (deleted == 0) throw const EmployeeNotFoundApiException();
  }

  /// As with [update], the empty result is checked outside [_guardStorage], so
  /// an id nobody holds is reported as not-found rather than as a fault in the
  /// store.
  ///
  /// `limit: 1` is redundant against a primary key and is passed anyway, so
  /// the query states that exactly one row is wanted.
  @override
  Future<EmployeeRecord> read(String id) async {
    final rows = await _guardStorage(
      () => _database.query(
        EmployeesTable.name,
        where: _whereId,
        whereArgs: [id],
        limit: 1,
      ),
    );

    if (rows.isEmpty) throw const EmployeeNotFoundApiException();

    return EmployeeRecord.fromRow(rows.first);
  }

  @override
  Future<List<EmployeeRecord>> readAll() async {
    final rows = await _guardStorage(
      () => _database.query(EmployeesTable.name),
    );
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

  /// Unguarded: a second `close()` returns normally rather than raising a
  /// [DatabaseException], so there is no failure here to translate.
  @override
  Future<void> close() => _database.close();
}
