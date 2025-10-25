#if canImport(Flutter)
import Flutter
#endif
import Foundation
#if canImport(MAMapKit)
import MAMapKit
#endif
#if canImport(AMapSearchKit)
import AMapSearchKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(Flutter) && canImport(UIKit)

/// Registers a UIKit backed platform view so Flutter can render `amap_city_view` on iOS.
final class AmapCityViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    AmapCityPlatformView(frame: frame, viewId: viewId, arguments: args)
  }
}

/// Simple wrapper around `MAMapView` so Flutter can embed it via `UiKitView`.
final class AmapCityPlatformView: NSObject, FlutterPlatformView {
  private let mapView: MAMapView
  private let geocodeSearch: AMapSearchAPI?

  init(frame: CGRect, viewId: Int64, arguments args: Any?) {
    mapView = MAMapView(frame: frame)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .none
    mapView.setZoomLevel(11, animated: false)

    geocodeSearch = AMapSearchAPI()

    super.init()

    geocodeSearch?.delegate = self

    configureInitialRegion(arguments: args)
  }

  func view() -> UIView {
    mapView
  }

  private func configureInitialRegion(arguments args: Any?) {
    if let params = args as? [String: Any] {
      if let latitude = params["latitude"] as? Double,
         let longitude = params["longitude"] as? Double {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.setCenter(coordinate, animated: false)
        return
      }

      if let cityName = params["cityName"] as? String, !cityName.isEmpty {
        search(cityName: cityName)
        return
      }
    }

    // Fallback to Beijing so there is always a visible map.
    let fallback = CLLocationCoordinate2D(latitude: 39.909187, longitude: 116.397451)
    mapView.setCenter(fallback, animated: false)
  }

  private func search(cityName: String) {
    guard let geocodeSearch else { return }

    let request = AMapGeocodeSearchRequest()
    request.address = cityName
    geocodeSearch.aMapGeocodeSearch(request)
  }
}

extension AmapCityPlatformView: MAMapViewDelegate {}

extension AmapCityPlatformView: AMapSearchDelegate {
  func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
    guard
      let geocode = response?.geocodes?.first,
      let location = geocode.location
    else {
      return
    }

    let coordinate = CLLocationCoordinate2D(
      latitude: CLLocationDegrees(location.latitude),
      longitude: CLLocationDegrees(location.longitude)
    )

    mapView.setCenter(coordinate, animated: true)
  }

  func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
    NSLog("⚠️ AmapCityPlatformView geocode failed: %@", error.localizedDescription)
  }
}

#endif
