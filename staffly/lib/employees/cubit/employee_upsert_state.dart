part of 'employee_upsert_cubit.dart';

/// {@template employee_upsert_state}
/// Everything the add/edit modal needs to render itself.
///
/// The four fields are [FormzInput]s rather than bare strings, so each one
/// carries its own validity *and* whether the user has touched it yet. That
/// second half is what stops the form from announcing "Full name is required"
/// on a field nobody has typed in.
///
/// One class for both adding and editing: the two differ only in whether
/// [initialEmployee] is present, and a second state class would duplicate
/// four inputs and a status to express that one difference.
/// {@endtemplate}
final class EmployeeUpsertState extends Equatable with FormzMixin {
  /// {@macro employee_upsert_state}
  const EmployeeUpsertState({
    this.initialEmployee,
    this.fullName = const FullName.pure(),
    this.jobTitle = const JobTitle.pure(),
    this.country = const Country.pure(),
    this.salary = const SalaryInput.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  /// The employee the form was opened on, or `null` when adding a new one.
  ///
  /// Kept whole rather than as a bare id because submitting an edit means
  /// handing the repository a complete [Employee]: the fields the form does
  /// not show still have to survive the round trip.
  final Employee? initialEmployee;

  /// The employee's full name, as the form holds it.
  final FullName fullName;

  /// The employee's job title, as the form holds it.
  final JobTitle jobTitle;

  /// The country the employee works from, as the form holds it.
  final Country country;

  /// The employee's salary in rupees, as the form holds it.
  final SalaryInput salary;

  /// How far the current submission has got.
  final FormzSubmissionStatus status;

  /// Whether this form is changing an existing employee rather than adding
  /// one.
  bool get isEditing => initialEmployee != null;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// [initialEmployee] is deliberately absent: which employee the form was
  /// opened on is fixed when the modal opens and never changes while it is
  /// open, so there is nothing to replace.
  EmployeeUpsertState copyWith({
    FullName? fullName,
    JobTitle? jobTitle,
    Country? country,
    SalaryInput? salary,
    FormzSubmissionStatus? status,
  }) {
    return EmployeeUpsertState(
      initialEmployee: initialEmployee,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      country: country ?? this.country,
      salary: salary ?? this.salary,
      status: status ?? this.status,
    );
  }

  /// The inputs [isValid] is derived from.
  ///
  /// Listing them here is the whole of the validity rule — there is no
  /// hand-written `isValid` to fall out of step with the fields.
  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    fullName,
    jobTitle,
    country,
    salary,
  ];

  @override
  List<Object?> get props => [
    initialEmployee,
    fullName,
    jobTitle,
    country,
    salary,
    status,
  ];
}
