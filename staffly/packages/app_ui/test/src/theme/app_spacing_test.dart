import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppSpacing, () {
    test('scales from a 4px base unit', () {
      const spacing = AppSpacing();

      expect(spacing.xxs, 4);
      expect(spacing.xs, 8);
      expect(spacing.sm, 12);
      expect(spacing.md, 16);
      expect(spacing.lg, 24);
      expect(spacing.xlg, 32);
      expect(spacing.xxlg, 48);
    });

    group('copyWith', () {
      test('replaces only the values it is given', () {
        final spacing = const AppSpacing().copyWith(md: 20);

        expect(spacing.md, 20);
        expect(spacing.xxs, const AppSpacing().xxs);
        expect(spacing.xxlg, const AppSpacing().xxlg);
      });

      test('returns an equivalent instance when given nothing', () {
        final spacing = const AppSpacing().copyWith();

        expect(spacing.md, const AppSpacing().md);
      });
    });

    group('lerp', () {
      test('interpolates every token towards the other instance', () {
        const from = AppSpacing();
        const to = AppSpacing(xxs: 8, md: 32);

        final result = from.lerp(to, 0.5);

        expect(result.xxs, 6);
        expect(result.md, 24);
      });

      test('returns itself when there is nothing to interpolate towards', () {
        const spacing = AppSpacing();

        expect(spacing.lerp(null, 0.5), same(spacing));
      });
    });
  });
}
