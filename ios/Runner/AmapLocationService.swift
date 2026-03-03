import Flutter
import UIKit
import AMapFoundationKit
import AMapLocationKit

/// 高德定位服务
/// 使用原生 AMapLocationManager 实现精准定位
class AmapLocationService: NSObject {
    
    private static let CHANNEL_NAME = "com.gonomads.df_admin_mobile/amap_location"
    
    private var methodChannel: FlutterMethodChannel?
    private var locationManager: AMapLocationManager?
    private var pendingResult: FlutterResult?
    
    /// 初始化服务
    func setup(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: AmapLocationService.CHANNEL_NAME,
            binaryMessenger: messenger
        )
        
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "getCurrentLocation":
                self.getCurrentLocation(result: result)
            case "startContinuousLocation":
                self.startContinuousLocation(result: result)
            case "stopContinuousLocation":
                self.stopContinuousLocation(result: result)
            case "checkPermission":
                self.checkPermission(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        initLocationManager()
        NSLog("✅ AmapLocationService: 初始化完成")
    }
    
    /// 初始化定位管理器
    private func initLocationManager() {
        locationManager = AMapLocationManager()
        locationManager?.delegate = self
        
        // 设置定位精度
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        // 设置定位超时时间
        locationManager?.locationTimeout = 30
        
        // 设置逆地理编码超时时间
        locationManager?.reGeocodeTimeout = 10
        
        // 返回逆地理编码信息
        locationManager?.locatingWithReGeocode = true
        
        // 允许后台定位（如果 Info.plist 配置了）
        locationManager?.allowsBackgroundLocationUpdates = false
        
        // 暂停自动更新位置
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        NSLog("✅ AmapLocationService: 定位管理器初始化成功")
    }
    
    /// 获取当前位置（单次定位）
    private func getCurrentLocation(result: @escaping FlutterResult) {
        NSLog("📍 AmapLocationService: 开始获取当前位置...")
        
        // 检查定位服务是否可用
        guard CLLocationManager.locationServicesEnabled() else {
            NSLog("❌ AmapLocationService: 定位服务不可用")
            result(FlutterError(code: "LOCATION_DISABLED", message: "定位服务未开启", details: nil))
            return
        }
        
        // 检查权限
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted {
            NSLog("❌ AmapLocationService: 没有定位权限")
            result(FlutterError(code: "PERMISSION_DENIED", message: "未授予定位权限", details: nil))
            return
        }
        
        // 保存待返回的 result
        pendingResult = result
        
        // 发起单次定位请求（带逆地理编码）
        locationManager?.requestLocation(withReGeocode: true) { [weak self] (location, reGeocode, error) in
            guard let self = self else { return }
            
            let pendingResult = self.pendingResult
            self.pendingResult = nil
            
            if let error = error {
                NSLog("❌ AmapLocationService: 定位失败 - \(error.localizedDescription)")
                pendingResult?(FlutterError(
                    code: "LOCATION_ERROR",
                    message: error.localizedDescription,
                    details: ["errorCode": (error as NSError).code]
                ))
                return
            }
            
            guard let location = location else {
                NSLog("❌ AmapLocationService: 定位返回空结果")
                pendingResult?(FlutterError(code: "LOCATION_NULL", message: "定位结果为空", details: nil))
                return
            }
            
            // 构建返回数据
            var locationData: [String: Any] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "accuracy": location.horizontalAccuracy,
                "altitude": location.altitude,
                "speed": location.speed,
                "errorCode": 0
            ]
            
            // 添加逆地理编码信息
            if let reGeocode = reGeocode {
                locationData["address"] = reGeocode.formattedAddress ?? ""
                locationData["country"] = reGeocode.country ?? ""
                locationData["province"] = reGeocode.province ?? ""
                locationData["city"] = reGeocode.city ?? ""
                locationData["cityCode"] = reGeocode.citycode ?? ""
                locationData["district"] = reGeocode.district ?? ""
                locationData["adCode"] = reGeocode.adcode ?? ""
                locationData["street"] = reGeocode.street ?? ""
                locationData["streetNum"] = reGeocode.number ?? ""
                locationData["poiName"] = reGeocode.poiName ?? ""
                locationData["aoiName"] = reGeocode.aoiName ?? ""
                locationData["description"] = reGeocode.formattedAddress ?? ""
                
                NSLog("✅ AmapLocationService: 定位成功")
                NSLog("   地址: \(reGeocode.formattedAddress ?? "")")
                NSLog("   城市: \(reGeocode.city ?? "")")
                NSLog("   区县: \(reGeocode.district ?? "")")
            } else {
                locationData["address"] = ""
                locationData["country"] = ""
                locationData["province"] = ""
                locationData["city"] = ""
                locationData["cityCode"] = ""
                locationData["district"] = ""
                locationData["adCode"] = ""
                locationData["street"] = ""
                locationData["streetNum"] = ""
                locationData["poiName"] = ""
                locationData["aoiName"] = ""
                locationData["description"] = ""
                
                NSLog("✅ AmapLocationService: 定位成功（无逆地理编码）")
            }
            
            // 添加定位类型（iOS 统一为 0，表示系统定位）
            locationData["locationType"] = 0
            
            NSLog("   坐标: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            NSLog("   精度: \(location.horizontalAccuracy)m")
            
            pendingResult?(locationData)
        }
    }
    
    /// 开始连续定位
    private func startContinuousLocation(result: @escaping FlutterResult) {
        NSLog("📍 AmapLocationService: 开始连续定位...")
        locationManager?.startUpdatingLocation()
        result(["success": true, "message": "连续定位已启动"])
    }
    
    /// 停止连续定位
    private func stopContinuousLocation(result: @escaping FlutterResult) {
        NSLog("📍 AmapLocationService: 停止连续定位...")
        locationManager?.stopUpdatingLocation()
        result(["success": true, "message": "连续定位已停止"])
    }
    
    /// 检查定位权限
    private func checkPermission(result: @escaping FlutterResult) {
        let status = CLLocationManager.authorizationStatus()
        let hasPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        NSLog("📍 AmapLocationService: 权限状态 = \(hasPermission) (status: \(status.rawValue))")
        result(["hasPermission": hasPermission])
    }
    
    /// 销毁资源
    func destroy() {
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        methodChannel?.setMethodCallHandler(nil)
        methodChannel = nil
        NSLog("🗑️ AmapLocationService: 已销毁")
    }
}

// MARK: - AMapLocationManagerDelegate
extension AmapLocationService: AMapLocationManagerDelegate {
    
    /// 连续定位回调
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        // 连续定位时，可以通过 MethodChannel 发送位置更新
        var locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "errorCode": 0
        ]
        
        if let reGeocode = reGeocode {
            locationData["address"] = reGeocode.formattedAddress ?? ""
            locationData["city"] = reGeocode.city ?? ""
            locationData["district"] = reGeocode.district ?? ""
            locationData["street"] = reGeocode.street ?? ""
            locationData["poiName"] = reGeocode.poiName ?? ""
        }
        
        // 发送位置更新事件到 Flutter
        methodChannel?.invokeMethod("onLocationUpdate", arguments: locationData)
    }
    
    /// 定位失败回调
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        NSLog("❌ AmapLocationService: 连续定位失败 - \(error.localizedDescription)")
    }
    
    /// 授权状态变化
    func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        NSLog("📍 AmapLocationService: 授权状态变化 - \(status.rawValue)")
    }
}
