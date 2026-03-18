import Cocoa
import FlutterMacOS

/**
 * Tap2exitPlugin — Safe no-op macOS implementation.
 *
 * macOS does not use the Android back button, so all method calls
 * return successfully without performing any action.
 */
public class Tap2exitPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example.tap2exit/exit",
            binaryMessenger: registrar.messenger
        )
        let instance = Tap2exitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "exitApp":
            // macOS does not support programmatic exit via this plugin. Safe no-op.
            result(nil)
        case "showToast":
            // Native Toast does not exist on macOS. Safe no-op.
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
