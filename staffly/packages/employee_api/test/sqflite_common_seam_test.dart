import 'package:sqflite_common/sqlite_api.dart';
// Only the factory and its initializer come from the ffi package — every type
// below is a sqflite_common type, which is the point of this spike.
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:test/test.dart';

/// Pins the assumption the whole data layer rests on: that this package can
/// speak SQLite through `sqflite_common` types alone, and that a test can
/// substitute an in-memory database for the real one purely by passing a
/// different [DatabaseFactory].
///
/// If this ever fails, `employee_api` cannot stay pure Dart and has to become
/// a Flutter package depending on `package:sqflite` directly.
void main() {
  group('sqflite_common seam', () {
    late DatabaseFactory databaseFactory;

    setUpAll(sqfliteFfiInit);

    setUp(() {
      databaseFactory = databaseFactoryFfi;
    });

    test('opens an in-memory database and round-trips a row', () async {
      final database = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) =>
              db.execute('CREATE TABLE spike (id TEXT PRIMARY KEY NOT NULL)'),
        ),
      );
      addTearDown(database.close);

      await database.insert(
        'spike',
        {'id': 'a'},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      expect(
        await database.query('spike'),
        equals([
          {'id': 'a'},
        ]),
      );
    });

    test('surfaces a $DatabaseException rather than a Flutter-only error', () {
      expect(
        () async {
          final database = await databaseFactory.openDatabase(
            inMemoryDatabasePath,
          );
          addTearDown(database.close);
          await database.query('does_not_exist');
        },
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
