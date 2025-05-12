import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let pipChannel = FlutterMethodChannel(name: "pip_channel",
                                              binaryMessenger: controller.binaryMessenger)
    pipChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "enablePip" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.enablePip(result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func enablePip(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard let rootViewController = self.window?.rootViewController else {
        result(FlutterError(code: "ERROR", message: "No root VC", details: nil))
        return
      }
      
      var currentController = rootViewController
      while let presented = currentController.presentedViewController {
        currentController = presented
      }
      
      if let avPlayerVC = currentController as? AVPlayerViewController {
        avPlayerVC.allowsPictureInPicturePlayback = true
        if #available(iOS 9.0, *) {
          avPlayerVC.startPictureInPicture()
          result(nil)
        } else {
          result(FlutterError(code: "ERROR", message: "PiP not available", details: nil))
        }
      } else {
        result(FlutterError(code: "ERROR", message: "No AVPlayer", details: nil))
      }
    }
  }
}
