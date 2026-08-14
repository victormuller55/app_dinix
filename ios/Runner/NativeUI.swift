import Flutter
import UIKit

enum NativeUI {
  static let channelName = "app_dinix/native_ui"

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      DispatchQueue.main.async {
        switch call.method {
        case "showConfirm":
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "bad_args", message: "Argumentos inválidos", details: nil))
            return
          }
          showConfirm(args: args, result: result)
        case "showActionSheet":
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "bad_args", message: "Argumentos inválidos", details: nil))
            return
          }
          showActionSheet(args: args, result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes
      .flatMap { $0.windows }
      .first(where: \.isKeyWindow) ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  private static func showConfirm(args: [String: Any], result: @escaping FlutterResult) {
    guard let host = topViewController() else {
      result(FlutterError(code: "no_vc", message: "Nenhuma tela disponível", details: nil))
      return
    }

    let title = args["title"] as? String
    let message = args["message"] as? String
    let confirmLabel = args["confirmLabel"] as? String ?? "OK"
    let cancelLabel = args["cancelLabel"] as? String ?? "Cancelar"
    let destructive = args["destructive"] as? Bool ?? false

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel) { _ in
      result(false)
    })
    alert.addAction(UIAlertAction(
      title: confirmLabel,
      style: destructive ? .destructive : .default
    ) { _ in
      result(true)
    })
    host.present(alert, animated: true)
  }

  private static func showActionSheet(args: [String: Any], result: @escaping FlutterResult) {
    guard let host = topViewController() else {
      result(FlutterError(code: "no_vc", message: "Nenhuma tela disponível", details: nil))
      return
    }

    let title = args["title"] as? String
    let message = args["message"] as? String
    let cancelLabel = args["cancelLabel"] as? String ?? "Cancelar"
    let actions = args["actions"] as? [[String: Any]] ?? []

    let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    for action in actions {
      let id = action["id"] as? String ?? ""
      let label = action["title"] as? String ?? id
      let destructive = action["destructive"] as? Bool ?? false
      sheet.addAction(UIAlertAction(
        title: label,
        style: destructive ? .destructive : .default
      ) { _ in
        result(id)
      })
    }
    sheet.addAction(UIAlertAction(title: cancelLabel, style: .cancel) { _ in
      result(nil)
    })

    if let popover = sheet.popoverPresentationController {
      popover.sourceView = host.view
      popover.sourceRect = CGRect(
        x: host.view.bounds.midX,
        y: host.view.bounds.midY,
        width: 0,
        height: 0
      )
      popover.permittedArrowDirections = []
    }

    host.present(sheet, animated: true)
  }
}
