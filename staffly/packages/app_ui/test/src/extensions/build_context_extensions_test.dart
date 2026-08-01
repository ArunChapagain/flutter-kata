import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppThemeBuildContext', () {
    testWidgets('appSpacing reads $AppSpacing off the surrounding theme', (
      tester,
    ) async {
      late AppSpacing spacing;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            spacing = context.appSpacing;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(spacing, same(AppTheme.light.extension<AppSpacing>()));
    });
  });
}
