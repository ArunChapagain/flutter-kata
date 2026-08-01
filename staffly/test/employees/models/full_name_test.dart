import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/models/models.dart';

void main() {
  group(FullName, () {
    test('shows no error before the field has been touched', () {
      const subject = FullName.pure();

      expect(subject.isPure, isTrue);
      expect(subject.displayError, isNull);
    });

    test('reports an empty name as $FullNameValidationError.empty', () {
      expect(
        const FullName.dirty().error,
        equals(FullNameValidationError.empty),
      );
    });

    test('treats a name of only whitespace as empty', () {
      expect(
        const FullName.dirty('   ').error,
        equals(FullNameValidationError.empty),
      );
    });

    test('is valid once a name has been typed', () {
      const subject = FullName.dirty('Arun Chapagai');

      expect(subject.isValid, isTrue);
      expect(subject.error, isNull);
    });
  });
}
