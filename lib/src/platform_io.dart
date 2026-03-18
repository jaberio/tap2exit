import 'dart:io' show Platform;

/// Returns `true` when running on Android.
///
/// Delegates to [Platform.isAndroid] from `dart:io`.
bool get isAndroid => Platform.isAndroid;
