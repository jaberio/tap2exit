package com.example.tap2exit

import android.app.Activity
import android.widget.Toast
import androidx.annotation.NonNull
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
 * Provides two methods via a MethodChannel:
 * - `exitApp`  : safely closes the app using `Activity.finishAffinity()`.
 * - `showToast` : displays a native Android Toast message.
 */
class Tap2exitPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    // ── FlutterPlugin ────────────────────────────────────────────────────

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.tap2exit/exit")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── ActivityAware ────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // ── MethodCallHandler ────────────────────────────────────────────────

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "exitApp" -> {
                val currentActivity = activity
                if (currentActivity != null) {
                    currentActivity.finishAffinity()
                    result.success(null)
                } else {
                    result.error(
                        "NO_ACTIVITY",
                        "Activity is not available.",
                        null
                    )
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
            else -> result.notImplemented()
        }
    }
}
