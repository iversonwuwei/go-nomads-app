/// 用户的家（常住地）实体
/// 用于判断是否为旅行目的地（距离常住地超过一定距离）
class HomeLocation {
  final int? id;
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int confidence; // 置信度（0-100），基于在该位置停留的次数和时长

  HomeLocation({
    this.id,
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.confidence = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'city_name': cityName,
      'country_name': countryName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  factory HomeLocation.fromMap(Map<String, dynamic> map) {
    return HomeLocation(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      cityName: map['city_name'] as String?,
      countryName: map['country_name'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      confidence: map['confidence'] as int? ?? 0,
    );
  }

  HomeLocation copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? cityName,
    String? countryName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? confidence,
  }) {
    return HomeLocation(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() {
    return 'HomeLocation($cityName, confidence: $confidence%)';
  }
}

/// 旅行检测配置
class TravelDetectionConfig {
  /// 判断为旅行的最小距离（公里）
  final double minTravelDistanceKm;

  /// 判断为停留点的最小时间（小时）
  final int minStayHours;

  /// 判断为旅行的最小过夜数
  final int minOvernightStays;

  /// 停留点聚类的距离阈值（米）
  final double clusterRadiusMeters;

  /// 后台定位的时间间隔（分钟）
  final int locationIntervalMinutes;

  /// 候选旅行的过期时间（天）
  final int candidateTripExpirationDays;

  const TravelDetectionConfig({
    this.minTravelDistanceKm = 50,
    this.minStayHours = 4,
    this.minOvernightStays = 1,
    this.clusterRadiusMeters = 300,
    this.locationIntervalMinutes = 30,
    this.candidateTripExpirationDays = 14,
  });

  /// 默认配置
  static const TravelDetectionConfig defaultConfig = TravelDetectionConfig();

  /// 严格模式（更长的距离和时间要求）
  static const TravelDetectionConfig strictMode = TravelDetectionConfig(
    minTravelDistanceKm: 100,
    minStayHours: 8,
    minOvernightStays: 2,
  );

  /// 宽松模式（较短的距离和时间要求）
  static const TravelDetectionConfig relaxedMode = TravelDetectionConfig(
    minTravelDistanceKm: 30,
    minStayHours: 3,
    minOvernightStays: 0,
  );

  Map<String, dynamic> toMap() {
    return {
      'min_travel_distance_km': minTravelDistanceKm,
      'min_stay_hours': minStayHours,
      'min_overnight_stays': minOvernightStays,
      'cluster_radius_meters': clusterRadiusMeters,
      'location_interval_minutes': locationIntervalMinutes,
      'candidate_trip_expiration_days': candidateTripExpirationDays,
    };
  }

  factory TravelDetectionConfig.fromMap(Map<String, dynamic> map) {
    return TravelDetectionConfig(
      minTravelDistanceKm: (map['min_travel_distance_km'] as num?)?.toDouble() ?? 50,
      minStayHours: map['min_stay_hours'] as int? ?? 4,
      minOvernightStays: map['min_overnight_stays'] as int? ?? 1,
      clusterRadiusMeters: (map['cluster_radius_meters'] as num?)?.toDouble() ?? 300,
      locationIntervalMinutes: map['location_interval_minutes'] as int? ?? 30,
      candidateTripExpirationDays: map['candidate_trip_expiration_days'] as int? ?? 14,
    );
  }
}
