import 'package:employee_repository/src/models/salary.dart';
import 'package:equatable/equatable.dart';

/// {@template employee}
/// An employee, as the rest of the app understands one.
///
/// This is the *domain* shape, not the storage shape. It differs from
/// `employee_api`'s `EmployeeRecord` in exactly one place that matters:
/// [salary] is a [Salary] rather than a bare `int` of paisa, so an amount
/// cannot be read or written without going through the one type that knows
/// how to convert it.
/// {@endtemplate}
class Employee extends Equatable {
  /// {@macro employee}
  const Employee({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.country,
    required this.salary,
  });

  /// Uniquely identifies the employee.
  final String id;

  /// The employee's full name.
  final String fullName;

  /// The employee's job title.
  final String jobTitle;

  /// The country the employee works from.
  final String country;

  /// The employee's salary.
  final Salary salary;

  /// Returns a copy of this employee with the given fields replaced.
  ///
  /// A field left out keeps its current value, which is what lets the upsert
  /// form submit an edit as a change to the employee it started from.
  Employee copyWith({
    String? id,
    String? fullName,
    String? jobTitle,
    String? country,
    Salary? salary,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      country: country ?? this.country,
      salary: salary ?? this.salary,
    );
  }

  @override
  List<Object?> get props => [id, fullName, jobTitle, country, salary];
}
