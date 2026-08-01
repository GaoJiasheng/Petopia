import Flutter
#if PETOPIA_TESTFLIGHT_TOOLS
import StoreKit
#endif
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  #if PETOPIA_TESTFLIGHT_TOOLS
  private var distributionChannel: FlutterMethodChannel?
  #endif

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    #if PETOPIA_TESTFLIGHT_TOOLS
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "PetopiaDistributionEnvironment"
    ) else { return }
    let channel = FlutterMethodChannel(
      name: "cn.gavingao.petopia/distribution",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "isTestFlight" else {
        result(FlutterMethodNotImplemented)
        return
      }
      Self.resolveTestFlight(result: result)
    }
    distributionChannel = channel
    #endif
  }

  #if PETOPIA_TESTFLIGHT_TOOLS
  private static func resolveTestFlight(result: @escaping FlutterResult) {
    #if targetEnvironment(simulator)
      result(false)
    #else
      if #available(iOS 16.0, *) {
        Task {
          do {
            switch try await AppTransaction.shared {
            case .verified(let transaction):
              result(transaction.environment == .sandbox)
            case .unverified:
              result(false)
            }
          } catch {
            result(hasSandboxReceipt)
          }
        }
      } else {
        result(hasSandboxReceipt)
      }
    #endif
  }

  private static var hasSandboxReceipt: Bool {
    Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  }
  #endif
}
