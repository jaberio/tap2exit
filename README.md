# tap2exit

A Flutter plugin providing **double-tap-to-exit** functionality for Android with native Toast support and safe iOS handling.

[![pub package](https://img.shields.io/pub/v/tap2exit.svg)](https://pub.dev/packages/tap2exit)
[![GitHub](https://img.shields.io/github/license/jaberio/tap2exit)](https://github.com/jaberio/tap2exit/blob/main/LICENSE)

## Features

- 🔙 Intercepts back button presses — shows a message on the first press, exits on the second.
- ⏱️ Configurable time window for the double-tap detection.
- 💬 SnackBar message by default — fully customisable style.
- 📱 Optional native Android Toast via a simple boolean flag.
- 🍎 Safe no-op on iOS — no app rejection risk.
- 🎯 Exit callback for cleanup before the app closes.
- 📦 Zero external dependencies.

## Installation

Add `tap2exit` to your `pubspec.yaml`:

```yaml
dependencies:
  tap2exit: ^1.0.0
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

| Parameter         | Type                    | Default                           | Description                                          |
| ----------------- | ----------------------- | --------------------------------- | ---------------------------------------------------- |
| `child`           | `Widget`                | **required**                      | The widget to wrap.                                  |
| `message`         | `String`                | `'Press back again to exit'`      | Message shown on the first back press.               |
| `duration`        | `Duration`              | `Duration(seconds: 2)`            | Time window for the second press to trigger exit.    |
| `useToast`        | `bool`                  | `false`                           | Use native Android Toast instead of SnackBar.        |
| `onExit`          | `VoidCallback?`         | `null`                            | Callback invoked just before the app exits.          |
| `onFirstBackPress`| `VoidCallback?`         | `null`                            | Callback invoked on the first back press.            |
| `snackBarStyle`   | `Tap2ExitSnackBarStyle?`| `null`                            | Customise SnackBar appearance.                       |

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

## Example

A fully working example app is included in the [`example/`](example/) directory. Run it with:

```bash
cd example
flutter run
```

## License

MIT — see [LICENSE](LICENSE) for details.
