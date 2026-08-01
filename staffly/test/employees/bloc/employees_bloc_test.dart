import 'package:bloc_test/bloc_test.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staffly/employees/bloc/bloc.dart';

class _MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  group(EmployeesBloc, () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    const sam = Employee(
      id: '7d3a1f52',
      fullName: 'Sam Rai',
      jobTitle: 'Designer',
      country: 'Nepal',
      salary: Salary(4200000),
    );

    // Seeded wherever a test needs the list already on screen, so the
    // assertions can speak about what deletion does to it.
    const listed = EmployeesState(
      status: EmployeesStatus.success,
      employees: [arun, sam],
    );

    late EmployeeRepository employeeRepository;

    setUp(() {
      employeeRepository = _MockEmployeeRepository();
    });

    EmployeesBloc buildBloc() =>
        EmployeesBloc(employeeRepository: employeeRepository);

    test('starts out idle, holding no employees', () {
      expect(buildBloc().state, equals(const EmployeesState()));
    });

    group('$EmployeesFetchRequested', () {
      blocTest<EmployeesBloc, EmployeesState>(
        'emits [loading, success] carrying every stored $Employee',
        setUp: () {
          when(
            employeeRepository.fetchEmployees,
          ).thenAnswer((_) async => [arun, sam]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const EmployeesFetchRequested()),
        expect: () => const [
          EmployeesState(status: EmployeesStatus.loading),
          listed,
        ],
        verify: (_) {
          verify(employeeRepository.fetchEmployees).called(1);
        },
      );

      blocTest<EmployeesBloc, EmployeesState>(
        'emits [loading, failure] when the repository throws',
        setUp: () {
          when(
            employeeRepository.fetchEmployees,
          ).thenThrow(const EmployeeStorageException());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const EmployeesFetchRequested()),
        expect: () => const [
          EmployeesState(status: EmployeesStatus.loading),
          EmployeesState(status: EmployeesStatus.failure),
        ],
      );
    });

    group('$EmployeesEmployeeDeleted', () {
      blocTest<EmployeesBloc, EmployeesState>(
        'drops the $Employee from the list and remembers it as the last '
        'deleted one',
        setUp: () {
          when(
            () => employeeRepository.deleteEmployee(any()),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => listed,
        act: (bloc) => bloc.add(const EmployeesEmployeeDeleted(employee: arun)),
        expect: () => const [
          EmployeesState(
            status: EmployeesStatus.success,
            employees: [sam],
            lastDeletedEmployee: arun,
          ),
        ],
        verify: (_) {
          verify(() => employeeRepository.deleteEmployee(arun.id)).called(1);
        },
      );

      blocTest<EmployeesBloc, EmployeesState>(
        'emits failure and leaves the list intact when the repository throws',
        setUp: () {
          when(
            () => employeeRepository.deleteEmployee(any()),
          ).thenThrow(const EmployeeNotFoundException());
        },
        build: buildBloc,
        seed: () => listed,
        act: (bloc) => bloc.add(const EmployeesEmployeeDeleted(employee: arun)),
        expect: () => const [
          EmployeesState(
            status: EmployeesStatus.failure,
            employees: [arun, sam],
          ),
        ],
      );
    });

    group('$EmployeesSearchQueryChanged', () {
      blocTest<EmployeesBloc, EmployeesState>(
        'holds the typed query in state, so $EmployeesState.visibleEmployees '
        'can narrow the list by it',
        build: buildBloc,
        seed: () => listed,
        act: (bloc) =>
            bloc.add(const EmployeesSearchQueryChanged(query: 'sam')),
        expect: () => const [
          EmployeesState(
            status: EmployeesStatus.success,
            employees: [arun, sam],
            searchQuery: 'sam',
          ),
        ],
      );
    });
  });
}
