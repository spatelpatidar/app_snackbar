// barrel export
/// A beautiful, fully customizable Flutter SnackBar utility.
///
/// ## Features
/// - 4 types: success, error, warning, info
/// - Action button support
/// - Loading spinner snackbar
/// - Slide & fade animations
/// - Top / bottom positioning
/// - Queue support (show one after another)
/// - rootScaffoldMessengerKey (shows above bottom sheets)
/// - Global Material 3 theme override
/// - Per-call: color, textStyle, fontSize, borderRadius, elevation overrides
/// - Custom leading / trailing widgets
///
/// ## Quick Start
/// ```dart
/// import 'package:app_snackbar/app_snackbar.dart';
///
/// AppSnackBar.success(context, 'Saved!');
/// AppSnackBar.error(context, 'Failed.');
/// ```
library app_snackbar;

export 'src/animated_snackbar_wrapper.dart';
export 'src/app_snackbar.dart';
export 'src/snackbar_animation.dart';
export 'src/snackbar_position.dart';
export 'src/snackbar_queue.dart';
export 'src/snackbar_theme.dart';
export 'src/snackbar_type.dart';
