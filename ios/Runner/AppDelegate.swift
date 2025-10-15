import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add error handling for plugin registration
    do {
      GeneratedPluginRegistrant.register(with: self)
    } catch {
      print("Error registering plugins: \(error)")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
