import UIKit
import MAMapKit
import AMapFoundationKit
import AMapSearchKit

/// 高德地图位置选择器 ViewController
/// 
/// 功能：
/// - 显示高德 3D 地图
/// - 支持地图拖动选择位置
/// - 自动逆地理编码获取地址信息
/// - 返回经纬度和详细地址
class AmapMapPickerController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
    
    // MARK: - Properties
    
    private var mapView: MAMapView!
    private var centerAnnotation: MAPointAnnotation!
    private var search: AMapSearchAPI!
    
    /// 初始经纬度
    var initialLatitude: CLLocationDegrees?
    var initialLongitude: CLLocationDegrees?
    
    /// 选择结果回调
    var onLocationSelected: ((_ latitude: Double, _ longitude: Double, _ address: String, _ city: String, _ province: String) -> Void)?
    
    /// 当前选中的位置信息
    private var currentAddress: String = ""
    private var currentCity: String = ""
    private var currentProvince: String = ""
    
    // MARK: - UI Components
    
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Location"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var centerPinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = UIColor(red: 1, green: 0.27, blue: 0.35, alpha: 1) // #FF4458
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var addressPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading address..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Location", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 1, green: 0.27, blue: 0.35, alpha: 1) // #FF4458
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupUI()
        setupSearch()
        
        // 设置初始位置
        if let lat = initialLatitude, let lng = initialLongitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView.setCenter(coordinate, animated: false)
            reverseGeocode(coordinate: coordinate)
        } else {
            // 默认北京天安门
            let defaultCoordinate = CLLocationCoordinate2D(latitude: 39.909187, longitude: 116.397451)
            mapView.setCenter(defaultCoordinate, animated: false)
            reverseGeocode(coordinate: defaultCoordinate)
        }
    }
    
    // MARK: - Setup
    
    private func setupMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.zoomLevel = 15
        view.addSubview(mapView)
    }
    
    private func setupUI() {
        // Top bar
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Title
        topBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
        
        // Cancel button
        topBar.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
        
        // Center pin
        view.addSubview(centerPinImageView)
        centerPinImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerPinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerPinImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            centerPinImageView.widthAnchor.constraint(equalToConstant: 40),
            centerPinImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Address panel
        view.addSubview(addressPanel)
        addressPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addressPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addressPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addressPanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        // Address label
        addressPanel.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: addressPanel.topAnchor, constant: 16),
            addressLabel.leadingAnchor.constraint(equalTo: addressPanel.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: addressPanel.trailingAnchor, constant: -16)
        ])
        
        // Confirm button
        addressPanel.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: addressPanel.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: addressPanel.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: addressPanel.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupSearch() {
        search = AMapSearchAPI()
        search.delegate = self
    }
    
    // MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            // 用户拖动地图时触发逆地理编码
            let center = mapView.centerCoordinate
            reverseGeocode(coordinate: center)
        }
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude),
                                                 longitude: CGFloat(coordinate.longitude))
        request.requireExtension = true
        
        search.aMapReGoecodeSearch(request)
    }
    
    // MARK: - AMapSearchDelegate
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let regeocode = response.regeocode else {
            addressLabel.text = "Unable to get address"
            return
        }
        
        // 更新地址信息
        currentAddress = regeocode.formattedAddress ?? "Unknown address"
        currentCity = regeocode.addressComponent.city ?? regeocode.addressComponent.province ?? ""
        currentProvince = regeocode.addressComponent.province ?? ""
        
        addressLabel.text = currentAddress
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("⚠️ Reverse geocode failed: \(error.localizedDescription)")
        addressLabel.text = "Failed to get address"
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func confirmTapped() {
        let center = mapView.centerCoordinate
        onLocationSelected?(
            center.latitude,
            center.longitude,
            currentAddress,
            currentCity,
            currentProvince
        )
        dismiss(animated: true, completion: nil)
    }
}
