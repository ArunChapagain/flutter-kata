import 'package:equatable/equatable.dart';

/// {@template employee_record}
/// A single row of the `employees` table.
///
/// This is the *storage* shape, not the domain shape — it mirrors the schema
/// column for column. `employee_repository` maps it to an `Employee`.
/// {@endtemplate}
class EmployeeRecord extends Equatable {
  /// {@macro employee_record}
  const EmployeeRecord({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.country,
    required this.salaryMinorUnits,
  });

  /// Creates an [EmployeeRecord] from a `sqflite` result [row].
  ///
  /// Every column is `NOT NULL`, so a missing or mistyped value is a schema
  /// bug rather than a case to tolerate — the casts are meant to throw.
  factory EmployeeRecord.fromRow(Map<String, Object?> row) {
    return EmployeeRecord(
      id: row['id']! as String,
      fullName: row['full_name']! as String,
      jobTitle: row['job_title']! as String,
      country: row['country']! as String,
      salaryMinorUnits: row['salary_minor_units']! as int,
    );
  }

  /// Uniquely identifies the employee.
  final String id;

  /// The employee's full name.
  final String fullName;

  /// The employee's job title.
  final String jobTitle;

  /// The country the employee works from.
  final String country;

  /// The employee's salary in minor units (e.g. paisa).
  final int salaryMinorUnits;

  /// Converts this record into a row for `sqflite` to insert or update.
  Map<String, Object?> toRow() {
    return {
      'id': id,
      'full_name': fullName,
      'job_title': jobTitle,
      'country': country,
      'salary_minor_units': salaryMinorUnits,
    };
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    jobTitle,
    country,
    salaryMinorUnits,
  ];
}
