import 'package:app_ui/app_ui.dart';

/// {@template app_theme}
/// The single [ThemeData] the app runs on.
///
/// Light only, deliberately: the brief asks for one appearance, and a dark
/// variant that is never rendered is a variant that is never verified.
/// {@endtemplate}
class AppTheme {
  /// The Inter family bundled with this package.
  ///
  /// Package-scoped, because a font declared by a dependency is registered
  /// under `packages/<name>/<family>`. Referring to it as plain `Inter` from
  /// the app resolves to nothing and falls back to the platform default
  /// without complaint.
  static const fontFamily = 'packages/app_ui/Inter';

  /// {@macro app_theme}
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: AppColors.scaffold,
    extensions: const [AppSpacing()],
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: AppColors.inputFill,
      border: _inputBorder(AppColors.outline),
      enabledBorder: _inputBorder(AppColors.outline),
      focusedBorder: _inputBorder(AppColors.primary, width: 2),
      disabledBorder: _inputBorder(AppColors.outline),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error, width: 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
      ),
    ),
  );

  /// Seeded so the tonal palette stays internally consistent, then overridden
  /// role by role — [ColorScheme.fromSeed] derives a tone from the seed rather
  /// than returning it, which would drift the brand colour.
  static final ColorScheme _lightColorScheme =
      ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.scaffold,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceContainerLowest: AppColors.card,
        surfaceContainerLow: AppColors.inputFill,
        outline: AppColors.outline,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
      );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
