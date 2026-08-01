import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/employees/models/models.dart';

void main() {
  group(JobTitle, () {
    test('shows no error before the field has been touched', () {
      const subject = JobTitle.pure();

      expect(subject.isPure, isTrue);
      expect(subject.displayError, isNull);
    });

    test('reports an empty title as $JobTitleValidationError.empty', () {
      expect(
        const JobTitle.dirty().error,
        equals(JobTitleValidationError.empty),
      );
    });

    test('treats a title of only whitespace as empty', () {
      expect(
        const JobTitle.dirty('   ').error,
        equals(JobTitleValidationError.empty),
      );
    });

    test('is valid once a title has been typed', () {
      const subject = JobTitle.dirty('Software Engineer');

      expect(subject.isValid, isTrue);
      expect(subject.error, isNull);
    });
  });
}
