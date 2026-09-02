import AppIntents
import Flutter
import UIKit

enum AppleIntelligenceChannel {
    static let name = "app_dinix/apple_intelligence"

    static func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "syncSession":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "bad_args", message: "Argumentos inválidos", details: nil))
                    return
                }
                syncSession(args: args)
                result(true)
            case "clearSession":
                DinixSessionStore.shared.clearSession()
                DinixSpotlightIndexer.clear()
                result(true)
            case "setOnScreenEntity":
                let args = call.arguments as? [String: Any]
                DinixSessionStore.shared.setOnScreenEntity(
                    type: args?["type"] as? String,
                    id: args?["id"] as? String,
                    title: args?["title"] as? String
                )
                donateUserActivity(
                    type: args?["type"] as? String,
                    id: args?["id"] as? String,
                    title: args?["title"] as? String
                )
                result(true)
            case "clearOnScreenEntity":
                DinixSessionStore.shared.setOnScreenEntity(type: nil, id: nil, title: nil)
                result(true)
            case "consumePendingRoute":
                result(DinixSessionStore.shared.consumePendingRoute())
            case "reindexSpotlight":
                Task {
                    await DinixSpotlightIndexer.reindexSafeEntities()
                    result(true)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func syncSession(args: [String: Any]) {
        guard let token = args["token"] as? String, !token.isEmpty else {
            DinixSessionStore.shared.clearSession()
            return
        }
        DinixSessionStore.shared.saveSession(
            token: token,
            userId: args["userId"] as? String,
            authDay: args["authDay"] as? String,
            deviceId: args["deviceId"] as? String,
            apiBaseURL: args["apiBaseURL"] as? String,
            clientId: args["clientId"] as? String,
            clientSecret: args["clientSecret"] as? String,
            appVersion: args["appVersion"] as? String,
            biometriaHabilitada: args["biometriaHabilitada"] as? Bool
        )
        if #available(iOS 16.0, *) {
            DinixShortcuts.updateAppShortcutParameters()
        }
    }

    private static func donateUserActivity(type: String?, id: String?, title: String?) {
        guard let type, let id, !type.isEmpty, !id.isEmpty else { return }
        let activity = NSUserActivity(activityType: "br.com.dinix.entity.\(type)")
        activity.title = title ?? type
        activity.isEligibleForHandoff = false
        activity.isEligibleForSearch = false
        activity.userInfo = ["type": type, "id": id]
        activity.becomeCurrent()
    }
}
