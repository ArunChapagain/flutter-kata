import 'package:app_ui/app_ui.dart';

/// The Staffly palette.
///
/// These are raw values, not roles. Nothing outside [AppTheme] should read
/// them — widgets go through `Theme.of(context).colorScheme`, so a palette
/// change lands in one place.
abstract final class AppColors {
  /// The brand green. Primary actions, active states and headings.
  static const primary = Color(0xFF014D43);

  /// Content drawn on top of [primary].
  static const onPrimary = Color(0xFFFFFFFF);

  /// The page background — off-white with a faint green cast.
  static const scaffold = Color(0xFFF8FAF8);

  /// Card and sheet backgrounds. Pure white, so cards separate from
  /// [scaffold] without needing a border.
  static const card = Color(0xFFFFFFFF);

  /// The fill behind a text field, distinct from both [scaffold] and [card].
  static const inputFill = Color(0xFFF2F4F2);

  /// Borders and dividers.
  static const outline = Color(0xFF707973);

  /// Body and heading text.
  static const textPrimary = Color(0xFF191C1B);

  /// Supporting text — labels, metadata, placeholder icons.
  static const textSecondary = Color(0xFF3F4946);

  /// Destructive actions and validation failures.
  static const error = Color(0xFFBA1A1A);

  /// Content drawn on top of [error].
  static const onError = Color(0xFFFFFFFF);

  /// The tinted fill behind a destructive action, such as a delete button.
  static const errorContainer = Color(0xC5FFDAD6);

  /// Content drawn on top of [errorContainer].
  static const onErrorContainer = Color(0xFF93000A);
}
