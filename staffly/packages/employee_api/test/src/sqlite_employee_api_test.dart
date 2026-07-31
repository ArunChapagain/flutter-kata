import 'package:employee_api/employee_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:test/test.dart';

class _MockDatabaseFactory extends Mock implements DatabaseFactory {}

void main() {
  group(SqliteEmployeeApi, () {
    late DatabaseFactory databaseFactory;
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      registerFallbackValue(OpenDatabaseOptions());
    });

    setUp(() {
      databaseFactory = _MockDatabaseFactory();

      // Redirects whatever path the subject asks for to a fresh in-memory
      // database, and keeps hold of it so the test can inspect the schema
      // the subject created.
      when(
        () => databaseFactory.openDatabase(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer((invocation) async {
        database = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: invocation.namedArguments[#options] as OpenDatabaseOptions?,
        );
        addTearDown(database.close);
        return database;
      });
    });

    group('open', () {
      test('creates the employees table with a not-null column per '
          'field the brief requires', () async {
        final subject = SqliteEmployeeApi(databaseFactory: databaseFactory);

        await subject.open();

        final columns = await database.rawQuery(
          'PRAGMA table_info(employees)',
        );

        expect(
          columns.map(
            (column) => (
              column['name'],
              column['type'],
              column['notnull'],
              column['pk'],
            ),
          ),
          equals([
            ('id', 'TEXT', 1, 1),
            ('full_name', 'TEXT', 1, 0),
            ('job_title', 'TEXT', 1, 0),
            ('country', 'TEXT', 1, 0),
            ('salary_minor_units', 'INTEGER', 1, 0),
          ]),
        );
      });
    });
  });
}
