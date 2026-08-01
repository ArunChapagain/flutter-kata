import 'package:staffly/employees/models/country.dart';
import 'package:staffly/employees/models/full_name.dart';
import 'package:staffly/employees/models/job_title.dart';
import 'package:staffly/employees/models/salary_input.dart';
import 'package:staffly/l10n/l10n.dart';

/// Maps formz validation errors to localized, user-facing messages.
///
/// Each helper returns `null` when there is no error (or the input is still
/// pure), which is exactly what `InputDecoration.errorText` expects.
String? fullNameErrorText(
  AppLocalizations l10n,
  FullNameValidationError? error,
) => switch (error) {
  FullNameValidationError.empty => l10n.validationFullNameRequired,
  null => null,
};

String? jobTitleErrorText(
  AppLocalizations l10n,
  JobTitleValidationError? error,
) => switch (error) {
  JobTitleValidationError.empty => l10n.validationJobTitleRequired,
  null => null,
};

String? countryErrorText(
  AppLocalizations l10n,
  CountryValidationError? error,
) => switch (error) {
  CountryValidationError.empty => l10n.validationCountryRequired,
  CountryValidationError.unknown => l10n.validationCountryUnknown,
  null => null,
};

String? salaryErrorText(
  AppLocalizations l10n,
  SalaryValidationError? error,
) => switch (error) {
  SalaryValidationError.empty => l10n.validationSalaryRequired,
  SalaryValidationError.invalid => l10n.validationSalaryInvalid,
  null => null,
};
