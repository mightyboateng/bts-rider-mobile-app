import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps SDK key (iOS-app restricted). Set MAPS_API_KEY in ios/Flutter/Maps.xcconfig;
    // it flows into Info.plist as GMSApiKey.
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty, key != "YOUR_IOS_MAPS_KEY" {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("[BTS] GMSApiKey is not set. Add MAPS_API_KEY to ios/Flutter/Maps.xcconfig.")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
