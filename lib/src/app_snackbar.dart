// core class + queue logic
import 'package:flutter/material.dart';

import 'snackbar_animation.dart';
import 'snackbar_position.dart';
import 'snackbar_queue.dart';
import 'snackbar_theme.dart';
import 'snackbar_type.dart';

/// A beautiful, fully customizable SnackBar utility for Flutter 3.16+.
class AppSnackBar {
  AppSnackBar._();

  static AppSnackBarTheme theme = const AppSnackBarTheme();
  static GlobalKey<ScaffoldMessengerState>? messengerKey;
  static bool useQueue = false;
  static SnackBarQueue? _queue;

  // Active overlay entries
  static OverlayEntry? _currentOverlay;

  // ── Core show ─────────────────────────────────────────────────────────────

  static void show(
      BuildContext? context,
      String message, {
        SnackBarType type = SnackBarType.info,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 3),
        bool showClose = true,
        Widget? leading,
        Widget? trailing,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
        EdgeInsetsGeometry? margin,
        VoidCallback? onClose,
        Duration queueGap = const Duration(milliseconds: 300),
      }) {
    final config = theme.resolve(type);
    final effectiveBg = backgroundColor ?? config.backgroundColor;
    final effectiveRadius = borderRadius ?? theme.borderRadius;
    final effectiveElevation = elevation ?? theme.elevation;
    final effectiveAnimation = animation ?? theme.defaultAnimation;
    final effectiveTextStyle = textStyle ??
        theme.textStyle ??
        TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? theme.fontSize,
          fontWeight: FontWeight.w500,
        );

    if (useQueue) {
      // Queue mode — use Flutter SnackBar (simpler for queue management)
      final messenger = _resolveMessenger(context);
      if (messenger == null) return;

      final snackBar = _buildFlutterSnackBar(
        message: message,
        icon: config.icon,
        backgroundColor: effectiveBg,
        borderRadius: effectiveRadius,
        elevation: effectiveElevation,
        textStyle: effectiveTextStyle,
        showClose: showClose,
        leading: leading,
        trailing: trailing,
        duration: duration,
        position: position,
        messengerKey: messengerKey,
        context: context,
      );

      _ensureQueue()?.add(snackBar, gap: queueGap);
      return;
    }

    // ✅ Non-queue — use Overlay for full animation control
    _showOverlay(
      context,
      message,
      icon: config.icon,
      backgroundColor: effectiveBg,
      borderRadius: effectiveRadius,
      elevation: effectiveElevation,
      animation: effectiveAnimation,
      duration: duration,
      showClose: showClose,
      leading: leading,
      trailing: trailing,
      textStyle: effectiveTextStyle,
      position: position,
      onClose: onClose,
    );
  }

  // ── Overlay show (both top & bottom) ─────────────────────────────────────

  static void _showOverlay(
      BuildContext? context,
      String message, {
        required IconData icon,
        required Color backgroundColor,
        required double borderRadius,
        required double elevation,
        required SnackBarAnimation animation,
        required Duration duration,
        required bool showClose,
        required TextStyle textStyle,
        required SnackBarPosition position,
        Widget? leading,
        Widget? trailing,
        VoidCallback? onClose,
      }) {
    final overlayContext = context ?? messengerKey?.currentContext;
    if (overlayContext == null) {
      debugPrint('[AppSnackBar] ⚠️ No context found.');
      return;
    }

    // Remove existing overlay
    _removeCurrentOverlay();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SnackBarOverlay(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        elevation: elevation,
        animation: animation,
        animationDuration: theme.animationDuration,
        textStyle: textStyle,
        showClose: showClose,
        leading: leading,
        trailing: trailing,
        position: position,
        onDismiss: () {
          _removeCurrentOverlay();
          onClose?.call();
        },
      ),
    );

    _currentOverlay = entry;
    Overlay.of(overlayContext).insert(entry);

    // Auto dismiss
    Future.delayed(duration, _removeCurrentOverlay);
  }

  static void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // ── With action button ─────────────────────────────────────────────────────

  static void showWithAction(
      BuildContext? context,
      String message, {
        required String actionLabel,
        required VoidCallback onAction,
        SnackBarType type = SnackBarType.info,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 4),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
        Duration queueGap = const Duration(milliseconds: 300),
      }) {
    final config = theme.resolve(type);
    final effectiveBg = backgroundColor ?? config.backgroundColor;
    final effectiveRadius = borderRadius ?? theme.borderRadius;
    final effectiveElevation = elevation ?? theme.elevation;
    final effectiveAnimation = animation ?? theme.defaultAnimation;
    final effectiveTextStyle = textStyle ??
        theme.textStyle ??
        TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? theme.fontSize,
          fontWeight: FontWeight.w500,
        );

    final actionWidget = GestureDetector(
      onTap: () {
        _removeCurrentOverlay();
        onAction();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Text(
          actionLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (useQueue) {
      final messenger = _resolveMessenger(context);
      if (messenger == null) return;

      final snackBar = _buildFlutterSnackBar(
        message: message,
        icon: config.icon,
        backgroundColor: effectiveBg,
        borderRadius: effectiveRadius,
        elevation: effectiveElevation,
        textStyle: effectiveTextStyle,
        showClose: false,
        trailing: actionWidget,
        duration: duration,
        position: position,
        messengerKey: messengerKey,
        context: context,
      );
      _ensureQueue()?.add(snackBar, gap: queueGap);
      return;
    }

    _showOverlay(
      context,
      message,
      icon: config.icon,
      backgroundColor: effectiveBg,
      borderRadius: effectiveRadius,
      elevation: effectiveElevation,
      animation: effectiveAnimation,
      duration: duration,
      showClose: false,
      trailing: actionWidget,
      textStyle: effectiveTextStyle,
      position: position,
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  static void showLoading(
      BuildContext? context,
      String message, {
        SnackBarType type = SnackBarType.info,
        SnackBarPosition position = SnackBarPosition.bottom,
        Duration duration = const Duration(seconds: 30),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
      }) {
    const spinner = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );

    final config = theme.resolve(type);
    _showOverlay(
      context,
      message,
      icon: config.icon,
      backgroundColor: backgroundColor ?? config.backgroundColor,
      borderRadius: borderRadius ?? theme.borderRadius,
      elevation: elevation ?? theme.elevation,
      animation: theme.defaultAnimation,
      duration: duration,
      showClose: false,
      leading: spinner,
      textStyle: textStyle ??
          theme.textStyle ??
          TextStyle(
            color: Colors.white,
            fontSize: fontSize ?? theme.fontSize,
            fontWeight: FontWeight.w500,
          ),
      position: position,
    );
  }

  // ── Queue ──────────────────────────────────────────────────────────────────

  static void clearQueue() => _queue?.clear();
  static int get queueLength => _queue?.length ?? 0;

  // ── Hide ──────────────────────────────────────────────────────────────────

  static void hide(BuildContext? context) {
    _removeCurrentOverlay();
    _resolveMessenger(context)?.hideCurrentSnackBar();
  }

  // ── Shortcuts ─────────────────────────────────────────────────────────────

  static void success(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 3),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        VoidCallback? onClose}) =>
      show(context, message,
          type: SnackBarType.success,
          showClose: showClose,
          position: position,
          animation: animation,
          duration: duration,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          fontSize: fontSize,
          elevation: elevation,
          borderRadius: borderRadius,
          onClose: onClose);

  static void error(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 4),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        VoidCallback? onClose}) =>
      show(context, message,
          type: SnackBarType.error,
          showClose: showClose,
          position: position,
          animation: animation,
          duration: duration,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          fontSize: fontSize,
          elevation: elevation,
          borderRadius: borderRadius,
          onClose: onClose);

  static void warning(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 3),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        VoidCallback? onClose}) =>
      show(context, message,
          type: SnackBarType.warning,
          showClose: showClose,
          position: position,
          animation: animation,
          duration: duration,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          fontSize: fontSize,
          elevation: elevation,
          borderRadius: borderRadius,
          onClose: onClose);

  static void info(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration duration = const Duration(seconds: 3),
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        VoidCallback? onClose}) =>
      show(context, message,
          type: SnackBarType.info,
          showClose: showClose,
          position: position,
          animation: animation,
          duration: duration,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          fontSize: fontSize,
          elevation: elevation,
          borderRadius: borderRadius,
          onClose: onClose);

  // ── Private helpers ────────────────────────────────────────────────────────

  static ScaffoldMessengerState? _resolveMessenger(BuildContext? context) {
    if (messengerKey?.currentState != null) return messengerKey!.currentState;
    if (context != null) return ScaffoldMessenger.of(context);
    debugPrint('[AppSnackBar] ⚠️ No messenger found.');
    return null;
  }

  static SnackBarQueue? _ensureQueue() {
    if (messengerKey == null) {
      debugPrint('[AppSnackBar] ⚠️ Queue requires messengerKey.');
      return null;
    }
    _queue ??= SnackBarQueue(messengerKey: messengerKey!);
    return _queue;
  }

  // ── Flutter SnackBar builder (used only for queue) ─────────────────────────

  static SnackBar _buildFlutterSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required double borderRadius,
    required double elevation,
    required TextStyle textStyle,
    required bool showClose,
    required Duration duration,
    required SnackBarPosition position,
    Widget? leading,
    Widget? trailing,
    GlobalKey<ScaffoldMessengerState>? messengerKey,
    BuildContext? context,
  }) {
    return SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      elevation: elevation,
      margin: position == SnackBarPosition.top
          ? const EdgeInsets.only(top: 50, left: 16, right: 16)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      content: Row(
        children: [
          leading ?? Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: textStyle)),
          if (trailing != null)
            trailing
          else if (showClose)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                messengerKey?.currentState?.hideCurrentSnackBar();
                if (context != null) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Overlay Widget (handles both top & bottom with real animations) ────────────

class _SnackBarOverlay extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final SnackBarAnimation animation;
  final Duration animationDuration;
  final TextStyle textStyle;
  final bool showClose;
  final Widget? leading;
  final Widget? trailing;
  final SnackBarPosition position;
  final VoidCallback onDismiss;

  const _SnackBarOverlay({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderRadius,
    required this.elevation,
    required this.animation,
    required this.animationDuration,
    required this.textStyle,
    required this.showClose,
    required this.position,
    required this.onDismiss,
    this.leading,
    this.trailing,
  });

  @override
  State<_SnackBarOverlay> createState() => _SnackBarOverlayState();
}

class _SnackBarOverlayState extends State<_SnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // ✅ Fade — 0 to 1
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    // ✅ Slide — direction depends on position
    final slideBegin = widget.position == SnackBarPosition.top
        ? const Offset(0, -1.5) // slides down from top
        : const Offset(0, 1.5); // slides up from bottom

    _offset = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _applyAnimation(Widget child) {
    switch (widget.animation) {
      case SnackBarAnimation.slide:
      // ✅ Slide only
        return SlideTransition(position: _offset, child: child);

      case SnackBarAnimation.fade:
      // ✅ Fade only
        return FadeTransition(opacity: _opacity, child: child);

      case SnackBarAnimation.none:
      // ✅ No animation — instant
        return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTop = widget.position == SnackBarPosition.top;

    return Positioned(
      // ✅ Top: below status bar | Bottom: above navigation bar
      top: isTop ? mq.padding.top + 12 : null,
      bottom: isTop ? null : mq.padding.bottom + 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _applyAnimation(
          Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: widget.elevation * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                widget.leading ??
                    Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.message, style: widget.textStyle),
                ),
                if (widget.trailing != null)
                  widget.trailing!
                else if (widget.showClose)
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onDismiss,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
