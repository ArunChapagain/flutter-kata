import 'dart:ui';

import 'package:app_ui/app_ui.dart';

/// {@template app_spacing}
/// The spacing scale, in logical pixels, stepping up from a 4px base unit.
///
/// A [ThemeExtension] rather than a bare constant class because Material has
/// no spacing equivalent to fold this into, and reading it off the theme keeps
/// widgets free of magic numbers.
/// {@endtemplate}
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// {@macro app_spacing}
  const AppSpacing({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xlg = 32,
    this.xxlg = 48,
  });

  /// 4px — the base unit.
  final double xxs;

  /// 8px.
  final double xs;

  /// 12px.
  final double sm;

  /// 16px — the default gap between elements.
  final double md;

  /// 24px.
  final double lg;

  /// 32px.
  final double xlg;

  /// 48px.
  final double xxlg;

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xlg,
    double? xxlg,
  }) {
    return AppSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xlg: xlg ?? this.xlg,
      xxlg: xxlg ?? this.xxlg,
    );
  }

  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other == null) return this;
    return AppSpacing(
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xlg: lerpDouble(xlg, other.xlg, t)!,
      xxlg: lerpDouble(xxlg, other.xxlg, t)!,
    );
  }
}
