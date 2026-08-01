import 'package:formz/formz.dart';
import 'package:staffly/employees/models/countries.dart';

/// The ways a [Country] can be rejected.
enum CountryValidationError {
  /// No country was selected.
  empty,

  /// The value is not one of the countries on offer.
  unknown,
}

/// {@template country}
/// The country the employee works from.
///
/// Validated by membership of [Countries.all] rather than by a format rule,
/// so the constant that fills the picker is the same one that rejects
/// anything which did not come out of it.
///
/// The match is exact, including case: this field is chosen from, not typed
/// into, so a value that fails to match did not come from the picker and
/// should not be accepted on a guess about what the user meant.
/// {@endtemplate}
class Country extends FormzInput<String, CountryValidationError> {
  /// {@macro country}
  ///
  /// Untouched, so no error is displayed yet.
  const Country.pure() : super.pure('');

  /// {@macro country}
  ///
  /// Selected by the user, so an error is now worth showing.
  const Country.dirty([super.value = '']) : super.dirty();

  @override
  CountryValidationError? validator(String value) {
    if (value.trim().isEmpty) return CountryValidationError.empty;

    return Countries.all.contains(value)
        ? null
        : CountryValidationError.unknown;
  }
}
