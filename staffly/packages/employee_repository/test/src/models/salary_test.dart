import 'package:employee_repository/employee_repository.dart';
import 'package:test/test.dart';

void main() {
  group(Salary, () {
    group('tryParse', () {
      test('returns a $Salary in minor units for a two-decimal amount', () {
        expect(Salary.tryParse('50000.50'), equals(const Salary(5000050)));
      });

      test('returns a $Salary for a whole amount', () {
        expect(Salary.tryParse('50000'), equals(const Salary(5000000)));
      });

      test('pads a single decimal place to two', () {
        expect(Salary.tryParse('50000.5'), equals(const Salary(5000050)));
      });

      test('keeps a zero fraction', () {
        expect(Salary.tryParse('50000.00'), equals(const Salary(5000000)));
      });

      test('returns a $Salary for an amount below one major unit', () {
        expect(Salary.tryParse('0.05'), equals(const Salary(5)));
      });

      test('returns null for more than two decimal places', () {
        expect(Salary.tryParse('50000.505'), isNull);
      });

      test('returns null for a negative amount', () {
        expect(Salary.tryParse('-50000.50'), isNull);
      });

      test('returns null for an empty string', () {
        expect(Salary.tryParse(''), isNull);
      });

      test('returns null for a non-numeric string', () {
        expect(Salary.tryParse('fifty thousand'), isNull);
      });

      // Grouping separators are rejected on the way in, which is precisely why
      // `toEditString` exists alongside `format` — see `toEditString` below.
      test('returns null for a grouped amount', () {
        expect(Salary.tryParse('50,000.50'), isNull);
      });
    });

    group('format', () {
      test('returns a grouped amount with two decimal places', () {
        expect(
          const Salary(5000050).format(locale: 'en_US'),
          equals('50,000.50'),
        );
      });

      test('pads a whole amount to two decimal places', () {
        expect(
          const Salary(5000000).format(locale: 'en_US'),
          equals('50,000'),
        );
      });
    });

    group('toEditString', () {
      test('returns an ungrouped amount with two decimal places', () {
        expect(const Salary(5000050).toEditString(), equals('50000.50'));
      });

      test('pads a whole amount to two decimal places', () {
        expect(const Salary(5000000).toEditString(), equals('50000.00'));
      });
    });
  });
}
