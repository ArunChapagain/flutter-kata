import 'package:formz/formz.dart';

/// The ways a [JobTitle] can be rejected.
enum JobTitleValidationError {
  /// No title was given.
  empty,
}

/// {@template job_title}
/// The employee's job title, as the add/edit form holds it.
/// {@endtemplate}
class JobTitle extends FormzInput<String, JobTitleValidationError> {
  /// {@macro job_title}
  ///
  /// Untouched, so no error is displayed yet.
  const JobTitle.pure() : super.pure('');

  /// {@macro job_title}
  ///
  /// Edited by the user, so an error is now worth showing.
  const JobTitle.dirty([super.value = '']) : super.dirty();

  @override
  JobTitleValidationError? validator(String value) =>
      value.trim().isEmpty ? JobTitleValidationError.empty : null;
}
