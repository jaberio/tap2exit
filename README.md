# tap2exit

A Flutter plugin providing **double-tap-to-exit** functionality for Android with native Toast support and safe iOS handling.

[![pub package](https://img.shields.io/pub/v/tap2exit.svg)](https://pub.dev/packages/tap2exit)
[![GitHub](https://img.shields.io/github/license/jaberio/tap2exit)](https://github.com/jaberio/tap2exit/blob/main/LICENSE)

## Features

- 🔙 Intercepts back button presses — shows a message on the first press, exits on the second.
- ⏱️ Configurable time window for the double-tap detection.
- 💬 SnackBar message by default — fully customisable style.
- 📱 Optional native Android Toast via a simple boolean flag.
- 🎨 Toast customisation — control duration and screen position.
- 🍎 Safe no-op on iOS — no app rejection risk.
- 🎯 Exit callback for cleanup before the app closes.
- 📦 Zero external dependencies.

## Android 13+ Setup (Required)

> **Important:** For Android 13+ (API 33+) predictive back support, you **must** add the following attribute to your `<application>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:enableOnBackInvokedCallback="true"
    ...>
```

Without this, the OS will close your activity immediately on back press — bypassing `Tap2Exit` entirely.

This enables the native `OnBackInvokedCallback` that `tap2exit` registers to intercept back events at the OS level, before the activity is destroyed.

## Installation

Add `tap2exit` to your `pubspec.yaml`:

```yaml
dependencies:
  tap2exit: ^1.3.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

Wrap your top-level page widget with `Tap2Exit`:

```dart
import 'package:tap2exit/tap2exit.dart';

@override
Widget build(BuildContext context) {
  return Tap2Exit(
    child: Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: const Center(child: Text('Hello!')),
    ),
  );
}
```

## Parameters

| Parameter            | Type                                        | Default                      | Description                                                    |
| -------------------- | ------------------------------------------- | ---------------------------- | -------------------------------------------------------------- |
| `child`              | `Widget`                                    | **required**                 | The widget to wrap.                                            |
| `message`            | `String`                                    | `'Press back again to exit'` | Message shown on the first back press.                         |
| `duration`           | `Duration`                                  | `Duration(seconds: 2)`       | Time window for the second press to trigger exit.              |
| `useToast`           | `bool`                                      | `false`                      | Use native Android Toast instead of SnackBar.                  |
| `toastDuration`      | `ToastDuration`                             | `ToastDuration.short`        | Native toast display length (`short` ≈ 2 s, `long` ≈ 3.5 s).  |
| `toastGravity`       | `ToastGravity?`                             | `null`                       | Native toast position (`bottom`, `center`, `top`).             |
| `onExit`             | `VoidCallback?`                             | `null`                       | Callback invoked just before the app exits.                    |
| `onFirstBackPress`   | `VoidCallback?`                             | `null`                       | Callback invoked on the first back press.                      |
| `onBackFirstPress`   | `void Function(BuildContext)?`              | `null`                       | Replaces Toast/SnackBar entirely — show your own custom Dart UI. |
| `snackBarStyle`      | `Tap2ExitSnackBarStyle?`                    | `null`                       | Customise SnackBar appearance.                                 |
| `customMessageWidget`| `Widget Function(BuildContext, String)?`    | `null`                       | Custom overlay widget for the first-press message.             |

## Advanced Usage

### Custom SnackBar Styling

```dart
Tap2Exit(
  snackBarStyle: Tap2ExitSnackBarStyle(
    backgroundColor: Colors.black87,
    textStyle: const TextStyle(color: Colors.white, fontSize: 16),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  ),
  child: MyHomePage(),
)
```

### Native Toast on Android

```dart
Tap2Exit(
  useToast: true,
  child: MyHomePage(),
)
```

### Toast Customisation

```dart
Tap2Exit(
  useToast: true,
  toastDuration: ToastDuration.long,
  toastGravity: ToastGravity.center,
  child: MyHomePage(),
)
```

### Custom First-Press UI (replaces Toast)

Use `onBackFirstPress` to replace the default Toast/SnackBar with any Dart UI:

```dart
Tap2Exit(
  useToast: true,
  onBackFirstPress: (context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap back again to exit')),
    );
  },
  child: MyHomePage(),
)
```

### Exit Callback

```dart
Tap2Exit(
  onExit: () async {
    await saveUserData();
    debugPrint('Goodbye!');
  },
  child: MyHomePage(),
)
```

## Platform Behaviour

| Platform | `exitApp`                          | `showToast`                 |
| -------- | ---------------------------------- | --------------------------- |
| Android  | `Activity.finishAffinity()`        | Native `Toast.makeText()`   |
| iOS      | No-op (not allowed by Apple)       | No-op (falls back to SnackBar in Flutter) |

## How Back Interception Works

On **Android 13+ (API 33+)**, `tap2exit` registers a native `OnBackInvokedCallback` to intercept back events at the OS level. `PopScope` sets `canPop: true` so it stays out of the way — only the native callback fires.

On **pre-13 / non-Android** platforms, no native callback is registered. `PopScope` sets `canPop: false` and intercepts back presses via `onPopInvokedWithResult`.

This two-layer strategy prevents the back handler from double-firing on any API level.

## Example

A fully working example app is included in the [`example/`](example/) directory. Run it with:

```bash
cd example
flutter run
```

## License

MIT — see [LICENSE](LICENSE) for details.
