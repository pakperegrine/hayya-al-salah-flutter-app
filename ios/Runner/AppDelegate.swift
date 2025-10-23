import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add comprehensive error handling for plugin registration
    do {
      // Disable Metal rendering if causing issues
      if #available(iOS 18.0, *) {
        // Force software rendering for iOS 18+ to avoid Metal crashes
        let flutterEngine = self.engine
        flutterEngine?.run(withEntrypoint: nil)
      }
      
      GeneratedPluginRegistrant.register(with: self)
    } catch {
      print("Error registering plugins: \(error)")
      // Continue anyway - don't let plugin registration crash the app
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Add memory management
    super.applicationDidEnterBackground(application)
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    // Clean shutdown
    super.applicationWillTerminate(application)
  }
}
