import 'package:employee_api/employee_api.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockEmployeeApi extends Mock implements EmployeeApi {}

void main() {
  group(EmployeeRepository, () {
    const id = 'e1b9f0c4';

    const record = EmployeeRecord(
      id: id,
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salaryMinorUnits: 5000050,
    );

    const employee = Employee(
      id: id,
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    late EmployeeApi employeeApi;
    late EmployeeRepository subject;

    setUpAll(() {
      registerFallbackValue(record);
    });

    setUp(() {
      employeeApi = _MockEmployeeApi();
      subject = EmployeeRepository(
        employeeApi: employeeApi,
        idGenerator: () => id,
      );
    });

    group('fetchEmployees', () {
      test(
        'returns an $Employee per stored record, reading the paisa column '
        'back as a $Salary',
        () async {
          const colleague = EmployeeRecord(
            id: '7d3a1f52',
            fullName: 'Sam Rai',
            jobTitle: 'Designer',
            country: 'Nepal',
            salaryMinorUnits: 4200000,
          );
          when(
            employeeApi.readAll,
          ).thenAnswer((_) async => [record, colleague]);

          expect(
            await subject.fetchEmployees(),
            equals([
              employee,
              const Employee(
                id: '7d3a1f52',
                fullName: 'Sam Rai',
                jobTitle: 'Designer',
                country: 'Nepal',
                salary: Salary(4200000),
              ),
            ]),
          );
        },
      );
    });

    group('createEmployee', () {
      test(
        'returns the created $Employee, identified by the generator',
        () async {
          when(() => employeeApi.create(any())).thenAnswer((_) async {});

          final created = await subject.createEmployee(
            fullName: 'Arun Chapagai',
            jobTitle: 'Software Engineer',
            country: 'Nepal',
            salary: const Salary(5000050),
          );

          expect(created, equals(employee));
        },
      );

      test('stores it as a record, with the salary written as paisa', () async {
        when(() => employeeApi.create(any())).thenAnswer((_) async {});

        await subject.createEmployee(
          fullName: 'Arun Chapagai',
          jobTitle: 'Software Engineer',
          country: 'Nepal',
          salary: const Salary(5000050),
        );

        verify(() => employeeApi.create(record)).called(1);
      });

      test(
        'identifies employees uniquely when no generator is injected',
        () async {
          when(() => employeeApi.create(any())).thenAnswer((_) async {});
          final defaultingSubject = EmployeeRepository(
            employeeApi: employeeApi,
          );

          final first = await defaultingSubject.createEmployee(
            fullName: 'Arun Chapagai',
            jobTitle: 'Software Engineer',
            country: 'Nepal',
            salary: const Salary(5000050),
          );
          final second = await defaultingSubject.createEmployee(
            fullName: 'Sam Rai',
            jobTitle: 'Designer',
            country: 'Nepal',
            salary: const Salary(4200000),
          );

          expect(first.id, isNotEmpty);
          expect(second.id, isNot(equals(first.id)));
        },
      );
    });

    group('updateEmployee', () {
      const promoted = Employee(
        id: id,
        fullName: 'Arun Chapagain',
        jobTitle: 'Senior Software Engineer',
        country: 'Netherlands',
        salary: Salary(7500000),
      );

      test('returns the $Employee it was given', () async {
        when(() => employeeApi.update(any())).thenAnswer((_) async {});

        expect(await subject.updateEmployee(promoted), equals(promoted));
      });

      test('hands it to the api as a record, keeping its own id', () async {
        when(() => employeeApi.update(any())).thenAnswer((_) async {});

        await subject.updateEmployee(promoted);

        verify(
          () => employeeApi.update(
            const EmployeeRecord(
              id: id,
              fullName: 'Arun Chapagain',
              jobTitle: 'Senior Software Engineer',
              country: 'Netherlands',
              salaryMinorUnits: 7500000,
            ),
          ),
        ).called(1);
      });
    });

    group('deleteEmployee', () {
      test('removes the employee with the given id', () async {
        when(() => employeeApi.delete(any())).thenAnswer((_) async {});

        await subject.deleteEmployee(id);

        verify(() => employeeApi.delete(id)).called(1);
      });
    });
  });
}
