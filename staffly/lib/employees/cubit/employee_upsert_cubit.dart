import 'package:bloc/bloc.dart';
import 'package:employee_repository/employee_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:staffly/employees/models/models.dart';

part 'employee_upsert_state.dart';

/// {@template employee_upsert_cubit}
/// Owns one add/edit modal — its four fields, their validity, and the write
/// that closes it.
///
/// A cubit rather than a bloc because every transition here is a direct
/// consequence of a user action on a form; there is no event stream worth
/// replaying, and no transformation to apply to one.
///
/// Adding and editing are the same form, told apart by whether an
/// [Employee] was passed in. Editing seeds every field from that employee, so
/// the modal opens filled in and already valid.
///
/// Writes live here rather than on the list bloc so that a submission in
/// flight — or a failed one — cannot disturb the list behind the modal. The
/// list learns about the write by being asked to fetch again once this cubit
/// reports success.
/// {@endtemplate}
class EmployeeUpsertCubit extends Cubit<EmployeeUpsertState> {
  /// {@macro employee_upsert_cubit}
  ///
  /// Pass [initialEmployee] to edit that employee, or leave it out to add a
  /// new one. It arrives whole from the card the user tapped, so the form
  /// opens filled in without a round trip to storage and without a loading
  /// state of its own.
  EmployeeUpsertCubit({
    required this._employeeRepository,
    Employee? initialEmployee,
  }) : super(_openedOn(initialEmployee));

  final EmployeeRepository _employeeRepository;

  static EmployeeUpsertState _openedOn(Employee? employee) {
    if (employee == null) return const EmployeeUpsertState();

    // Dirty, not pure: these values came from storage, so they have been
    // "entered" already and deserve to be validated on sight. Pure inputs
    // would leave the form reporting itself invalid until the user retyped
    // fields that were already correct.
    return EmployeeUpsertState(
      initialEmployee: employee,
      fullName: FullName.dirty(employee.fullName),
      jobTitle: JobTitle.dirty(employee.jobTitle),
      country: Country.dirty(employee.country),
      salary: SalaryInput.dirty(employee.salary.toEditString()),
    );
  }

  /// Records the name currently in the full name field.
  void fullNameChanged(String value) =>
      emit(state.copyWith(fullName: FullName.dirty(value)));

  /// Records the title currently in the job title field.
  void jobTitleChanged(String value) =>
      emit(state.copyWith(jobTitle: JobTitle.dirty(value)));

  /// Records the country currently selected.
  void countryChanged(String value) =>
      emit(state.copyWith(country: Country.dirty(value)));

  /// Records the amount currently in the salary field, in rupees.
  void salaryChanged(String value) =>
      emit(state.copyWith(salary: SalaryInput.dirty(value)));

  /// Writes the form to storage, creating or updating as appropriate.
  Future<void> submitted() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final salary = Salary.fromRupees(state.salary.value)!;

    final fullName = state.fullName.value.trim();
    final jobTitle = state.jobTitle.value.trim();

    try {
      final initialEmployee = state.initialEmployee;

      if (initialEmployee == null) {
        await _employeeRepository.createEmployee(
          fullName: fullName,
          jobTitle: jobTitle,
          country: state.country.value,
          salary: salary,
        );
      } else {
        // copyWith rather than a fresh Employee: the id has to survive, and
        // so does any field a future form does not put on screen.
        await _employeeRepository.updateEmployee(
          initialEmployee.copyWith(
            fullName: fullName,
            jobTitle: jobTitle,
            country: state.country.value,
            salary: salary,
          ),
        );
      }

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on EmployeeRepositoryException {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
