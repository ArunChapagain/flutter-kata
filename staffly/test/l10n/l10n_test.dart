import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staffly/l10n/l10n.dart';

import '../helpers/helpers.dart';

void main() {
  group('AppLocalizationsX', () {
    testWidgets('resolves the $AppLocalizations for the active locale', (
      tester,
    ) async {
      late AppLocalizations l10n;

      await tester.pumpApp(
        Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(l10n.localeName, equals('en'));
    });
  });
}
