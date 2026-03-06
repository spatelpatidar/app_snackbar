## 1.0.0

### ✨ Initial stable release

**Types**
- 4 snackbar types: `success`, `error`, `warning`, `info`
- Shortcut methods: `AppSnackBar.success()`, `.error()`, `.warning()`, `.info()`

**Actions & Loading**
- `AppSnackBar.showWithAction()` — inline action chip (Undo, Retry, etc.)
- `AppSnackBar.showLoading()` — circular spinner for async operations

**Animation**
- `SnackBarAnimation.slide` — slides in from bottom/top (default)
- `SnackBarAnimation.fade` — smooth fade in/out
- `SnackBarAnimation.none` — instant appear/disappear
- Configurable `animationDuration` via theme

**Queue**
- `AppSnackBar.useQueue = true` — show snackbars one after another
- `AppSnackBar.clearQueue()` — cancel all pending snackbars
- `AppSnackBar.queueLength` — check pending count

**Positioning**
- `SnackBarPosition.bottom` (default)
- `SnackBarPosition.top` — shows above bottom sheets

**rootScaffoldMessengerKey support**
- `AppSnackBar.messengerKey = myKey` — always visible above bottom sheets
- Pass `null` as context to use key automatically

**Customization (per-call overrides)**
- `backgroundColor` — custom color for one snackbar
- `textStyle` — full text style override
- `fontSize` — quick font size override
- `borderRadius` — shape override
- `elevation` — shadow depth override
- `margin` — spacing override
- `leading` — custom icon/avatar widget
- `trailing` — custom close/action widget
- `showClose` — toggle close button

**Global Theme**
- `AppSnackBarTheme` — set once, applies everywhere
- Per-type color, icon, textStyle, borderRadius, elevation, animation

**Platform**
- Flutter 3.16+ / Material 3
- Dart 3.2+
