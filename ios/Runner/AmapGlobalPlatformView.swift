#if canImport(Flutter)
import Flutter
#endif
import Foundation
#if canImport(MAMapKit)
import MAMapKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(Flutter) && canImport(UIKit)

/// Registers a UIKit backed platform view for displaying global cities on AMap.
final class AmapGlobalViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    AmapGlobalPlatformView(frame: frame, viewId: viewId, arguments: args, messenger: messenger)
  }
}

/// City marker data model
struct CityMarkerData {
  let id: Int
  let name: String
  let latitude: Double
  let longitude: Double
  let country: String
  let score: Double
}

/// Platform view displaying global city markers on AMap.
final class AmapGlobalPlatformView: NSObject, FlutterPlatformView {
  private let containerView: UIView
  private let mapView: MAMapView
  private let methodChannel: FlutterMethodChannel
  private var cities: [CityMarkerData] = []
  private var annotations: [MAPointAnnotation] = []

  init(frame: CGRect, viewId: Int64, arguments args: Any?, messenger: FlutterBinaryMessenger) {
    // 创建容器视图
    containerView = UIView(frame: frame)
    containerView.backgroundColor = UIColor.white
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // 创建地图视图 - 确保有足够的初始 frame
    let mapFrame = CGRect(x: 0, y: 0, width: max(frame.width, 300), height: max(frame.height, 500))
    mapView = MAMapView(frame: mapFrame)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.showsUserLocation = false
    mapView.showsCompass = true
    mapView.showsScale = true
    
    // 使用标准地图类型（2D），在模拟器上更兼容
    mapView.mapType = MAMapType.standard
    
    // 设置方法通道用于 Flutter 和原生通信
    methodChannel = FlutterMethodChannel(
      name: "amap_global_view_\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    // 将地图添加到容器
    containerView.addSubview(mapView)
    
    mapView.delegate = self
    
    // 设置方法通道处理
    setupMethodChannel()
    
    // 配置地图和城市标记
    configureMap(arguments: args)
    
    NSLog("🗺️ AmapGlobalPlatformView initialized with frame: \(frame), mapFrame: \(mapFrame)")
  }

  func view() -> UIView {
    containerView
  }

  private func setupMethodChannel() {
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "setZoom":
        if let args = call.arguments as? [String: Any],
           let zoom = args["zoom"] as? Double {
          self.mapView.setZoomLevel(CGFloat(zoom), animated: true)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Zoom level required", details: nil))
        }
        
      case "setCenter":
        if let args = call.arguments as? [String: Any],
           let lat = args["latitude"] as? Double,
           let lng = args["longitude"] as? Double {
          let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
          self.mapView.setCenter(coordinate, animated: true)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Latitude and longitude required", details: nil))
        }
        
      case "resetToWorld":
        // 重置到世界视图
        let worldCenter = CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0)
        self.mapView.setCenter(worldCenter, animated: true)
        self.mapView.setZoomLevel(2, animated: true)
        result(nil)
        
      case "updateCities":
        if let args = call.arguments as? [String: Any],
           let citiesData = args["cities"] as? [[String: Any]] {
          self.updateCities(citiesData: citiesData)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Cities data required", details: nil))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func configureMap(arguments args: Any?) {
    guard let params = args as? [String: Any] else {
      NSLog("🗺️ No arguments provided, using defaults")
      setDefaultMapPosition()
      return
    }

    NSLog("🗺️ Configuring map with params: \(params)")

    // 设置初始中心点 - 默认使用中国中心以确保底图可见
    let centerLat = params["centerLatitude"] as? Double ?? 35.0
    let centerLng = params["centerLongitude"] as? Double ?? 105.0
    let centerCoordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
    mapView.setCenter(centerCoordinate, animated: false)
    NSLog("🗺️ Set center: \(centerLat), \(centerLng)")

    // 设置初始缩放 - 使用较高的缩放级别确保底图可见
    if let initialZoom = params["initialZoom"] as? Double {
      // 确保缩放级别不会太小
      let safeZoom = max(initialZoom, 3.0)
      mapView.setZoomLevel(CGFloat(safeZoom), animated: false)
      NSLog("🗺️ Set zoom level: \(safeZoom)")
    } else {
      mapView.setZoomLevel(4, animated: false)
    }

    // 添加城市标记
    if let citiesData = params["cities"] as? [[String: Any]] {
      NSLog("🗺️ Received \(citiesData.count) cities")
      updateCities(citiesData: citiesData)
    }
  }

  private func setDefaultMapPosition() {
    // 默认显示中国视图 - 高德地图在中国区域底图覆盖完整
    let chinaCenter = CLLocationCoordinate2D(latitude: 35.0, longitude: 105.0)
    mapView.setCenter(chinaCenter, animated: false)
    mapView.setZoomLevel(4, animated: false)  // 使用更高的缩放级别确保底图可见
    NSLog("🗺️ Set default map position to China center")
  }

  private func updateCities(citiesData: [[String: Any]]) {
    // 清除现有标记
    mapView.removeAnnotations(annotations)
    annotations.removeAll()
    cities.removeAll()

    // 解析城市数据
    for cityData in citiesData {
      guard let id = cityData["id"] as? Int,
            let name = cityData["name"] as? String,
            let lat = cityData["latitude"] as? Double,
            let lng = cityData["longitude"] as? Double else {
        continue
      }

      let city = CityMarkerData(
        id: id,
        name: name,
        latitude: lat,
        longitude: lng,
        country: cityData["country"] as? String ?? "",
        score: cityData["score"] as? Double ?? 0.0
      )
      cities.append(city)

      // 创建标记
      let annotation = MAPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      annotation.title = name
      annotation.subtitle = city.country
      annotations.append(annotation)
    }

    // 添加标记到地图
    mapView.addAnnotations(annotations)

    NSLog("🗺️ Added \(annotations.count) city markers to AMap")
  }
}

// MARK: - MAMapViewDelegate

extension AmapGlobalPlatformView: MAMapViewDelegate {
  
  func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
    NSLog("✅ AMap finished loading map tiles")
  }
  
  func mapViewDidFailLoadingMap(_ mapView: MAMapView!, withError error: Error!) {
    NSLog("❌ AMap failed to load map: \(error?.localizedDescription ?? "unknown error")")
  }
  
  func mapInitComplete(_ mapView: MAMapView!) {
    NSLog("✅ AMap init complete")
  }
  
  func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
    guard !(annotation is MAUserLocation) else { return nil }

    let identifier = "CityMarker"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MAPinAnnotationView

    if annotationView == nil {
      annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
      annotationView?.animatesDrop = false
      annotationView?.pinColor = .red
    } else {
      annotationView?.annotation = annotation
    }

    // 根据分数设置不同颜色
    if let pointAnnotation = annotation as? MAPointAnnotation,
       let index = annotations.firstIndex(of: pointAnnotation),
       index < cities.count {
      let city = cities[index]
      if city.score >= 4.0 {
        annotationView?.pinColor = .green
      } else if city.score >= 3.0 {
        annotationView?.pinColor = .purple
      } else {
        annotationView?.pinColor = .red
      }
    }

    return annotationView
  }

  func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
    guard let annotation = view.annotation,
          !(annotation is MAUserLocation) else { return }

    // 发送城市点击事件到 Flutter
    if let pointAnnotation = annotation as? MAPointAnnotation,
       let index = annotations.firstIndex(of: pointAnnotation),
       index < cities.count {
      let city = cities[index]
      methodChannel.invokeMethod("onCityTapped", arguments: [
        "id": city.id,
        "name": city.name,
        "latitude": city.latitude,
        "longitude": city.longitude,
        "country": city.country,
        "score": city.score
      ])
    }
  }

  func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
    // 可以通知 Flutter 缩放级别变化
    if wasUserAction {
      methodChannel.invokeMethod("onZoomChanged", arguments: [
        "zoom": mapView.zoomLevel
      ])
    }
  }
}

#endif
