/// A Flutter plugin providing double-tap-to-exit functionality.
///
/// Wraps a child widget and intercepts back button presses. On the first press,
/// a message is displayed (via SnackBar or native Android Toast). On a second
/// press within a configurable duration, the app exits.
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

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides static access to the platform channel for exiting the app and
/// showing native Toast messages.
class Tap2ExitPlatform {
  Tap2ExitPlatform._();

  /// The method channel used to communicate with the native platform.
  static const MethodChannel _channel =
      MethodChannel('com.example.tap2exit/exit');

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
  /// On iOS, this is a safe no-op.
  static Future<void> showToast(String message) async {
    try {
      await _channel.invokeMethod<void>('showToast', {'message': message});
    } on PlatformException catch (_) {
      // Silently handle – not available on iOS.
    }
  }
}

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

/// A widget that provides double-tap-to-exit functionality.
///
/// Wrap your top-level page widget with [Tap2Exit] to intercept back button
/// presses. On the first press a message is shown (SnackBar by default, or
/// native Android Toast when [useToast] is `true`). If the user presses back
/// again within [duration], the app exits.
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
    this.onExit,
    this.onFirstBackPress,
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

  /// Optional callback executed just before the app exits.
  final VoidCallback? onExit;

  /// Optional callback executed on the first back press.
  final VoidCallback? onFirstBackPress;

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
    if (widget.customMessageWidget != null) {
      _showCustomOverlay();
    } else if (widget.useToast && !kIsWeb && Platform.isAndroid) {
      // Native Toast is only available on Android.
      // On iOS / web, fall back to SnackBar so the user always sees feedback.
      Tap2ExitPlatform.showToast(widget.message);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: widget.child,
    );
  }
}
