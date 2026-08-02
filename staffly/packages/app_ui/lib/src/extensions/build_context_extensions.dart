import 'package:app_ui/app_ui.dart';

/// Shorthand access to the custom theme tokens.
extension AppThemeBuildContext on BuildContext {
  /// The [AppSpacing] carried by the surrounding theme.
  ///
  /// Non-null by construction: [AppTheme.light] always registers the
  /// extension, and every widget in this package is rendered under it.
  AppSpacing get appSpacing => Theme.of(this).extension<AppSpacing>()!;
}
