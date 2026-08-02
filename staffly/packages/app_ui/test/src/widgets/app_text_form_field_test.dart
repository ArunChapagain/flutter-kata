import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group(AppTextFormField, () {
    group('renders', () {
      testWidgets('its label above the field', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name'),
        );

        expect(find.text('Full Name'), findsOneWidget);
      });

      testWidgets('a required marker when the field is required', (
        tester,
      ) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name', isRequired: true),
        );

        expect(find.text('*'), findsOneWidget);
      });

      testWidgets('no required marker when the field is optional', (
        tester,
      ) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name'),
        );

        expect(find.text('*'), findsNothing);
      });

      testWidgets('its hint text', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(
            label: 'Full Name',
            hintText: 'Enter full name',
          ),
        );

        expect(find.text('Enter full name'), findsOneWidget);
      });

      testWidgets('its prefix icon', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
          ),
        );

        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('the error text it is given', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(
            label: 'Full Name',
            errorText: 'Full name cannot be empty',
          ),
        );

        expect(find.text('Full name cannot be empty'), findsOneWidget);
      });

      testWidgets('the initial value it is given', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name', initialValue: 'Jane Doe'),
        );

        expect(find.text('Jane Doe'), findsOneWidget);
      });
    });

    group('calls onChanged', () {
      testWidgets('with the text the user typed', (tester) async {
        String? changed;

        await tester.pumpApp(
          AppTextFormField(
            label: 'Full Name',
            onChanged: (value) => changed = value,
          ),
        );
        await tester.enterText(find.byType(TextField), 'Jane Doe');
        await tester.pump();

        expect(changed, 'Jane Doe');
      });
    });

    group('disables the field', () {
      testWidgets('when it is not enabled', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name', enabled: false),
        );

        final field = tester.widget<TextField>(find.byType(TextField));

        expect(field.enabled, isFalse);
      });

      testWidgets('never, by default', (tester) async {
        await tester.pumpApp(
          const AppTextFormField(label: 'Full Name'),
        );

        final field = tester.widget<TextField>(find.byType(TextField));

        expect(field.enabled, isTrue);
      });
    });
  });
}
