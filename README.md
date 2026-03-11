<!-- badges + full docs -->
# app_snackbar

[![pub.dev](https://img.shields.io/pub/v/app_snackbar.svg)](https://pub.dev/packages/app_snackbar)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A beautiful, fully customizable Flutter SnackBar utility with **4 types**, **action buttons**, **loading states**, **queue support**, **slide/fade animations**, **top/bottom positioning**, **countdown timer bar**, and global **Material 3** theme override.

---
## Screenshots
<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/spatelpatidar/app_snackbar/main/screenshots/showcase.png" width="200" alt="showcase.png"/></td>
    <td><img src="https://raw.githubusercontent.com/spatelpatidar/app_snackbar/main/screenshots/error.png" width="200" alt="error.png"/></td>
    <td><img src="https://raw.githubusercontent.com/spatelpatidar/app_snackbar/main/screenshots/top_position.png" width="200" alt="top_position.png"/></td>
    <td><img src="https://raw.githubusercontent.com/spatelpatidar/app_snackbar/main/screenshots/code_preview.png" width="200" alt="code_preview.png"/></td>
  </tr>
</table>

---

## Features

| Feature | Description |
|---|---|
| **4 types** | `success` 🟢 `error` 🔴 `warning` 🟠 `info` 🔵 |
| **Action button** | Undo, Retry, View — inline chip with optional icon |
| **Loading** | Spinner for async operations — pass any custom indicator |
| **Queue** | Show one after another — override per-call |
| **Animations** | Slide, Fade, or None |
| **Position** | Top or Bottom (top always uses overlay) |
| **Timer bar** | Countdown progress bar with custom color |
| **Duration control** | Per-call or global theme default |
| **Icon override** | Per-call icon on every method |
| **messengerKey** | Visible above bottom sheets |
| **Global theme** | Override colors, icons, fonts app-wide |
| **Per-call overrides** | `backgroundColor`, `textStyle`, `fontSize`, `borderRadius`, `elevation` |
| **Custom widgets** | Custom `leading` & `trailing` |
| **Material 3** | Flutter 3.16+ ready |

---

## Installation

```yaml
dependencies:
  app_snackbar: ^1.0.4
```

```dart
import 'package:app_snackbar/app_snackbar.dart';
```

---

## Setup

Add `scaffoldMessengerKey` to your `MaterialApp` — **required** for queue and above-bottom-sheet support:

```dart
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  AppSnackBar.messengerKey = rootMessengerKey; // ✅ register once

  AppSnackBar.theme = const AppSnackBarTheme(  // ✅ optional global theme
    infoColor: Color(0xFF003249),
    defaultAnimation: SnackBarAnimation.fade,
    defaultDuration: Duration(seconds: 4),     // ✅ global duration
    showTimer: true,                            // ✅ enable timer globally
  );

  runApp(MyApp());
}

MaterialApp(
  scaffoldMessengerKey: rootMessengerKey, // ✅ required
  ...
)
```

---

## Usage

### Basic Types

```dart
AppSnackBar.success(context, 'Profile updated!');
AppSnackBar.error(context, 'Upload failed. Try again.');
AppSnackBar.warning(context, 'Download cancelled.');
AppSnackBar.info(context, 'New version available.');
```

### Per-call Icon Override

Override the icon for any single call without changing the theme.  
Priority: `per-call icon` → `AppSnackBarTheme icon` → built-in default

```dart
AppSnackBar.success(context, 'Uploaded!',
    icon: Icons.cloud_done_rounded);

AppSnackBar.error(context, 'No internet',
    icon: Icons.wifi_off_rounded);

AppSnackBar.info(context, 'Reminder set',
    icon: Icons.alarm_rounded);

// Works on every method including show()
AppSnackBar.show(context, 'Custom icon',
    icon: Icons.star_rounded);
```

### Position

```dart
AppSnackBar.success(context, 'Top!',
    position: SnackBarPosition.top);      // ⬆️

AppSnackBar.error(context, 'Bottom!',
    position: SnackBarPosition.bottom);   // ⬇️ default
```

> **Note:** `SnackBarPosition.top` always uses overlay mode internally — this is required because Flutter's `ScaffoldMessenger` renders at the bottom regardless of margin.

### Animation

```dart
AppSnackBar.info(context, 'Slide in!',
    animation: SnackBarAnimation.slide);  // default

AppSnackBar.info(context, 'Fade in!',
    animation: SnackBarAnimation.fade);

AppSnackBar.info(context, 'Instant!',
    animation: SnackBarAnimation.none);
```

### Duration

```dart
// Per-call duration:
AppSnackBar.success(context, 'Saved!',
    duration: const Duration(seconds: 5));

// Global default via theme (set once in main):
AppSnackBar.theme = const AppSnackBarTheme(
  defaultDuration: Duration(seconds: 4),
);

// Priority: per-call → theme default → built-in default (3s)
```

### Timer Bar

```dart
// Per-call:
AppSnackBar.success(context, 'Saved!',
    showTimer: true);

// With custom color:
AppSnackBar.error(context, 'Failed!',
    showTimer: true,
    timerColor: Colors.redAccent);

// Enable globally via theme:
AppSnackBar.theme = const AppSnackBarTheme(
  showTimer: true,
  timerColor: Colors.white70,
);
```

### With Action Button

```dart
// Label only
AppSnackBar.showWithAction(
  context,
  'Message deleted.',
  actionLabel: 'Undo',
  type: SnackBarType.warning,
  onAction: () => _restoreMessage(),
);

// With icon left of label
AppSnackBar.showWithAction(
  context,
  'Item deleted.',
  actionLabel: 'Undo',
  actionIcon: Icons.undo_rounded,   // ✅ new in 1.0.4
  onAction: () => _restoreItem(),
);
```

### Loading Snackbar

```dart
// Default white spinner
AppSnackBar.showLoading(context, 'Uploading photo...');

// Custom indicator — pass any widget
AppSnackBar.showLoading(
  context,
  'Processing...',
  progressIndicator: CircularProgressIndicator(color: Colors.amber), // ✅ new in 1.0.4
);

AppSnackBar.showLoading(
  context,
  'Syncing...',
  progressIndicator: LinearProgressIndicator(),
);

// Replace with result when done:
AppSnackBar.showLoading(context, 'Uploading photo...');
await uploadPhoto();
if (context.mounted) AppSnackBar.success(context, 'Upload complete! ✅');

// Or just hide:
AppSnackBar.hide(context);
```

### Queue Mode

```dart
AppSnackBar.useQueue = true;  // enable once (default: true)

AppSnackBar.success(null, 'Step 1: Data saved ✅');
AppSnackBar.info(null, 'Step 2: Syncing...');
AppSnackBar.success(null, 'Step 3: All done! 🎉');
// Each appears after the previous finishes ✅

// Skip the queue for one specific call:
AppSnackBar.error(context, 'Critical error!',
    useQueue: false);   // ✅ new in 1.0.4

AppSnackBar.clearQueue(); // cancel all pending
```

### Above Bottom Sheet

```dart
// Set messengerKey (see Setup above), then:
showModalBottomSheet(context: context, builder: (_) => Column(
  children: [
    ElevatedButton(
      // Pass null — uses messengerKey — shows ABOVE the sheet ✅
      onPressed: () => AppSnackBar.success(null, 'Visible!'),
      child: Text('Show'),
    ),
  ],
));
```

### Per-call Overrides

```dart
AppSnackBar.show(
  context,
  'Fully custom!',
  type: SnackBarType.error,
  icon: Icons.wifi_off_rounded,          // custom icon
  backgroundColor: Colors.deepPurple,   // custom color
  fontSize: 16,                          // bigger text
  borderRadius: 8,                       // sharper corners
  elevation: 12,                         // deeper shadow
  duration: const Duration(seconds: 5),  // custom duration
  position: SnackBarPosition.top,
  animation: SnackBarAnimation.fade,
  showClose: true,
  showTimer: true,                       // countdown bar
  timerColor: Colors.white54,            // timer bar color
  useQueue: false,                       // skip queue for this call
  onClose: () => debugPrint('Dismissed'),
);
```

### Custom Leading / Trailing

```dart
// Custom avatar
AppSnackBar.show(context, 'New message from Ali',
  leading: CircleAvatar(radius: 14, child: Text('A')),
);

// Custom action button
AppSnackBar.show(context, 'File ready',
  showClose: false,
  trailing: TextButton(
    onPressed: () => _openFile(),
    child: Text('Open', style: TextStyle(color: Colors.white)),
  ),
);
```

### Global Theme Override

```dart
AppSnackBar.theme = const AppSnackBarTheme(
  // Colors
  successColor: Colors.teal,
  errorColor: Color(0xFFC62828),
  warningColor: Colors.deepOrange,
  infoColor: Color(0xFF003249),

  // Icons (overridable per-call too)
  successIcon: Icons.done_all_rounded,
  errorIcon: Icons.cancel_outlined,
  warningIcon: Icons.warning_amber_rounded,
  infoIcon: Icons.info_outline_rounded,

  // Typography
  fontSize: 15,
  textStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),

  // Shape
  borderRadius: 12,
  elevation: 8,

  // Animation
  defaultAnimation: SnackBarAnimation.fade,
  animationDuration: Duration(milliseconds: 250),

  // Duration & Timer
  defaultDuration: Duration(seconds: 4),
  showTimer: true,
  timerColor: Colors.white60,
);
```

---

## API Reference

### AppSnackBar

| Method | Description |
|---|---|
| `success(ctx, msg, {icon, useQueue, ...})` | ✅ Green snackbar |
| `error(ctx, msg, {icon, useQueue, ...})` | ❌ Red snackbar |
| `warning(ctx, msg, {icon, useQueue, ...})` | ⚠️ Orange snackbar |
| `info(ctx, msg, {icon, useQueue, ...})` | ℹ️ Brand-color snackbar |
| `show(ctx, msg, {...})` | Full control |
| `showWithAction(..., {actionIcon})` | Action chip with optional icon |
| `showLoading(ctx, msg, {progressIndicator})` | Custom or default spinner |
| `hide(ctx)` | Dismiss current |
| `clearQueue()` | Cancel all queued |
| `queueLength` | Pending queue count |

### AppSnackBarTheme

| Property | Type | Default                |
|---|---|------------------------|
| `successColor` | `Color?` | `#2E7D32` 🟢           |
| `errorColor` | `Color?` | `#C62828` 🔴           |
| `warningColor` | `Color?` | `#E65100` 🟠           |
| `infoColor` | `Color?` | `#003249` 🔵           |
| `successIcon` | `IconData?` | material rounded icons |
| `errorIcon` | `IconData?` | material rounded icon  |
| `warningIcon` | `IconData?` | material rounded icon  |
| `infoIcon` | `IconData?` | material rounded icon  |
| `textStyle` | `TextStyle?` | `null`                 |
| `fontSize` | `double` | `14`                   |
| `borderRadius` | `double` | `16`                   |
| `elevation` | `double` | `6`                    |
| `defaultAnimation` | `SnackBarAnimation` | `.slide`               |
| `animationDuration` | `Duration` | `300ms`                |
| `defaultDuration` | `Duration?` | `null` (3s fallback)   |
| `showTimer` | `bool` | `false`                |
| `timerColor` | `Color?` | `Colors.white54`       |

### Per-call Parameters

| Parameter | Type | Description |
|---|---|---|
| `type` | `SnackBarType` | Snackbar style |
| `position` | `SnackBarPosition` | Top or bottom |
| `animation` | `SnackBarAnimation` | Entrance animation |
| `duration` | `Duration?` | How long to show |
| `icon` | `IconData?` | Icon override for this call |
| `backgroundColor` | `Color?` | Custom background |
| `fontSize` | `double?` | Text size override |
| `textStyle` | `TextStyle?` | Full text style override |
| `borderRadius` | `double?` | Corner radius |
| `elevation` | `double?` | Shadow depth |
| `showClose` | `bool` | Show close button |
| `showTimer` | `bool?` | Show countdown bar |
| `timerColor` | `Color?` | Timer bar color |
| `useQueue` | `bool?` | Queue override for this call |
| `leading` | `Widget?` | Custom leading widget |
| `trailing` | `Widget?` | Custom trailing widget |
| `onClose` | `VoidCallback?` | On dismiss callback |

### `showWithAction()` extra params

| Parameter | Type | Description |
|---|---|---|
| `actionLabel` | `String` | **Required.** Button label |
| `onAction` | `VoidCallback` | **Required.** Button callback |
| `actionIcon` | `IconData?` | Optional icon left of label |

### `showLoading()` extra params

| Parameter | Type | Description |
|---|---|---|
| `progressIndicator` | `Widget?` | Custom widget. Defaults to white `CircularProgressIndicator` |

### Enums

| Enum | Values |
|---|---|
| `SnackBarType` | `success`, `error`, `warning`, `info` |
| `SnackBarPosition` | `bottom`, `top` |
| `SnackBarAnimation` | `slide`, `fade`, `none` |

---

## License

MIT — see [LICENSE](LICENSE)
