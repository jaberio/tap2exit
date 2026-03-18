package com.example.tap2exit

import android.app.Activity
import android.os.Build
import android.widget.Toast
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Tap2exitPlugin — Native Android handler for tap2exit.
 *
 * Provides methods via a MethodChannel:
 * - `exitApp`                 : safely closes the app using `Activity.finishAffinity()`.
 * - `showToast`               : displays a native Android Toast message.
 * - `enableBackInterception`  : registers an `OnBackInvokedCallback` (API 33+) so that
 *                               back events on the root route are forwarded to Flutter
 *                               instead of letting the OS exit the app.
 * - `disableBackInterception` : unregisters the callback.
 */
class Tap2exitPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    // Stored reference so we can unregister later (API 33+).
    private var backCallback: Any? = null

    // ── FlutterPlugin ────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.tap2exit/exit")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── ActivityAware ────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterBackCallback()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        unregisterBackCallback()
        activity = null
    }

    // ── MethodCallHandler ────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "exitApp" -> {
                val currentActivity = activity
                if (currentActivity != null) {
                    currentActivity.finishAffinity()
                    result.success(null)
                } else {
                    result.error("NO_ACTIVITY", "Activity is not available.", null)
                }
            }
            "showToast" -> {
                val message = call.argument<String>("message")
                val currentActivity = activity
                if (message != null && currentActivity != null) {
                    Toast.makeText(
                        currentActivity.applicationContext,
                        message,
                        Toast.LENGTH_SHORT
                    ).show()
                    result.success(null)
                } else {
                    result.error(
                        "INVALID_ARGUMENT",
                        "Message is null or activity is not available.",
                        null
                    )
                }
            }
            "enableBackInterception" -> {
                registerBackCallback()
                result.success(null)
            }
            "disableBackInterception" -> {
                unregisterBackCallback()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ── Predictive-back helpers (API 33+) ────────────────────────────────

    private fun registerBackCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val currentActivity = activity ?: return

        // Avoid double-registration.
        if (backCallback != null) return

        val callback = android.window.OnBackInvokedCallback {
            // Forward the back event to Flutter so the Dart-side
            // double-tap logic can run.
            channel.invokeMethod("onBackPressed", null)
        }
        currentActivity.onBackInvokedDispatcher.registerOnBackInvokedCallback(
            android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT,
            callback
        )
        backCallback = callback
    }

    private fun unregisterBackCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val currentActivity = activity ?: return
        val callback = backCallback ?: return

        currentActivity.onBackInvokedDispatcher.unregisterOnBackInvokedCallback(
            callback as android.window.OnBackInvokedCallback
        )
        backCallback = null
    }
}
