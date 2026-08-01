import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group(AppCard, () {
    group('renders', () {
      testWidgets('its child', (tester) async {
        await tester.pumpApp(
          const AppCard(child: Text('Jane Doe')),
        );

        expect(find.text('Jane Doe'), findsOneWidget);
      });
    });

    group('calls onTap', () {
      testWidgets('when the card is tapped', (tester) async {
        var tapped = 0;

        await tester.pumpApp(
          AppCard(
            onTap: () => tapped++,
            child: const Text('Jane Doe'),
          ),
        );
        await tester.tap(find.byType(AppCard));
        await tester.pump();

        expect(tapped, 1);
      });

      testWidgets('never, when no callback is supplied', (tester) async {
        await tester.pumpApp(
          const AppCard(child: Text('Jane Doe')),
        );

        // A card with nothing to do offers no ink response, so it neither
        // splashes nor steals the gesture from anything beneath it.
        expect(find.byType(InkWell), findsNothing);
      });
    });
  });
}
