import 'package:employee_repository/employee_repository.dart';
import 'package:test/test.dart';

void main() {
  group(Employee, () {
    const employee = Employee(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salary: Salary(9000050),
    );

    test('supports value equality', () {
      expect(
        employee,
        equals(
          const Employee(
            id: 'e1b9f0c4',
            fullName: 'Arun Chapagai',
            jobTitle: 'Software Engineer',
            country: 'Nepal',
            salary: Salary(9000050),
          ),
        ),
      );
    });

    test('is not equal to an $Employee whose salary differs', () {
      expect(
        employee,
        isNot(
          equals(
            const Employee(
              id: 'e1b9f0c4',
              fullName: 'Arun Chapagai',
              jobTitle: 'Software Engineer',
              country: 'Nepal',
              salary: Salary(6000000),
            ),
          ),
        ),
      );
    });

    group('copyWith', () {
      test('returns an equal $Employee when given no field', () {
        expect(employee.copyWith(), equals(employee));
      });

      test('replaces every field it is given', () {
        expect(
          employee.copyWith(
            id: 'a2c8d1e5',
            fullName: 'Sita Sharma',
            jobTitle: 'Product Designer',
            country: 'India',
            salary: const Salary(7500000),
          ),
          equals(
            const Employee(
              id: 'a2c8d1e5',
              fullName: 'Sita Sharma',
              jobTitle: 'Product Designer',
              country: 'India',
              salary: Salary(7500000),
            ),
          ),
        );
      });

      test('leaves the fields it is not given alone', () {
        expect(
          employee.copyWith(salary: const Salary(6000000)),
          equals(
            const Employee(
              id: 'e1b9f0c4',
              fullName: 'Arun Chapagai',
              jobTitle: 'Software Engineer',
              country: 'Nepal',
              salary: Salary(6000000),
            ),
          ),
        );
      });
    });
  });
}
