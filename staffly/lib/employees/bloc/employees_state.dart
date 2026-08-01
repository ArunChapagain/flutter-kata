part of 'employees_bloc.dart';

/// Where the employee list currently stands.
enum EmployeesStatus {
  /// Nothing has been asked for yet.
  initial,

  /// A read or a write is in flight.
  loading,

  /// The list reflects storage.
  success,

  /// The last operation failed. Whatever was already loaded is still shown.
  failure,
}

/// {@template employees_state}
/// Everything the employee list screen needs to render itself.
///
/// One class with a [status] rather than a state per phase, because every
/// phase carries the same list: a failed delete still has employees to show,
/// and a reload should not blank the screen it is refreshing.
/// {@endtemplate}
final class EmployeesState extends Equatable {
  /// {@macro employees_state}
  const EmployeesState({
    this.status = EmployeesStatus.initial,
    this.employees = const [],
    this.lastDeletedEmployee,
  });

  /// Where the list currently stands.
  final EmployeesStatus status;

  /// The employees last read from storage, minus any since deleted.
  final List<Employee> employees;

  /// The employee removed by the most recent successful deletion.
  ///
  /// Held so the deletion can be announced — and, eventually, undone.
  final Employee? lastDeletedEmployee;

  /// Returns a copy of this state with the given fields replaced.
  EmployeesState copyWith({
    EmployeesStatus? status,
    List<Employee>? employees,
    Employee? lastDeletedEmployee,
  }) {
    return EmployeesState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      lastDeletedEmployee: lastDeletedEmployee ?? this.lastDeletedEmployee,
    );
  }

  @override
  List<Object?> get props => [status, employees, lastDeletedEmployee];
}
