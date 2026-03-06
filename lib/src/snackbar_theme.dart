// AppSnackBarTheme + config
import 'package:flutter/material.dart';

import 'snackbar_animation.dart';
import 'snackbar_type.dart';

/// Internal resolved config for one [SnackBarType].
@immutable
class AppSnackBarConfig {
  /// Background color of the snackbar.
  final Color backgroundColor;

  /// Leading icon shown on the left side.
  final IconData icon;

  /// Creates an [AppSnackBarConfig].
  const AppSnackBarConfig({
    required this.backgroundColor,
    required this.icon,
  });
}

/// Global visual theme for [AppSnackBar].
///
/// Set once and every snackbar inherits these values unless
/// explicitly overridden per-call.
///
/// ### Example
/// ```dart
/// AppSnackBar.theme = const AppSnackBarTheme(
///   infoColor: Color(0xFF003249),
///   successIcon: Icons.done_all_rounded,
///   borderRadius: 12,
///   elevation: 8,
///   defaultAnimation: SnackBarAnimation.fade,
///   textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
/// );
/// ```
@immutable
class AppSnackBarTheme {
  // ── Per-type colors ────────────────────────────────────────────────────────

  /// Background color for [SnackBarType.success]. Default: `#2E7D32`
  final Color? successColor;

  /// Background color for [SnackBarType.error]. Default: `#C62828`
  final Color? errorColor;

  /// Background color for [SnackBarType.warning]. Default: `#E65100`
  final Color? warningColor;

  /// Background color for [SnackBarType.info]. Default: `#003249`
  final Color? infoColor;

  // ── Per-type icons ─────────────────────────────────────────────────────────

  /// Leading icon for [SnackBarType.success].
  final IconData? successIcon;

  /// Leading icon for [SnackBarType.error].
  final IconData? errorIcon;

  /// Leading icon for [SnackBarType.warning].
  final IconData? warningIcon;

  /// Leading icon for [SnackBarType.info].
  final IconData? infoIcon;

  // ── Typography ─────────────────────────────────────────────────────────────

  /// Default [TextStyle] for the snackbar message.
  /// Per-call [textStyle] overrides this.
  final TextStyle? textStyle;

  /// Default font size for the message. Ignored if [textStyle] is set.
  final double fontSize;

  // ── Shape & elevation ──────────────────────────────────────────────────────

  /// Border radius of all snackbars. Default: `16`
  final double borderRadius;

  /// Shadow depth (Material elevation). Default: `6`
  final double elevation;

  // ── Animation ─────────────────────────────────────────────────────────────

  /// Default entrance/exit animation. Default: [SnackBarAnimation.slide]
  final SnackBarAnimation defaultAnimation;

  /// Duration of the animation. Default: `300ms`
  final Duration animationDuration;

  /// Creates an [AppSnackBarTheme].
  const AppSnackBarTheme({
    this.successColor,
    this.errorColor,
    this.warningColor,
    this.infoColor,
    this.successIcon,
    this.errorIcon,
    this.warningIcon,
    this.infoIcon,
    this.textStyle,
    this.fontSize = 14,
    this.borderRadius = 16,
    this.elevation = 6,
    this.defaultAnimation = SnackBarAnimation.slide,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Resolves the [AppSnackBarConfig] for the given [SnackBarType].
  AppSnackBarConfig resolve(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppSnackBarConfig(
          backgroundColor: successColor ?? const Color(0xFF2E7D32),
          icon: successIcon ?? Icons.check_circle_outline_rounded,
        );
      case SnackBarType.error:
        return AppSnackBarConfig(
          backgroundColor: errorColor ?? const Color(0xFFC62828),
          icon: errorIcon ?? Icons.error_outline_rounded,
        );
      case SnackBarType.warning:
        return AppSnackBarConfig(
          backgroundColor: warningColor ?? const Color(0xFFE65100),
          icon: warningIcon ?? Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return AppSnackBarConfig(
          backgroundColor: infoColor ?? const Color(0xFF003249),
          icon: infoIcon ?? Icons.info_outline_rounded,
        );
    }
  }
}
