import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group(AppEmptyState, () {
    group('renders', () {
      testWidgets('its title and message', (tester) async {
        await tester.pumpApp(
          const AppEmptyState(
            title: 'No employees yet',
            message: 'Add your first team member to get started.',
          ),
        );

        expect(find.text('No employees yet'), findsOneWidget);
        expect(
          find.text('Add your first team member to get started.'),
          findsOneWidget,
        );
      });

      testWidgets('an icon when one is supplied', (tester) async {
        await tester.pumpApp(
          const AppEmptyState(
            title: 'No employees yet',
            message: 'Add your first team member to get started.',
            icon: Icons.people_outline,
          ),
        );

        expect(find.byIcon(Icons.people_outline), findsOneWidget);
      });

      testWidgets('no icon when none is supplied', (tester) async {
        await tester.pumpApp(
          const AppEmptyState(
            title: 'No employees yet',
            message: 'Add your first team member to get started.',
          ),
        );

        expect(find.byType(Icon), findsNothing);
      });

      testWidgets('an action when one is supplied', (tester) async {
        await tester.pumpApp(
          AppEmptyState(
            title: 'No employees yet',
            message: 'Add your first team member to get started.',
            action: FilledButton(
              onPressed: () {},
              child: const Text('Add employee'),
            ),
          ),
        );

        expect(find.text('Add employee'), findsOneWidget);
      });

      testWidgets('no action when none is supplied', (tester) async {
        await tester.pumpApp(
          const AppEmptyState(
            title: 'No employees yet',
            message: 'Add your first team member to get started.',
          ),
        );

        expect(find.byType(FilledButton), findsNothing);
      });
    });
  });
}
