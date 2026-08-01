import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders a $MaterialApp with localizations wired up', (
      tester,
    ) async {
      await tester.pumpWidget(const App());

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
