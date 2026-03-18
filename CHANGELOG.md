## 1.3.0

* **Fix**: Fixed double-firing on Android 13+ where both native `OnBackInvokedCallback` and `PopScope` intercepted the same back press. A `_nativeBackActive` flag now dynamically sets `canPop` based on whether native interception was registered.
* **Fix**: Fixed app closing directly without double-tap when `enableOnBackInvokedCallback="true"` is set but no native callback was registered.
* **Feature**: Added toast customisation — `toastDuration` (`ToastDuration.short` / `.long`) and `toastGravity` (`ToastGravity.bottom` / `.center` / `.top`).
* **Feature**: Added `onBackFirstPress` callback — when provided, replaces native Toast entirely so users can show SnackBar, overlay, or any custom Dart UI.
* **Docs**: Added prominent Android 13+ manifest setup instructions to README.

## 1.2.1

* **Feature**: Added macOS native plugin with Swift Package Manager (SPM) support.

## 1.2.0

* **Feature**: Added support for Web, Windows, macOS, and Linux platforms.
* **Feature**: Added Swift Package Manager (SPM) support for iOS.
* **Fix**: Fixed unconditional `dart:io` import that prevented web compilation.

## 1.1.0

* **Fix**: Fixed Android Kotlin crash when activity is null.
* **Fix**: Fixed window leak when showing Android Toast.
* **Feature**: Added iOS fallback for `useToast`. When enabled on iOS, it now falls back to SnackBar instead of doing nothing.
* **Feature**: Added `customMessageWidget` parameter to `Tap2Exit` for custom first-tap message builder (using `OverlayEntry`).
* **Docs**: Added topics, repository, and issue tracker to `pubspec.yaml`.

## 1.0.0

* Initial release.
* Double-tap-to-exit functionality with configurable duration.
* SnackBar message on first back press (default).
* Optional native Android Toast message support.
* Safe no-op behavior on iOS.
* Configurable exit callback via `onExit`.
