import 'package:formz/formz.dart';

/// The ways a [FullName] can be rejected.
enum FullNameValidationError {
  /// No name was given.
  empty,
}

/// {@template full_name}
/// The employee's full name, as the add/edit form holds it.
///
/// Being a plain Dart object rather than a rule inside a
/// `TextFormField.validator` is the point: validity is assertable without
/// pumping a widget, so the rule earns its own fast test.
/// {@endtemplate}
class FullName extends FormzInput<String, FullNameValidationError> {
  /// {@macro full_name}
  ///
  /// Untouched, so nothing is wrong with it yet as far as the user is
  /// concerned — `displayError` stays null however invalid the value is.
  const FullName.pure() : super.pure('');

  /// {@macro full_name}
  ///
  /// Edited by the user, so an error is now worth showing.
  const FullName.dirty([super.value = '']) : super.dirty();

  @override
  FullNameValidationError? validator(String value) =>
      value.trim().isEmpty ? FullNameValidationError.empty : null;
}
