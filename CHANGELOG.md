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
