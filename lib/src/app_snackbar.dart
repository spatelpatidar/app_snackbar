// core class + queue logic
import 'package:flutter/material.dart';
import 'dart:async';
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
  static Timer? _dismissTimer; // cancellable timer

  // ✅ Overlay pending queue — naya snackbar purane ke baad aayega automatically
  static final List<_OverlayArgs> _overlayPendingQueue = [];

  // ── Core show ─────────────────────────────────────────────────────────────

  /// Shows a fully customizable snackbar.
  ///
  /// ### Border examples
  /// ```dart
  /// // Outlined style:
  /// AppSnackBar.show(context, 'Outlined!',
  ///   backgroundColor: Colors.transparent,
  ///   borderColor: Colors.white,
  ///   borderWidth: 2,
  /// );
  ///
  /// // Subtle border on colored bg:
  /// AppSnackBar.success(context, 'Done!',
  ///   borderColor: Colors.white30,
  /// );
  /// ```
  static void show(
      BuildContext? context,
      String message, {
        SnackBarType type = SnackBarType.info,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        bool showClose = true,
        Widget? leading,
        Widget? trailing,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
        Color? borderColor,
        double? borderWidth,
        double? width,   // ✅ custom width (null = full width)
        double? height,  // ✅ custom height (null = wrap content)
        EdgeInsetsGeometry? margin,
        VoidCallback? onClose,
        Duration queueGap = const Duration(milliseconds: 300),
        bool? showTimer,
        Color? timerColor,
        // ✅ Per-call icon override.
        // Priority: per-call icon → theme.successIcon/errorIcon/… → built-in default
        IconData? icon,
      }) {
    final config = theme.resolve(type);
    final effectiveIcon = icon ?? config.icon;   // ← per-call wins
    final effectiveBg = backgroundColor ?? config.backgroundColor;
    final effectiveRadius = borderRadius ?? theme.borderRadius;
    final effectiveElevation = elevation ?? theme.elevation;
    final effectiveAnimation = animation ?? theme.defaultAnimation;
    final effectiveBorderColor = borderColor ?? theme.borderColor;
    final effectiveBorderWidth = borderWidth ?? theme.borderWidth;
    final effectiveDuration = duration ?? theme.defaultDuration ?? const Duration(seconds: 3);
    final effectiveShowTimer = showTimer ?? theme.showTimer;
    final effectiveTimerColor = timerColor ?? theme.timerColor ?? Colors.white54;
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
      _ensureQueue()?.add(
        _buildFlutterSnackBar(
          message: message,
          icon: effectiveIcon,
          backgroundColor: effectiveBg,
          borderRadius: effectiveRadius,
          elevation: effectiveElevation,
          borderColor: effectiveBorderColor,
          borderWidth: effectiveBorderWidth,
          textStyle: effectiveTextStyle,
          showClose: showClose,
          leading: leading,
          trailing: trailing,
          duration: effectiveDuration,
          // duration: duration,
          position: position,
          messengerKey: messengerKey,
          context: context,
        ),
        gap: queueGap,
      );
      return;
    }

    // ✅ Non-queue — use Overlay for full animation control
    _showOverlay(
      context,
      message,
      icon: effectiveIcon,
      backgroundColor: effectiveBg,
      borderRadius: effectiveRadius,
      elevation: effectiveElevation,
      borderColor: effectiveBorderColor,
      borderWidth: effectiveBorderWidth,
      width: width,
      height: height,
      animation: effectiveAnimation,
      // duration: duration,
      duration: effectiveDuration,
      showClose: showClose,
      leading: leading,
      trailing: trailing,
      textStyle: effectiveTextStyle,
      position: position,
      onClose: onClose,
      showTimer: effectiveShowTimer,
      timerColor: effectiveTimerColor,
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
        required double borderWidth,
        double? width,
        double? height,
        Color? borderColor,
        Widget? leading,
        Widget? trailing,
        VoidCallback? onClose,
        bool showTimer = false,
        Color? timerColor,
      }) {
    final overlayContext = context ?? messengerKey?.currentContext;
    if (overlayContext == null) {
      debugPrint('[AppSnackBar] ⚠️ No context found.');
      return;
    }

    final args = _OverlayArgs(
      context: overlayContext,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation,
      borderColor: borderColor,
      borderWidth: borderWidth,
      width: width,       // ✅ pass karo
      height: height,     // ✅ pass karo
      animation: animation,
      duration: duration,
      showClose: showClose,
      textStyle: textStyle,
      position: position,
      leading: leading,
      trailing: trailing,
      onClose: onClose,
      showTimer: showTimer,
      timerColor: timerColor,
    );

    // ✅ Agar abhi koi snackbar chal raha hai → queue mein daalo
    if (_currentOverlay != null) {
      _overlayPendingQueue.add(args);
      return;
    }

    _showFromArgs(args);
  }

  // ── Actual overlay insert ─────────────────────────────────────────────────

  static void _showFromArgs(_OverlayArgs a) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SnackBarOverlay(
        message: a.message,
        icon: a.icon,
        backgroundColor: a.backgroundColor,
        borderRadius: a.borderRadius,
        elevation: a.elevation,
        borderColor: a.borderColor,
        borderWidth: a.borderWidth,
        width: a.width,     // ✅ use karo
        height: a.height,   // ✅ use karo
        animation: a.animation,
        animationDuration: theme.animationDuration,
        textStyle: a.textStyle,
        showClose: a.showClose,
        leading: a.leading,
        trailing: a.trailing,
        position: a.position,
        duration: a.duration,
        showTimer: a.showTimer,
        timerColor: a.timerColor,
        onDismiss: () {
          _removeCurrentOverlay();
          a.onClose?.call();
        },
      ),
    );

    _currentOverlay = entry;
    Overlay.of(a.context).insert(entry);

    // Cancellable timer
    _dismissTimer?.cancel();
    _dismissTimer = Timer(a.duration, _removeCurrentOverlay);
  }

  static void _removeCurrentOverlay() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      _currentOverlay!.remove();
    }
    _currentOverlay = null;

    // ✅ Queue mein kuch hai? → next show karo
    if (_overlayPendingQueue.isNotEmpty) {
      final next = _overlayPendingQueue.removeAt(0);
      // Thoda gap dene ke liye — feels natural
      Timer(const Duration(milliseconds: 150), () => _showFromArgs(next));
    }
  }

  // ── With action button ─────────────────────────────────────────────────────

  static void showWithAction(
      BuildContext? context,
      String message, {
        required String actionLabel,
        required VoidCallback onAction,
        bool showClose = true,
        SnackBarType type = SnackBarType.info,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        Duration queueGap = const Duration(milliseconds: 300),
        // ✅ Per-call icon override.
        // Priority: per-call icon → theme.successIcon/errorIcon/… → built-in default
        IconData? icon,
        // ✅ Optional icon shown inside the action button, left of the label.
        // If null, only the label text is shown.
        //
        // Example:
        //   AppSnackBar.showWithAction(context, 'Deleted',
        //     actionLabel: 'UNDO',
        //     actionIcon: Icons.undo_rounded,
        //     onAction: restoreItem,
        //   );
        IconData? actionIcon,
      }) {
    final config = theme.resolve(type);
    final effectiveIcon = icon ?? config.icon;
    final effectiveBg = backgroundColor ?? config.backgroundColor;
    final effectiveRadius = borderRadius ?? theme.borderRadius;
    final effectiveElevation = elevation ?? theme.elevation;
    final effectiveAnimation = animation ?? theme.defaultAnimation;
    final effectiveBorderColor = borderColor ?? theme.borderColor;
    final effectiveBorderWidth = borderWidth ?? theme.borderWidth;
    final effectiveDuration = duration ?? theme.defaultDuration ?? const Duration(seconds: 4);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ actionIcon is optional — only rendered when developer provides it
            if (actionIcon != null) ...[
              Icon(actionIcon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    if (useQueue) {
      final messenger = _resolveMessenger(context);
      if (messenger == null) return;
      _ensureQueue()?.add(
        _buildFlutterSnackBar(
          message: message,
          icon: effectiveIcon,
          backgroundColor: effectiveBg,
          borderRadius: effectiveRadius,
          elevation: effectiveElevation,
          borderColor: effectiveBorderColor,
          borderWidth: effectiveBorderWidth,
          textStyle: effectiveTextStyle,
          showClose: showClose,
          trailing: actionWidget,
          // duration: duration,
          duration: effectiveDuration,
          position: position,
          messengerKey: messengerKey,
          context: context,
        ),
        gap: queueGap,
      );
      return;
    }

    _showOverlay(
      context,
      message,
      icon: effectiveIcon,
      backgroundColor: effectiveBg,
      borderRadius: effectiveRadius,
      elevation: effectiveElevation,
      borderColor: effectiveBorderColor,
      borderWidth: effectiveBorderWidth,
      width: width,
      height: height,
      animation: effectiveAnimation,
      // duration: duration,
      duration: effectiveDuration,
      showClose: showClose,
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
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? borderRadius,
        double? elevation,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        bool showClose = true,
        // ✅ Per-call icon override (shown when no custom leading widget is used).
        // Priority: per-call icon → theme.successIcon/errorIcon/… → built-in default
        IconData? icon,
        // ✅ Custom progress indicator — pass any widget.
        // If null, the default white CircularProgressIndicator is used.
        //
        // Examples:
        //   progressIndicator: const CircularProgressIndicator(
        //     strokeWidth: 2, color: Colors.amber),
        //   progressIndicator: const LinearProgressIndicator(),
        //   progressIndicator: MyBrandedSpinner(),
        Widget? progressIndicator,
      }) {
    // ✅ Developer's widget wins; fallback = default white spinner
    final effectiveSpinner = progressIndicator ??
      const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );

    final config = theme.resolve(type);
    final effectiveIcon = icon ?? config.icon;
    final effectiveDuration = duration ?? theme.defaultDuration ?? const Duration(seconds: 10);
    final effectiveTextStyle = textStyle ??
      theme.textStyle ??
      TextStyle(
        color: Colors.white,
        fontSize: fontSize ?? theme.fontSize,
        fontWeight: FontWeight.w500,
      );
    final effectiveBg = backgroundColor ?? config.backgroundColor;
    final effectiveRadius = borderRadius ?? theme.borderRadius;
    final effectiveElevation = elevation ?? theme.elevation;
    final effectiveBorderColor = borderColor ?? theme.borderColor;
    final effectiveBorderWidth = borderWidth ?? theme.borderWidth;

    if (useQueue) {
      final messenger = _resolveMessenger(context);
      if (messenger == null) return;
      _ensureQueue()?.add(
        _buildFlutterSnackBar(
          message: message,
          icon: effectiveIcon,
          backgroundColor: effectiveBg,
          borderRadius: effectiveRadius,
          elevation: effectiveElevation,
          borderColor: effectiveBorderColor,
          borderWidth: effectiveBorderWidth,
          textStyle: effectiveTextStyle,
          showClose: false,
          leading: effectiveSpinner,
          duration: effectiveDuration,
          position: position,
          messengerKey: messengerKey,
          context: context,
        ),
      );
      return;
    }

    _showOverlay(
      context,
      message,
      icon: effectiveIcon,
      backgroundColor: effectiveBg,
      borderRadius: effectiveRadius,
      elevation: effectiveElevation,
      borderColor: effectiveBorderColor,
      borderWidth: effectiveBorderWidth,
      width: width,
      height: height,
      animation: theme.defaultAnimation,
      // duration: duration,
      duration: effectiveDuration,
      showClose: showClose,
      leading: effectiveSpinner,
      textStyle: effectiveTextStyle,
      position: position,
    );
  }

  // ── Queue ──────────────────────────────────────────────────────────────────

  static void clearQueue() {
    _queue?.clear();
    _overlayPendingQueue.clear(); // ✅ overlay queue bhi clear
    _removeCurrentOverlay();
  }

  static int get queueLength =>
      (_queue?.length ?? 0) + _overlayPendingQueue.length;

  // ── Hide ──────────────────────────────────────────────────────────────────

  static void hide(BuildContext? context) {
    _removeCurrentOverlay();
    _resolveMessenger(context)?.hideCurrentSnackBar();
  }

  // ── Shortcuts (all include borderColor + borderWidth) ─────────────────────

  static void success(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        bool? showTimer,
        Color? timerColor,
        // ✅ Per-call icon override. Priority: per-call → theme icon → built-in default
        IconData? icon,
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
          borderColor: borderColor,
          borderWidth: borderWidth,
          width: width,
          height: height,
          showTimer: showTimer,
          timerColor: timerColor,
          icon: icon,
          onClose: onClose);

  static void error(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        bool? showTimer,
        Color? timerColor,
        // ✅ Per-call icon override. Priority: per-call → theme icon → built-in default
        IconData? icon,
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
          borderColor: borderColor,
          borderWidth: borderWidth,
          width: width,
          height: height,
          showTimer: showTimer,
          timerColor: timerColor,
          icon: icon,
          onClose: onClose);

  static void warning(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        bool? showTimer,
        Color? timerColor,
        // ✅ Per-call icon override. Priority: per-call → theme icon → built-in default
        IconData? icon,
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
          borderColor: borderColor,
          borderWidth: borderWidth,
          width: width,
          height: height,
          showTimer: showTimer,
          timerColor: timerColor,
          icon: icon,
          onClose: onClose);

  static void info(BuildContext? context, String message,
      {bool showClose = true,
        SnackBarPosition position = SnackBarPosition.bottom,
        SnackBarAnimation? animation,
        Duration? duration,
        Color? backgroundColor,
        TextStyle? textStyle,
        double? fontSize,
        double? elevation,
        double? borderRadius,
        Color? borderColor,
        double? borderWidth,
        double? width,
        double? height,
        bool? showTimer,
        Color? timerColor,
        // ✅ Per-call icon override. Priority: per-call → theme icon → built-in default
        IconData? icon,
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
          borderColor: borderColor,
          borderWidth: borderWidth,
          width: width,
          height: height,
          showTimer: showTimer,
          timerColor: timerColor,
          icon: icon,
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
    required double borderWidth,
    required TextStyle textStyle,
    required bool showClose,
    required Duration duration,
    required SnackBarPosition position,
    Color? borderColor,
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
        side: borderColor != null
            ? BorderSide(color: borderColor, width: borderWidth)
            : BorderSide.none,
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
  final Color? borderColor;
  final double borderWidth;
  final double? width;   // ✅ null = full width (left:16, right:16)
  final double? height;  // ✅ null = wrap content
  final SnackBarAnimation animation;
  final Duration animationDuration;
  final Duration duration;
  final bool showTimer;
  final Color? timerColor;
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
    required this.borderWidth,
    required this.animation,
    required this.animationDuration,
    required this.duration,
    required this.textStyle,
    required this.showClose,
    required this.position,
    required this.onDismiss,
    this.showTimer = false,
    this.timerColor,
    this.borderColor,
    this.width,
    this.height,
    this.leading,
    this.trailing,
  });

  @override
  State<_SnackBarOverlay> createState() => _SnackBarOverlayState();
}

class _SnackBarOverlayState extends State<_SnackBarOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  // Timer progress bar
  late final AnimationController _timerCtrl;
  late final Animation<double> _timerProgress;

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

    unawaited(_ctrl.forward());

    // ✅ Timer progress bar — 1.0 → 0.0 over the full snackbar duration
    _timerCtrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _timerProgress = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerCtrl, curve: Curves.linear),
    );
    if (widget.showTimer) {
      unawaited(_timerCtrl.forward());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timerCtrl.dispose();
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

    // ✅ Border logic:
    // 1. User ne borderColor diya     → woh use karo
    // 2. Background transparent hai   → automatically white border
    // 3. Kuch nahi                    → no border
    final effectiveBorderColor = widget.borderColor ??
        (widget.backgroundColor == Colors.transparent ? Colors.white : null);

    return Positioned(
      // ✅ Top: below status bar | Bottom: above navigation bar
      top: isTop ? mq.padding.top + 12 : null,
      bottom: isTop ? null : mq.padding.bottom + 12,
      // ✅ Custom width: center karo, warna full width
      left: widget.width != null
          ? (mq.size.width - widget.width!) / 2
          : 16,
      right: widget.width != null ? null : 16,
      child: Material(
        color: Colors.transparent,
        child: _applyAnimation(
          Container(
            width: widget.width,   // ✅ custom width
            height: widget.height, // ✅ custom height
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              // ✅ Border: user-defined > transparent auto > none
              border: effectiveBorderColor != null
                  ? Border.all(
                color: effectiveBorderColor,
                width: widget.borderWidth,
              )
                  : null,
              // ✅ Shadow: skip when transparent bg
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: widget.elevation * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
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
                // ✅ Timer progress bar — only shown when showTimer is true
                if (widget.showTimer)
                  AnimatedBuilder(
                    animation: _timerProgress,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(widget.borderRadius),
                        bottomRight: Radius.circular(widget.borderRadius),
                      ),
                      child: LinearProgressIndicator(
                        value: _timerProgress.value,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.timerColor ?? Colors.white54,
                        ),
                      ),
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

// ── Internal data class for overlay queue ─────────────────────────────────────

class _OverlayArgs {
  final BuildContext context;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final Color? borderColor;
  final double borderWidth;
  final double? width;    // ✅ back aa gaya
  final double? height;   // ✅ back aa gaya
  final SnackBarAnimation animation;
  final Duration duration;
  final bool showClose;
  final TextStyle textStyle;
  final SnackBarPosition position;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onClose;
  final bool showTimer;
  final Color? timerColor;

  const _OverlayArgs({
    required this.context,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderRadius,
    required this.elevation,
    required this.borderWidth,
    required this.animation,
    required this.duration,
    required this.showClose,
    required this.textStyle,
    required this.position,
    this.width,
    this.height,
    this.borderColor,
    this.leading,
    this.trailing,
    this.onClose,
    this.showTimer = false,
    this.timerColor,
  });
}
