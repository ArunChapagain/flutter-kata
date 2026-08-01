import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/bloc/bloc.dart';

void main() {
  group(EmployeesEvent, () {
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

    // Read through `props` rather than by comparing two equal instances:
    // these events are const, so any two equal ones are canonicalised to the
    // same object and `==` would short-circuit on identity without ever
    // consulting the value equality under test.
    test('gives $EmployeesFetchRequested nothing to compare but its type', () {
      expect(const EmployeesFetchRequested().props, isEmpty);
    });

    test(
      'compares an $EmployeesEmployeeDeleted by the $Employee it carries',
      () {
        expect(
          const EmployeesEmployeeDeleted(employee: arun).props,
          equals([arun]),
        );
        expect(
          const EmployeesEmployeeDeleted(employee: arun),
          isNot(equals(const EmployeesEmployeeDeleted(employee: sam))),
        );
      },
    );
  });
}
