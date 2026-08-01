import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group(AppConfirmDialog, () {
    AppConfirmDialog buildSubject({
      VoidCallback? onConfirm,
      VoidCallback? onCancel,
    }) {
      return AppConfirmDialog(
        title: 'Delete employee?',
        message: 'Jane Doe will be removed permanently.',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        onConfirm: onConfirm ?? () {},
        onCancel: onCancel ?? () {},
      );
    }

    group('renders', () {
      testWidgets('its title, message and both action labels', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.text('Delete employee?'), findsOneWidget);
        expect(
          find.text('Jane Doe will be removed permanently.'),
          findsOneWidget,
        );
        expect(find.text('Delete'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });
    });

    group('calls onConfirm', () {
      testWidgets('when the confirm action is tapped', (tester) async {
        var confirmed = 0;

        await tester.pumpApp(buildSubject(onConfirm: () => confirmed++));
        await tester.tap(find.text('Delete'));
        await tester.pump();

        expect(confirmed, 1);
      });

      testWidgets('never, when the cancel action is tapped', (tester) async {
        var confirmed = 0;

        await tester.pumpApp(buildSubject(onConfirm: () => confirmed++));
        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(confirmed, isZero);
      });
    });

    group('calls onCancel', () {
      testWidgets('when the cancel action is tapped', (tester) async {
        var cancelled = 0;

        await tester.pumpApp(buildSubject(onCancel: () => cancelled++));
        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(cancelled, 1);
      });

      testWidgets('never, when the confirm action is tapped', (tester) async {
        var cancelled = 0;

        await tester.pumpApp(buildSubject(onCancel: () => cancelled++));
        await tester.tap(find.text('Delete'));
        await tester.pump();

        expect(cancelled, isZero);
      });
    });
  });
}
