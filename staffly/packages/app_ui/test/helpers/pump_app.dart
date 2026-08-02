import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget inside the real app theme.
///
/// Every widget test in this package goes through here, so a primitive is
/// always exercised against the same [ThemeData] the app runs on rather than
/// against Material's defaults.
extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in a [MaterialApp] using [AppTheme.light].
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: widget),
      ),
    );
  }
}
