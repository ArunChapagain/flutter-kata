import 'package:employee_repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/models/models.dart';

void main() {
  group(SalaryInput, () {
    test('shows no error before the field has been touched', () {
      const subject = SalaryInput.pure();

      expect(subject.isPure, isTrue);
      expect(subject.displayError, isNull);
    });

    test('reports an empty amount as $SalaryValidationError.empty', () {
      expect(
        const SalaryInput.dirty().error,
        equals(SalaryValidationError.empty),
      );
    });

    test('treats an amount of only whitespace as empty', () {
      expect(
        const SalaryInput.dirty('   ').error,
        equals(SalaryValidationError.empty),
      );
    });

    test(
      'defers the format rule to $Salary rather than restating it, so a '
      'malformed amount is $SalaryValidationError.invalid',
      () {
        // Every one of these is rejected by Salary.fromRupees. The input
        // reports them without knowing why any of them is wrong.
        const malformed = ['abc', '-1', '50.123', '50,000', '1.2.3', '5 0'];

        for (final rupees in malformed) {
          expect(
            SalaryInput.dirty(rupees).error,
            equals(SalaryValidationError.invalid),
            reason: '"$rupees" is not a well-formed amount',
          );
        }
      },
    );

    test('is valid for any amount $Salary can parse', () {
      const wellFormed = ['50000', '50000.50', '500.7', '0', '1234567.89'];

      for (final rupees in wellFormed) {
        final subject = SalaryInput.dirty(rupees);

        expect(subject.isValid, isTrue, reason: '"$rupees" should parse');
        expect(subject.error, isNull);
      }
    });
  });
}
