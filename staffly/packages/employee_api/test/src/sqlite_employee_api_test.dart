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

    group('read', () {
      test('returns only the record with the matching id', () async {
        await subject.open();

        // Two records, so a `read` that ignored its argument and returned
        // whatever came back first would still have to pick the right one.
        const colleague = EmployeeRecord(
          id: '7d3a1f52',
          fullName: 'Sam Rai',
          jobTitle: 'Designer',
          country: 'Nepal',
          salaryMinorUnits: 4200000,
        );
        await subject.create(record);
        await subject.create(colleague);

        expect(await subject.read(colleague.id), equals(colleague));
      });

      test(
        'throws $EmployeeNotFoundApiException when no record has that id',
        () async {
          await subject.open();

          await expectLater(
            () => subject.read('no-such-employee'),
            throwsA(isA<EmployeeNotFoundApiException>()),
          );
        },
      );
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

      test(
        'throws $EmployeeNotFoundApiException when no record has that id',
        () async {
          await subject.open();

          const unknown = EmployeeRecord(
            id: 'no-such-employee',
            fullName: 'Nobody',
            jobTitle: 'Ghost',
            country: 'Nepal',
            salaryMinorUnits: 1,
          );

          await expectLater(
            () => subject.update(unknown),
            throwsA(isA<EmployeeNotFoundApiException>()),
          );
        },
      );
    });

    group('delete', () {
      test('removes only the record with the matching id', () async {
        await subject.open();

        const colleague = EmployeeRecord(
          id: '7d3a1f52',
          fullName: 'Sam Rai',
          jobTitle: 'Designer',
          country: 'Nepal',
          salaryMinorUnits: 4200000,
        );
        await subject.create(record);
        await subject.create(colleague);

        await subject.delete(record.id);

        expect(await subject.readAll(), equals([colleague]));
      });

      test(
        'throws $EmployeeNotFoundApiException when no record has that id',
        () async {
          await subject.open();

          await expectLater(
            () => subject.delete('no-such-employee'),
            throwsA(isA<EmployeeNotFoundApiException>()),
          );
        },
      );
    });

    group('close', () {
      test('releases the underlying database', () async {
        await subject.open();

        await subject.close();

        expect(database.isOpen, isFalse);
      });
    });

    group('storage failures', () {
      test(
        'surface as $EmployeeStorageApiException from every method, so no '
        'sqflite $DatabaseException escapes the package',
        () async {
          // The real ffi factory, pointed at a directory that cannot exist.
          final unopenable = SqliteEmployeeApi(
            databaseFactory: databaseFactoryFfi,
            path: '/no/such/directory/employees.db',
          );

          await expectLater(
            unopenable.open,
            throwsA(isA<EmployeeStorageApiException>()),
          );

          // The rest reach sqflite through a database closed underneath
          // them — a real failure that needs no broken file on disk.
          await subject.open();
          await subject.close();

          await expectLater(
            () => subject.create(record),
            throwsA(isA<EmployeeStorageApiException>()),
          );
          await expectLater(
            () => subject.read(record.id),
            throwsA(isA<EmployeeStorageApiException>()),
          );
          await expectLater(
            subject.readAll,
            throwsA(isA<EmployeeStorageApiException>()),
          );
          await expectLater(
            () => subject.update(record),
            throwsA(isA<EmployeeStorageApiException>()),
          );
          await expectLater(
            () => subject.delete(record.id),
            throwsA(isA<EmployeeStorageApiException>()),
          );
        },
      );

      test('keep the underlying sqflite error as their cause', () async {
        await subject.open();
        await subject.close();

        await expectLater(
          subject.readAll,
          throwsA(
            isA<EmployeeStorageApiException>().having(
              (exception) => exception.cause,
              'cause',
              isA<DatabaseException>(),
            ),
          ),
        );
      });
    });
  });
}
