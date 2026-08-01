import 'package:employee_repository/employee_repository.dart';
import 'package:test/test.dart';

void main() {
  group(Salary, () {
    group('fromRupees', () {
      test('converts rupees to paisa for a two-decimal amount', () {
        expect(Salary.fromRupees('50000.50'), equals(const Salary(5000050)));
      });

      test('converts a whole number of rupees', () {
        expect(Salary.fromRupees('50000'), equals(const Salary(5000000)));
      });

      test('reads a single decimal place as tens of paisa', () {
        expect(Salary.fromRupees('500.7'), equals(const Salary(50070)));
      });

      test('keeps a zero paisa fraction', () {
        expect(Salary.fromRupees('50000.00'), equals(const Salary(5000000)));
      });

      test('converts an amount below one rupee', () {
        expect(Salary.fromRupees('0.05'), equals(const Salary(5)));
      });

      test('returns null for a fraction finer than one paisa', () {
        expect(Salary.fromRupees('50000.505'), isNull);
      });

      test('returns null for a negative amount', () {
        expect(Salary.fromRupees('-50000.50'), isNull);
      });

      test('returns null for an empty string', () {
        expect(Salary.fromRupees(''), isNull);
      });

      test('returns null for a non-numeric string', () {
        expect(Salary.fromRupees('fifty thousand'), isNull);
      });

      // Grouping separators are rejected on the way in, which is why `format`
      // and `toEditString` are separate outbound forms: only the latter is
      // safe to seed a text field with.
      test('returns null for a grouped amount', () {
        expect(Salary.fromRupees('50,000.50'), isNull);
      });
    });

    group('toPaisa', () {
      test('returns the amount in paisa, for storage', () {
        expect(const Salary(5000050).toPaisa(), equals(5000050));
      });
    });

    group('format', () {
      test('returns grouped rupees with the paisa fraction', () {
        expect(
          const Salary(5000050).format(locale: 'en_US'),
          equals('50,000.50'),
        );
      });

      test('omits the fraction when there is no paisa', () {
        expect(
          const Salary(5000000).format(locale: 'en_US'),
          equals('50,000'),
        );
      });
    });

    group('toEditString', () {
      test('returns ungrouped rupees with the paisa fraction', () {
        expect(const Salary(5000050).toEditString(), equals('50000.50'));
      });

      test('pads a zero paisa fraction rather than omitting it', () {
        expect(const Salary(5000000).toEditString(), equals('50000.00'));
      });
    });
  });
}
