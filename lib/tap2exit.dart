/// A Flutter plugin providing double-tap-to-exit functionality.
///
/// Wraps a child widget and intercepts back button presses. On the first press,
/// a message is displayed (via SnackBar or native Android Toast). On a second
/// press within a configurable duration, the app exits.
///
/// Supports Android 14+ predictive back gestures automatically — a native
/// `OnBackInvokedCallback` intercepts back events even on the root route.
///
/// ## Usage
///
/// ```dart
/// Tap2Exit(
///   message: 'Press back again to exit',
///   duration: Duration(seconds: 2),
///   child: MyHomePage(),
/// )
/// ```
library tap2exit;

import 'src/platform_stub.dart'
    if (dart.library.io) 'src/platform_io.dart'
    if (dart.library.html) 'src/platform_web.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Toast enums ──────────────────────────────────────────────────────────

/// Controls how long the native Android Toast is displayed.
enum ToastDuration {
  /// Displays for approximately 2 seconds (`Toast.LENGTH_SHORT`).
  short,

  /// Displays for approximately 3.5 seconds (`Toast.LENGTH_LONG`).
  long,
}

/// Controls where the native Android Toast appears on screen.
///
/// Maps to the corresponding `android.view.Gravity` constants.
enum ToastGravity {
  /// Bottom of the screen — the default Android Toast position.
  bottom(0x50), // Gravity.BOTTOM

  /// Centre of the screen.
  center(0x11), // Gravity.CENTER

  /// Top of the screen.
  top(0x30); // Gravity.TOP

  /// Creates a [ToastGravity] with the given Android `Gravity` constant.
  const ToastGravity(this.value);

  /// The raw Android `Gravity` integer value.
  final int value;
}

// ── Platform channel ─────────────────────────────────────────────────────

/// Provides static access to the platform channel for exiting the app and
/// showing native Toast messages.
class Tap2ExitPlatform {
  Tap2ExitPlatform._();

  /// The method channel used to communicate with the native platform.
  static const MethodChannel _channel =
      MethodChannel('com.example.tap2exit/exit');

  /// Returns the shared [MethodChannel] so the widget can set a call handler.
  static MethodChannel get channel => _channel;

  /// Exits the app using platform-safe methods.
  ///
  /// On Android, this calls `Activity.finishAffinity()`.
  /// On iOS, this is a safe no-op (iOS does not allow programmatic exit).
  static Future<void> exitApp() async {
    try {
      await _channel.invokeMethod<void>('exitApp');
    } on PlatformException catch (_) {
      // Silently handle – iOS returns nil, and we don't want to crash.
    }
  }

  /// Shows a native Toast message on Android.
  ///
  /// [toastDuration] controls display length (`LENGTH_SHORT` vs `LENGTH_LONG`).
  /// [toastGravity] controls positioning (bottom, center, or top).
  ///
  /// On iOS, this is a safe no-op.
  static Future<void> showToast(
    String message, {
    ToastDuration toastDuration = ToastDuration.short,
    ToastGravity? toastGravity,
  }) async {
    try {
      await _channel.invokeMethod<void>('showToast', {
        'message': message,
        'isLong': toastDuration == ToastDuration.long,
        if (toastGravity != null) 'gravity': toastGravity.value,
      });
    } on PlatformException catch (_) {
      // Silently handle – not available on iOS.
    }
  }

  /// Registers a native `OnBackInvokedCallback` on Android 13+ (API 33+).
  ///
  /// This ensures that back events are forwarded to Flutter even on the root
  /// route when `enableOnBackInvokedCallback="true"` is set in the manifest.
  ///
  /// Returns `true` if the native callback was successfully registered,
  /// `false` otherwise (pre-API 33 or non-Android).
  static Future<bool> enableBackInterception() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('enableBackInterception');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Unregisters the native `OnBackInvokedCallback`.
  static Future<void> disableBackInterception() async {
    try {
      await _channel.invokeMethod<void>('disableBackInterception');
    } on PlatformException catch (_) {
      // Silently handle.
    }
  }
}

// ── SnackBar style ───────────────────────────────────────────────────────

/// Configuration for the SnackBar appearance shown on the first back press.
///
/// Use this to customise the look and feel of the SnackBar message.
///
/// ```dart
/// Tap2Exit(
///   snackBarStyle: Tap2ExitSnackBarStyle(
///     backgroundColor: Colors.black87,
///     textStyle: TextStyle(color: Colors.white, fontSize: 16),
///     behavior: SnackBarBehavior.floating,
///     margin: EdgeInsets.all(16),
///     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
///   ),
///   child: MyHomePage(),
/// )
/// ```
class Tap2ExitSnackBarStyle {
  /// Creates a [Tap2ExitSnackBarStyle].
  const Tap2ExitSnackBarStyle({
    this.backgroundColor,
    this.textStyle,
    this.duration,
    this.behavior,
    this.shape,
    this.margin,
    this.padding,
    this.elevation,
  });

  /// Background colour of the SnackBar.
  final Color? backgroundColor;

  /// Text style for the SnackBar message.
  final TextStyle? textStyle;

  /// How long the SnackBar is visible. Defaults to 2 seconds.
  final Duration? duration;

  /// Whether the SnackBar is fixed or floating.
  final SnackBarBehavior? behavior;

  /// Shape of the SnackBar.
  final ShapeBorder? shape;

  /// Margin around the SnackBar (only applies when [behavior] is
  /// [SnackBarBehavior.floating]).
  final EdgeInsetsGeometry? margin;

  /// Padding inside the SnackBar.
  final EdgeInsetsGeometry? padding;

  /// Elevation of the SnackBar.
  final double? elevation;
}

// ── Main widget ──────────────────────────────────────────────────────────

/// A widget that provides double-tap-to-exit functionality.
///
/// Wrap your top-level page widget with [Tap2Exit] to intercept back button
/// presses. On the first press a message is shown (SnackBar by default, or
/// native Android Toast when [useToast] is `true`). If the user presses back
/// again within [duration], the app exits.
///
/// On **Android 13+** with `enableOnBackInvokedCallback="true"` set in the
/// manifest, this widget automatically registers a native
/// `OnBackInvokedCallback` to intercept back events even on the root route
/// (where Flutter's `PopScope` would otherwise not fire).
///
/// The widget dynamically sets `PopScope.canPop` based on whether native
/// interception was successfully registered, preventing back events from
/// double-firing.
///
/// {@tool snippet}
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Tap2Exit(
///     message: 'Press back again to exit',
///     duration: const Duration(seconds: 2),
///     useToast: false,
///     onExit: () => debugPrint('Exiting!'),
///     child: const Scaffold(
///       body: Center(child: Text('Hello')),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
class Tap2Exit extends StatefulWidget {
  /// Creates a [Tap2Exit] widget.
  const Tap2Exit({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.duration = const Duration(seconds: 2),
    this.useToast = false,
    this.toastDuration = ToastDuration.short,
    this.toastGravity,
    this.onExit,
    this.onFirstBackPress,
    this.onBackFirstPress,
    this.snackBarStyle,
    this.customMessageWidget,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The message displayed on the first back press.
  ///
  /// Defaults to `'Press back again to exit'`.
  final String message;

  /// The time window in which a second back press will exit the app.
  ///
  /// Defaults to 2 seconds.
  final Duration duration;

  /// Whether to use native Android Toast instead of a Flutter SnackBar.
  ///
  /// On iOS this flag is ignored; the SnackBar is always used as a fallback
  /// since native Toast is not available.
  final bool useToast;

  /// Controls how long the native Toast is displayed.
  ///
  /// Only applies when [useToast] is `true`. Defaults to [ToastDuration.short].
  final ToastDuration toastDuration;

  /// Controls where the native Toast appears on screen.
  ///
  /// Only applies when [useToast] is `true`. When `null`, Android uses its
  /// default position (bottom of the screen).
  final ToastGravity? toastGravity;

  /// Optional callback executed just before the app exits.
  final VoidCallback? onExit;

  /// Optional callback executed on the first back press.
  final VoidCallback? onFirstBackPress;

  /// Optional callback that **replaces** the default message UI entirely.
  ///
  /// When provided and [useToast] is `true`, this callback is invoked instead
  /// of showing a native Toast. Use it to show a SnackBar, overlay, bottom
  /// sheet, or any custom Dart UI in response to the first back press.
  ///
  /// The [BuildContext] is provided so you can use `ScaffoldMessenger.of`,
  /// `showDialog`, etc.
  final void Function(BuildContext context)? onBackFirstPress;

  /// Optional styling configuration for the SnackBar.
  ///
  /// Ignored when [useToast] is `true`.
  final Tap2ExitSnackBarStyle? snackBarStyle;

  /// Optional custom widget to display instead of a SnackBar or Toast.
  ///
  /// When provided, this widget is shown in an [OverlayEntry] on the first
  /// back press instead of the default message. Useful for custom animations
  /// or entirely bespoke messaging UI.
  final Widget Function(BuildContext context, String message)?
      customMessageWidget;

  @override
  State<Tap2Exit> createState() => _Tap2ExitState();
}

class _Tap2ExitState extends State<Tap2Exit> {
  DateTime? _lastBackPressTime;

  /// Whether a native `OnBackInvokedCallback` is actively intercepting back
  /// events. When `true`, `PopScope.canPop` is set to `true` so it stays out
  /// of the way (only the native callback fires). When `false`, `PopScope`
  /// handles back presses via `onPopInvokedWithResult`.
  bool _nativeBackActive = false;

  @override
  void initState() {
    super.initState();
    _setupNativeBackInterception();
  }

  @override
  void dispose() {
    _teardownNativeBackInterception();
    super.dispose();
  }

  /// On Android, registers a native `OnBackInvokedCallback` via the platform
  /// channel and listens for `"onBackPressed"` invocations from the native
  /// side. This is the path used on Android 13+ with predictive back enabled.
  ///
  /// If registration succeeds, `_nativeBackActive` is set to `true` and
  /// `PopScope.canPop` becomes `true` — preventing double-fire.
  void _setupNativeBackInterception() {
    if (kIsWeb) return;
    if (!isAndroid) return;

    // Listen for back events forwarded from the native callback.
    Tap2ExitPlatform.channel.setMethodCallHandler((call) async {
      if (call.method == 'onBackPressed') {
        _handleBackPress();
      }
    });

    // Ask the native side to register the OnBackInvokedCallback.
    // The result tells us whether native interception is active.
    Tap2ExitPlatform.enableBackInterception().then((registered) {
      if (mounted) {
        setState(() {
          _nativeBackActive = registered;
        });
      }
    });
  }

  void _teardownNativeBackInterception() {
    if (kIsWeb) return;
    if (!isAndroid) return;

    Tap2ExitPlatform.disableBackInterception();
    Tap2ExitPlatform.channel.setMethodCallHandler(null);
  }

  Future<void> _handleBackPress() async {
    final now = DateTime.now();
    final lastPress = _lastBackPressTime;

    if (lastPress != null && now.difference(lastPress) <= widget.duration) {
      // Second press within the duration – exit the app.
      widget.onExit?.call();
      await Tap2ExitPlatform.exitApp();
    } else {
      // First press – show a message and record the time.
      _lastBackPressTime = now;
      widget.onFirstBackPress?.call();
      _showMessage();
    }
  }

  void _showMessage() {
    // If the user provided onBackFirstPress, it replaces ALL default message
    // UI (Toast, SnackBar, overlay) entirely.
    if (widget.onBackFirstPress != null) {
      widget.onBackFirstPress!(context);
      return;
    }

    if (widget.customMessageWidget != null) {
      _showCustomOverlay();
    } else if (widget.useToast && !kIsWeb && isAndroid) {
      // Native Toast is only available on Android.
      // On iOS / web, fall back to SnackBar so the user always sees feedback.
      Tap2ExitPlatform.showToast(
        widget.message,
        toastDuration: widget.toastDuration,
        toastGravity: widget.toastGravity,
      );
    } else {
      _showSnackBar();
    }
  }

  void _showCustomOverlay() {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => widget.customMessageWidget!(context, widget.message),
    );
    overlay.insert(entry);

    // Auto-dismiss after the configured SnackBar duration or 2 seconds.
    Future.delayed(
      widget.snackBarStyle?.duration ?? const Duration(seconds: 2),
      () {
        if (entry.mounted) entry.remove();
      },
    );
  }

  void _showSnackBar() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final style = widget.snackBarStyle;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.message,
          style: style?.textStyle,
        ),
        duration: style?.duration ?? const Duration(seconds: 2),
        backgroundColor: style?.backgroundColor,
        behavior: style?.behavior,
        shape: style?.shape,
        margin: style?.margin,
        padding: style?.padding,
        elevation: style?.elevation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When native back is active (API 33+), canPop = true makes PopScope a
    // no-op — only the native OnBackInvokedCallback fires, preventing
    // double-fire.
    //
    // When native back is NOT active (pre-API 33, iOS, web), canPop = false
    // and PopScope handles back presses via onPopInvokedWithResult.
    return PopScope(
      canPop: _nativeBackActive,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: widget.child,
    );
  }
}
