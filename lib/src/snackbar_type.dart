// success/error/warning/info
/// The visual type/style of the snackbar.
///
/// Each type maps to a default color and icon which can be
/// overridden globally via [//AppSnackBarTheme].
enum SnackBarType {
  /// ✅ Green — operation completed successfully.
  success,

  /// ❌ Red — something went wrong.
  error,

  /// ⚠️ Orange — caution or heads-up.
  warning,

  /// ℹ️ Blue/dark — neutral information.
  info,
}
