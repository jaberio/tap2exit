import Flutter
import UIKit

/**
 * Tap2exitPlugin — Safe no-op iOS implementation.
 *
 * iOS does not allow programmatic app exit, so all method calls
 * return successfully without performing any action.
 */
public class Tap2exitPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example.tap2exit/exit",
            binaryMessenger: registrar.messenger()
        )
        let instance = Tap2exitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            // iOS does not support programmatic exit. Safe no-op.
            result(nil)
        case "showToast":
            // Native Toast does not exist on iOS. Safe no-op.
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
