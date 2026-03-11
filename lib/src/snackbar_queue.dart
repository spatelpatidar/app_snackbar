// FIFO queue manager
import 'dart:async';
import 'package:flutter/material.dart';

/// A single item waiting in the snackbar queue.
class _QueueItem {
  final SnackBar snackBar;
  final Duration gap;

  _QueueItem({required this.snackBar, required this.gap});
}

/// Manages a FIFO queue of [SnackBar]s, showing them one-by-one
/// with an optional gap between each.
///
/// Used internally by [//AppSnackBar] when queue mode is active.
///
/// ### Direct usage
/// ```dart
/// final queue = SnackBarQueue(messengerKey: rootMessengerKey);
/// queue.add(snackBar);
/// queue.add(anotherSnackBar);
/// queue.clear();
/// ```
class SnackBarQueue {
  /// The [ScaffoldMessengerState] key used to show snackbars.
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  final List<_QueueItem> _queue = [];
  bool _isProcessing = false;
  Timer? _gapTimer;

  /// Creates a [SnackBarQueue] bound to [messengerKey].
  SnackBarQueue({required this.messengerKey});

  /// Adds [snackBar] to the queue.
  ///
  /// [gap] is the pause between this snackbar finishing and
  /// the next one starting. Default: `300ms`
  void add(SnackBar snackBar, {Duration gap = const Duration(milliseconds: 300)}) {
    _queue.add(_QueueItem(snackBar: snackBar, gap: gap));
    if (!_isProcessing) {
      _processNext();
    }
  }

  /// Clears all pending snackbars and hides the current one.
  void clear() {
    _gapTimer?.cancel();
    _queue.clear();
    _isProcessing = false;
    messengerKey.currentState?.hideCurrentSnackBar();
  }

  /// Number of snackbars currently waiting in the queue.
  int get length => _queue.length;

  /// Whether the queue is currently showing a snackbar.
  bool get isProcessing => _isProcessing;

  void _processNext() {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }

    final messenger = messengerKey.currentState;
    if (messenger == null) {
      _queue.clear();
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final item = _queue.removeAt(0);

    // messenger.showSnackBar(item.snackBar).closed.then((_) {
    //   _gapTimer = Timer(item.gap, _processNext);
    // });
    unawaited( // ✅ explicitly marks the Future as intentionally discarded
      messenger.showSnackBar(item.snackBar).closed.then((_) {
        _gapTimer = Timer(item.gap, _processNext);
      }),
    );
  }
}
