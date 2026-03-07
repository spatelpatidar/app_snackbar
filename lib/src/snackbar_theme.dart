// AppSnackBarTheme + AppSnackBarData + SnackBarContentBuilder
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

// ── AppSnackBarData ──────────────────────────────────────────────────────────

/// All resolved data passed into [SnackBarContentBuilder].
///
/// Use every field to build your fully custom snackbar widget.
/// The package handles position, animation, overlay — you handle the design.
///
/// ### Full example
/// ```dart
/// AppSnackBar.show(
///   context,
///   'Download complete!',
///   type: SnackBarType.success,
///   contentBuilder: (ctx, data) {
///     return Container(
///       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
///       decoration: BoxDecoration(
///         gradient: LinearGradient(
///           colors: [data.backgroundColor, Colors.black87],
///           begin: Alignment.topLeft,
///           end: Alignment.bottomRight,
///         ),
///         borderRadius: BorderRadius.circular(data.borderRadius),
///         border: data.borderColor != null
///             ? Border.all(color: data.borderColor!, width: data.borderWidth)
///             : null,
///         boxShadow: [
///           BoxShadow(
///             color: data.backgroundColor.withValues(alpha: 0.4),
///             blurRadius: 12,
///             offset: const Offset(0, 4),
///           ),
///         ],
///       ),
///       child: Row(
///         children: [
///           Container(
///             padding: const EdgeInsets.all(8),
///             decoration: BoxDecoration(
///               color: Colors.white.withValues(alpha: 0.2),
///               shape: BoxShape.circle,
///             ),
///             child: Icon(data.icon, color: Colors.white, size: 18),
///           ),
///           const SizedBox(width: 12),
///           Expanded(
///             child: Column(
///               crossAxisAlignment: CrossAxisAlignment.start,
///               mainAxisSize: MainAxisSize.min,
///               children: [
///                 Text(
///                   data.type.name.toUpperCase(),
///                   style: const TextStyle(
///                     color: Colors.white70,
///                     fontSize: 10,
///                     fontWeight: FontWeight.w700,
///                     letterSpacing: 1.5,
///                   ),
///                 ),
///                 const SizedBox(height: 2),
///                 Text(data.message, style: data.textStyle),
///               ],
///             ),
///           ),
///           if (data.showClose)
///             GestureDetector(
///               onTap: data.dismiss,
///               child: const Icon(Icons.close_rounded,
///                   color: Colors.white54, size: 18),
///             ),
///         ],
///       ),
///     );
///   },
/// );
/// ```
@immutable
class AppSnackBarData {
  /// The message text to show.
  final String message;

  /// The snackbar type (`success`, `error`, `warning`, `info`).
  final SnackBarType type;

  /// Resolved background color for this type/call.
  final Color backgroundColor;

  /// Resolved icon for this type.
  final IconData icon;

  /// Resolved text style.
  final TextStyle textStyle;

  /// Resolved border radius.
  final double borderRadius;

  /// Resolved elevation / shadow depth.
  final double elevation;

  /// Resolved border color. `null` = no border.
  final Color? borderColor;

  /// Resolved border width.
  final double borderWidth;

  /// Whether a close button should be shown.
  final bool showClose;

  /// Call this to dismiss the snackbar from inside your builder.
  ///
  /// ```dart
  /// GestureDetector(
  ///   onTap: data.dismiss,
  ///   child: const Icon(Icons.close, color: Colors.white),
  /// )
  /// ```
  final VoidCallback dismiss;

  const AppSnackBarData({
    required this.message,
    required this.type,
    required this.backgroundColor,
    required this.icon,
    required this.textStyle,
    required this.borderRadius,
    required this.elevation,
    required this.borderColor,
    required this.borderWidth,
    required this.showClose,
    required this.dismiss,
  });
}

/// Signature for a fully custom snackbar content builder.
///
/// Return **any widget** — the package handles position, animation, overlay.
///
/// ```dart
/// typedef SnackBarContentBuilder = Widget Function(
///   BuildContext context,
///   AppSnackBarData data,
/// );
/// ```
typedef SnackBarContentBuilder = Widget Function(
    BuildContext context,
    AppSnackBarData data,
    );

// ── AppSnackBarTheme ──────────────────────────────────────────────────────────

/// Global visual theme for [AppSnackBar].
///
/// Set once in `main()` and every snackbar inherits these values
/// unless overridden per-call.
///
/// ### Basic theme
/// ```dart
/// AppSnackBar.theme = const AppSnackBarTheme(
///   infoColor: Color(0xFF003249),
///   successIcon: Icons.done_all_rounded,
///   borderRadius: 12,
///   elevation: 8,
///   defaultAnimation: SnackBarAnimation.fade,
/// );
/// ```
///
/// ### Global custom design via [contentBuilder]
/// ```dart
/// AppSnackBar.theme = AppSnackBarTheme(
///   contentBuilder: (ctx, data) => MyBrandedSnackBar(data: data),
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
  /// Per-call `textStyle` overrides this.
  final TextStyle? textStyle;

  /// Default font size. Ignored when [textStyle] is set.
  final double fontSize;

  // ── Shape & elevation ──────────────────────────────────────────────────────

  /// Border radius. Default: `16`
  final double borderRadius;

  /// Shadow depth. Default: `6`
  final double elevation;

  // ── Border ────────────────────────────────────────────────────────────────

  /// Global border color for all snackbars. `null` = no border (default).
  ///
  /// Transparent background automatically uses white border when this is null.
  ///
  /// Per-call `borderColor` overrides this.
  final Color? borderColor;

  /// Global border width. Only used when [borderColor] is set. Default: `1.5`
  final double borderWidth;

  // ── Animation ─────────────────────────────────────────────────────────────

  /// Default animation style. Default: [SnackBarAnimation.slide]
  final SnackBarAnimation defaultAnimation;

  /// Animation duration. Default: `300ms`
  final Duration animationDuration;

  // ── Custom Builder ────────────────────────────────────────────────────────

  /// 🎨 Global custom content builder — replaces the default snackbar design.
  ///
  /// When set, **all** snackbars use your widget instead of the built-in design.
  /// Per-call `contentBuilder` overrides this for individual snackbars.
  ///
  /// [AppSnackBarData] gives you all resolved values:
  /// `message`, `type`, `backgroundColor`, `icon`, `textStyle`,
  /// `borderRadius`, `elevation`, `borderColor`, `borderWidth`,
  /// `showClose`, `dismiss()`.
  ///
  /// ### Example — brand-wide custom design
  /// ```dart
  /// AppSnackBar.theme = AppSnackBarTheme(
  ///   contentBuilder: (ctx, data) => Container(
  ///     padding: const EdgeInsets.all(16),
  ///     decoration: BoxDecoration(
  ///       color: data.backgroundColor,
  ///       borderRadius: BorderRadius.circular(data.borderRadius),
  ///       border: data.borderColor != null
  ///           ? Border.all(color: data.borderColor!, width: data.borderWidth)
  ///           : null,
  ///     ),
  ///     child: Row(children: [
  ///       Icon(data.icon, color: Colors.white),
  ///       const SizedBox(width: 12),
  ///       Expanded(child: Text(data.message, style: data.textStyle)),
  ///       if (data.showClose)
  ///         GestureDetector(
  ///           onTap: data.dismiss,
  ///           child: const Icon(Icons.close, color: Colors.white),
  ///         ),
  ///     ]),
  ///   ),
  /// );
  ///
  /// // Then just call normally — your design is used automatically:
  /// AppSnackBar.success(context, 'Done!');
  /// AppSnackBar.error(context, 'Failed.');
  /// ```
  final SnackBarContentBuilder? contentBuilder;

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
    this.borderColor,
    this.borderWidth = 1.5,
    this.defaultAnimation = SnackBarAnimation.slide,
    this.animationDuration = const Duration(milliseconds: 300),
    this.contentBuilder, // null = use default built-in design
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
// // AppSnackBarTheme + config
// import 'package:flutter/material.dart';
//
// import 'snackbar_animation.dart';
// import 'snackbar_type.dart';
//
// /// Internal resolved config for one [SnackBarType].
// @immutable
// class AppSnackBarConfig {
//   /// Background color of the snackbar.
//   final Color backgroundColor;
//
//   /// Leading icon shown on the left side.
//   final IconData icon;
//
//   /// Creates an [AppSnackBarConfig].
//   const AppSnackBarConfig({
//     required this.backgroundColor,
//     required this.icon,
//   });
// }
//
// /// Global visual theme for [AppSnackBar].
// ///
// /// Set once and every snackbar inherits these values unless
// /// explicitly overridden per-call.
// ///
// /// ### Example
// /// ```dart
// /// AppSnackBar.theme = const AppSnackBarTheme(
// ///   infoColor: Color(0xFF003249),
// ///   successIcon: Icons.done_all_rounded,
// ///   borderRadius: 12,
// ///   elevation: 8,
// ///   defaultAnimation: SnackBarAnimation.fade,
// ///   textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
// /// );
// /// ```
// @immutable
// class AppSnackBarTheme {
//   // ── Per-type colors ────────────────────────────────────────────────────────
//
//   /// Background color for [SnackBarType.success]. Default: `#2E7D32`
//   final Color? successColor;
//
//   /// Background color for [SnackBarType.error]. Default: `#C62828`
//   final Color? errorColor;
//
//   /// Background color for [SnackBarType.warning]. Default: `#E65100`
//   final Color? warningColor;
//
//   /// Background color for [SnackBarType.info]. Default: `#003249`
//   final Color? infoColor;
//
//   // ── Per-type icons ─────────────────────────────────────────────────────────
//
//   /// Leading icon for [SnackBarType.success].
//   final IconData? successIcon;
//
//   /// Leading icon for [SnackBarType.error].
//   final IconData? errorIcon;
//
//   /// Leading icon for [SnackBarType.warning].
//   final IconData? warningIcon;
//
//   /// Leading icon for [SnackBarType.info].
//   final IconData? infoIcon;
//
//   // ── Typography ─────────────────────────────────────────────────────────────
//
//   /// Default [TextStyle] for the snackbar message.
//   /// Per-call [textStyle] overrides this.
//   final TextStyle? textStyle;
//
//   /// Default font size for the message. Ignored if [textStyle] is set.
//   final double fontSize;
//
//   // ── Shape & elevation ──────────────────────────────────────────────────────
//
//   /// Border radius of all snackbars. Default: `16`
//   final double borderRadius;
//
//   /// Shadow depth (Material elevation). Default: `6`
//   final double elevation;
//
//   // ── Animation ─────────────────────────────────────────────────────────────
//
//   /// Default entrance/exit animation. Default: [SnackBarAnimation.slide]
//   final SnackBarAnimation defaultAnimation;
//
//   /// Duration of the animation. Default: `300ms`
//   final Duration animationDuration;
//
//   /// Creates an [AppSnackBarTheme].
//   const AppSnackBarTheme({
//     this.successColor,
//     this.errorColor,
//     this.warningColor,
//     this.infoColor,
//     this.successIcon,
//     this.errorIcon,
//     this.warningIcon,
//     this.infoIcon,
//     this.textStyle,
//     this.fontSize = 14,
//     this.borderRadius = 16,
//     this.elevation = 6,
//     this.defaultAnimation = SnackBarAnimation.slide,
//     this.animationDuration = const Duration(milliseconds: 300),
//   });
//
//   /// Resolves the [AppSnackBarConfig] for the given [SnackBarType].
//   AppSnackBarConfig resolve(SnackBarType type) {
//     switch (type) {
//       case SnackBarType.success:
//         return AppSnackBarConfig(
//           backgroundColor: successColor ?? const Color(0xFF2E7D32),
//           icon: successIcon ?? Icons.check_circle_outline_rounded,
//         );
//       case SnackBarType.error:
//         return AppSnackBarConfig(
//           backgroundColor: errorColor ?? const Color(0xFFC62828),
//           icon: errorIcon ?? Icons.error_outline_rounded,
//         );
//       case SnackBarType.warning:
//         return AppSnackBarConfig(
//           backgroundColor: warningColor ?? const Color(0xFFE65100),
//           icon: warningIcon ?? Icons.warning_amber_rounded,
//         );
//       case SnackBarType.info:
//         return AppSnackBarConfig(
//           backgroundColor: infoColor ?? const Color(0xFF003249),
//           icon: infoIcon ?? Icons.info_outline_rounded,
//         );
//     }
//   }
// }
