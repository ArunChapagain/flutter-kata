import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/models/models.dart';

void main() {
  group(Country, () {
    test('shows no error before the field has been touched', () {
      const subject = Country.pure();

      expect(subject.isPure, isTrue);
      expect(subject.displayError, isNull);
    });

    test('reports no selection as $CountryValidationError.empty', () {
      expect(
        const Country.dirty().error,
        equals(CountryValidationError.empty),
      );
    });

    test('treats a selection of only whitespace as empty', () {
      expect(
        const Country.dirty('   ').error,
        equals(CountryValidationError.empty),
      );
    });

    test('rejects a name that is not a country', () {
      expect(
        const Country.dirty('Atlantis').error,
        equals(CountryValidationError.unknown),
      );
    });

    test(
      'rejects a real country whose spelling does not match the list, since '
      'the value is picked rather than typed',
      () {
        expect(
          const Country.dirty('nepal').error,
          equals(CountryValidationError.unknown),
        );
      },
    );

    test('is valid once a country from the list is selected', () {
      const subject = Country.dirty('Nepal');

      expect(subject.isValid, isTrue);
      expect(subject.error, isNull);
    });

    test('accepts every country it offers', () {
      for (final country in Countries.all) {
        expect(
          Country.dirty(country).isValid,
          isTrue,
          reason: '"$country" is offered but rejected',
        );
      }
    });
  });
}
