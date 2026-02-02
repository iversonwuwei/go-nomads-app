import Flutter
import UIKit
import AMapFoundationKit
import MAMapKit
import AMapSearchKit
import AMapLocationKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  // Platform Channel 名称
  private let CHANNEL_NAME = "com.gonomads.df_admin_mobile/amap"

  // Amap API Key (iOS)
  private let AMAP_API_KEY = "6b053c71911726f46271e4b54124d35f"
  
  // 高德定位服务实例
  private var amapLocationService: AmapLocationService?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 初始化高德地图 SDK
    AMapServices.shared().apiKey = AMAP_API_KEY
    AMapServices.shared().enableHTTPS = true

    // 设置 Platform Channel
    guard let flutterViewController = window?.rootViewController as? FlutterViewController else {
      fatalError("Unable to bootstrap Flutter root view controller")
    }
    
    // 初始化高德定位服务（混合实现核心）
    amapLocationService = AmapLocationService()
    amapLocationService?.setup(with: flutterViewController.binaryMessenger)
    
    // 设置原有的 MethodChannel（保持兼容性）
    let amapChannel = FlutterMethodChannel(
      name: CHANNEL_NAME,
      binaryMessenger: flutterViewController.binaryMessenger
    )

    amapChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "test":
        result("Native iOS Amap connected ✅")

      case "openMapPicker":
        self.openMapPicker(call: call, result: result, controller: flutterViewController)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register the platform view factory so Flutter can create `amap_city_view` on iOS.
    registerAmapPlatformView()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Platform Channel Methods

  /// 打开原生地图选择器
  private func openMapPicker(
    call: FlutterMethodCall, result: @escaping FlutterResult, controller: FlutterViewController
  ) {
    let args = call.arguments as? [String: Any]
    let initialLat = args?["initialLatitude"] as? Double
    let initialLng = args?["initialLongitude"] as? Double

    let picker = AmapMapPickerController()
    picker.initialLatitude = initialLat
    picker.initialLongitude = initialLng
    picker.modalPresentationStyle = .fullScreen

    picker.onLocationSelected = { latitude, longitude, address, city, province in
      let resultData: [String: Any] = [
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "city": city,
        "province": province,
      ]
      result(resultData)
    }

    controller.present(picker, animated: true, completion: nil)
  }

  /// Registers the iOS platform view factory for embedding AMap in Flutter.
  private func registerAmapPlatformView() {
    // 注册城市详情地图视图
    guard let cityRegistrar = registrar(forPlugin: "AmapCityPlatformView") else {
      NSLog("⚠️ Unable to obtain registrar for AmapCityPlatformView")
      return
    }
    cityRegistrar.register(
      AmapCityViewFactory(messenger: cityRegistrar.messenger()),
      withId: "amap_city_view"
    )

    // 注册全球地图视图（显示多个城市标记）
    guard let globalRegistrar = registrar(forPlugin: "AmapGlobalPlatformView") else {
      NSLog("⚠️ Unable to obtain registrar for AmapGlobalPlatformView")
      return
    }
    globalRegistrar.register(
      AmapGlobalViewFactory(messenger: globalRegistrar.messenger()),
      withId: "amap_global_view"
    )
  }
}
