import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/bloc/bloc.dart';

void main() {
  group(EmployeesState, () {
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
      country: 'India',
      salary: Salary(4200000),
    );

    group('visibleEmployees', () {
      test('returns every $Employee when the search query is empty', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
        );

        expect(state.visibleEmployees, equals([arun, sam]));
      });

      test('matches a $Employee whose full name contains the query', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
          searchQuery: 'arun',
        );

        expect(state.visibleEmployees, equals([arun]));
      });

      test('matches a $Employee whose job title contains the query', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
          searchQuery: 'design',
        );

        expect(state.visibleEmployees, equals([sam]));
      });

      test('matches a $Employee whose country contains the query', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
          searchQuery: 'nepal',
        );

        expect(state.visibleEmployees, equals([arun]));
      });

      test('matches regardless of case or surrounding whitespace', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
          searchQuery: '  SAM  ',
        );

        expect(state.visibleEmployees, equals([sam]));
      });

      test('returns an empty list when nothing matches the query', () {
        const state = EmployeesState(
          fetchState: FetchState(employees: [arun, sam]),
          searchQuery: 'atlantis',
        );

        expect(state.visibleEmployees, isEmpty);
      });
    });
  });

  group(DeleteState, () {
    const arun = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(5000050),
    );

    group('copyWith', () {
      test('keeps the status it was not asked to replace', () {
        const state = DeleteState(
          status: DeleteStatus.success,
          deletedEmployee: arun,
        );

        expect(state.copyWith(), equals(state));
      });

      test('replaces only the fields it is given', () {
        const state = DeleteState(deletedEmployee: arun);

        expect(
          state.copyWith(status: DeleteStatus.failure),
          equals(
            const DeleteState(
              status: DeleteStatus.failure,
              deletedEmployee: arun,
            ),
          ),
        );
      });
    });
  });
}
