import 'package:employee_api/employee_api.dart';
import 'package:test/test.dart';

void main() {
  group(EmployeeRecord, () {
    const record = EmployeeRecord(
      id: 'e1b9f0c4',
      fullName: 'Arun Chapagai',
      jobTitle: 'Software Engineer',
      country: 'Nepal',
      salaryMinorUnits: 5000050,
    );

    const row = <String, Object?>{
      'id': 'e1b9f0c4',
      'full_name': 'Arun Chapagai',
      'job_title': 'Software Engineer',
      'country': 'Nepal',
      'salary_minor_units': 5000050,
    };

    group('toRow', () {
      test('returns a map keyed by the employees table columns', () {
        expect(record.toRow(), equals(row));
      });
    });

    group('fromRow', () {
      test('returns an equivalent $EmployeeRecord', () {
        expect(EmployeeRecord.fromRow(row), equals(record));
      });
    });

    test('round-trips through a row without losing a field', () {
      expect(EmployeeRecord.fromRow(record.toRow()), equals(record));
    });
  });
}
