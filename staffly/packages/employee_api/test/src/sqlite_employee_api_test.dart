import 'package:employee_api/employee_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:test/test.dart';

class _MockDatabaseFactory extends Mock implements DatabaseFactory {}

void main() {
  group(SqliteEmployeeApi, () {
    const record = EmployeeRecord(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salaryMinorUnits: 5000050,
    );

    late DatabaseFactory databaseFactory;
    late Database database;
    late SqliteEmployeeApi subject;

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

      subject = SqliteEmployeeApi(databaseFactory: databaseFactory);
    });

    group('open', () {
      test('creates the employees table with a not-null column per '
          'field the brief requires', () async {
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

    group('create', () {
      test('inserts a record that readAll then returns', () async {
        await subject.open();

        await subject.create(record);

        expect(await subject.readAll(), equals([record]));
      });
    });

    group('readAll', () {
      test('returns an empty list when nothing has been created', () async {
        await subject.open();

        expect(await subject.readAll(), isEmpty);
      });
    });

    group('update', () {
      test(
        'overwrites every field of the record with the matching id',
        () async {
          await subject.open();
          await subject.create(record);

          const promoted = EmployeeRecord(
            id: 'e1b9f0c4',
            fullName: 'Arun Chapagain',
            jobTitle: 'Senior Software Engineer',
            country: 'Netherlands',
            salaryMinorUnits: 7500000,
          );

          await subject.update(promoted);

          expect(await subject.readAll(), equals([promoted]));
        },
      );
    });
  });
}
