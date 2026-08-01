import 'package:employee_repository/employee_repository.dart';
import 'package:formz/formz.dart';

/// The ways a [SalaryInput] can be rejected.
enum SalaryValidationError {
  /// No amount was given.
  empty,

  /// The amount is not a well-formed number of rupees.
  invalid,
}

/// {@template salary_input}
/// The employee's salary in rupees, as the add/edit form holds it.
///
/// Holds a `String` rather than a [Salary] because a `String` is what the
/// text field holds; the crossing into paisa happens once, on submit.
///
/// The format rule is delegated to [Salary.fromRupees] rather than restated
/// here. The domain owns what a valid amount is and this class owns only the
/// form's state machine — restating the rule would give the app two
/// definitions of a valid salary, free to drift apart.
/// {@endtemplate}
class SalaryInput extends FormzInput<String, SalaryValidationError> {
  /// {@macro salary_input}
  ///
  /// Untouched, so no error is displayed yet.
  const SalaryInput.pure() : super.pure('');

  /// {@macro salary_input}
  ///
  /// Edited by the user, so an error is now worth showing.
  const SalaryInput.dirty([super.value = '']) : super.dirty();

  @override
  SalaryValidationError? validator(String value) {
    if (value.trim().isEmpty) return SalaryValidationError.empty;

    // Deliberately the untrimmed value. Whatever passes here is exactly the
    // string the cubit hands to fromRupees on submit, so a value cannot
    // validate and then fail to parse.
    return Salary.fromRupees(value) == null
        ? SalaryValidationError.invalid
        : null;
  }
}
