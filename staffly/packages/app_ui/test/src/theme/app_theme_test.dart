import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    group('light', () {
      test('is a light Material 3 $ThemeData', () {
        expect(AppTheme.light.brightness, Brightness.light);
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('keeps the brand green as the scheme primary', () {
        // ColorScheme.fromSeed derives a tone from the seed rather than
        // returning it, so the brand colour is pinned explicitly. Without
        // this the CTAs drift away from the design system.
        expect(AppTheme.light.colorScheme.primary, AppColors.primary);
        expect(AppTheme.light.colorScheme.onPrimary, AppColors.onPrimary);
      });

      test('separates the scaffold, the card and the input surfaces', () {
        final colorScheme = AppTheme.light.colorScheme;

        expect(AppTheme.light.scaffoldBackgroundColor, AppColors.scaffold);
        expect(colorScheme.surface, AppColors.scaffold);
        expect(colorScheme.surfaceContainerLowest, AppColors.card);
        expect(colorScheme.surfaceContainerLow, AppColors.inputFill);
      });

      test('uses the design system outline and text colours', () {
        final colorScheme = AppTheme.light.colorScheme;

        expect(colorScheme.outline, AppColors.outline);
        expect(colorScheme.onSurface, AppColors.textPrimary);
        expect(colorScheme.onSurfaceVariant, AppColors.textSecondary);
      });

      test('uses the error palette the destructive actions are drawn in', () {
        final colorScheme = AppTheme.light.colorScheme;

        expect(colorScheme.error, AppColors.error);
        expect(colorScheme.onError, AppColors.onError);
        expect(colorScheme.errorContainer, AppColors.errorContainer);
        expect(colorScheme.onErrorContainer, AppColors.onErrorContainer);
      });

      test('renders text in the bundled Inter family', () {
        // Package-scoped, because the font ships with app_ui and is consumed
        // from the app — an unprefixed 'Inter' silently falls back.
        expect(
          AppTheme.light.textTheme.bodyMedium?.fontFamily,
          'packages/app_ui/Inter',
        );
        expect(
          AppTheme.light.textTheme.titleLarge?.fontFamily,
          'packages/app_ui/Inter',
        );
      });

      test('rounds cards to the card radius', () {
        expect(
          AppTheme.light.cardTheme.shape,
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
        );
      });

      test('fills and rounds inputs, and outlines them in the outline '
          'colour', () {
        final inputTheme = AppTheme.light.inputDecorationTheme;

        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, AppColors.inputFill);
        expect(
          inputTheme.enabledBorder,
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
        );
      });

      test('rounds filled buttons to the button radius', () {
        final shape = AppTheme.light.filledButtonTheme.style?.shape?.resolve(
          const <WidgetState>{},
        );

        expect(
          shape,
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        );
      });

      test('carries $AppSpacing as a theme extension', () {
        expect(AppTheme.light.extension<AppSpacing>(), isNotNull);
      });
    });
  });
}
