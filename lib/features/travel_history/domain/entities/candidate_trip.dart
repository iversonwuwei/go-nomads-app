import 'stay_point.dart';

/// 候选旅行状态枚举
enum CandidateTripStatus {
  pending, // 待确认
  confirmed, // 已确认
  dismissed, // 已忽略
  expired, // 已过期
}

/// 候选旅行实体
/// 当检测到可能的旅行目的地时创建，等待用户确认
class CandidateTrip {
  final int? id;
  final String? backendId; // 后端服务的 UUID
  final double latitude;
  final double longitude;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final double distanceFromHome; // 距离常住地的距离（公里）
  final CandidateTripStatus status;
  final String? cityName; // 反向地理编码后填充
  final String? countryName;
  final String? countryCode;
  final String? cityId; // 关联的城市 ID，用于跳转到城市详情
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? dismissedAt;
  final bool isSyncedToBackend; // 是否已同步到后端

  CandidateTrip({
    this.id,
    this.backendId,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
    required this.departureTime,
    this.distanceFromHome = 0.0,
    this.status = CandidateTripStatus.pending,
    this.cityName,
    this.countryName,
    this.countryCode,
    this.cityId,
    DateTime? createdAt,
    this.confirmedAt,
    this.dismissedAt,
    this.isSyncedToBackend = false,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 停留时长（小时）
  double get durationHours {
    return departureTime.difference(arrivalTime).inMinutes / 60.0;
  }

  /// 停留天数
  int get durationDays {
    return departureTime.difference(arrivalTime).inDays + 1;
  }

  /// 是否有城市信息（已完成反向地理编码）
  bool get hasGeocodingInfo => cityName != null && cityName!.isNotEmpty;

  /// 是否为待确认状态
  bool get isPending => status == CandidateTripStatus.pending;

  /// 是否已确认
  bool get isConfirmed => status == CandidateTripStatus.confirmed;

  /// 是否已忽略
  bool get isDismissed => status == CandidateTripStatus.dismissed;

  /// 显示名称（优先显示城市名，否则显示坐标）
  String get displayName {
    if (cityName != null && cityName!.isNotEmpty) {
      return cityName!;
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  /// 完整地点名称（包含国家）
  String get fullLocationName {
    if (cityName != null && countryName != null) {
      return '$cityName, $countryName';
    }
    return displayName;
  }

  /// 从停留点创建候选旅行
  factory CandidateTrip.fromStayPoint(
    StayPoint stayPoint, {
    required double distanceFromHome,
  }) {
    return CandidateTrip(
      latitude: stayPoint.latitude,
      longitude: stayPoint.longitude,
      arrivalTime: stayPoint.arrivalTime,
      departureTime: stayPoint.departureTime,
      distanceFromHome: distanceFromHome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'backend_id': backendId,
      'latitude': latitude,
      'longitude': longitude,
      'arrival_time': arrivalTime.toIso8601String(),
      'departure_time': departureTime.toIso8601String(),
      'distance_from_home': distanceFromHome,
      'status': status.index,
      'city_name': cityName,
      'country_name': countryName,
      'country_code': countryCode,
      'city_id': cityId,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'dismissed_at': dismissedAt?.toIso8601String(),
      'is_synced_to_backend': isSyncedToBackend ? 1 : 0,
    };
  }

  factory CandidateTrip.fromMap(Map<String, dynamic> map) {
    return CandidateTrip(
      id: map['id'] as int?,
      backendId: map['backend_id'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      arrivalTime: DateTime.parse(map['arrival_time'] as String),
      departureTime: DateTime.parse(map['departure_time'] as String),
      distanceFromHome: (map['distance_from_home'] as num?)?.toDouble() ?? 0.0,
      status: CandidateTripStatus.values[map['status'] as int? ?? 0],
      cityName: map['city_name'] as String?,
      countryName: map['country_name'] as String?,
      countryCode: map['country_code'] as String?,
      cityId: map['city_id'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      confirmedAt: map['confirmed_at'] != null ? DateTime.parse(map['confirmed_at'] as String) : null,
      dismissedAt: map['dismissed_at'] != null ? DateTime.parse(map['dismissed_at'] as String) : null,
      isSyncedToBackend: (map['is_synced_to_backend'] as int? ?? 0) == 1,
    );
  }

  CandidateTrip copyWith({
    int? id,
    String? backendId,
    double? latitude,
    double? longitude,
    DateTime? arrivalTime,
    DateTime? departureTime,
    double? distanceFromHome,
    CandidateTripStatus? status,
    String? cityName,
    String? countryName,
    String? countryCode,
    String? cityId,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? dismissedAt,
    bool? isSyncedToBackend,
  }) {
    return CandidateTrip(
      id: id ?? this.id,
      backendId: backendId ?? this.backendId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      distanceFromHome: distanceFromHome ?? this.distanceFromHome,
      status: status ?? this.status,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      cityId: cityId ?? this.cityId,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      isSyncedToBackend: isSyncedToBackend ?? this.isSyncedToBackend,
    );
  }

  /// 确认旅行
  CandidateTrip confirm() {
    return copyWith(
      status: CandidateTripStatus.confirmed,
      confirmedAt: DateTime.now(),
    );
  }

  /// 忽略旅行
  CandidateTrip dismiss() {
    return copyWith(
      status: CandidateTripStatus.dismissed,
      dismissedAt: DateTime.now(),
    );
  }

  /// 更新地理编码信息
  CandidateTrip withGeocodingInfo({
    required String cityName,
    String? countryName,
    String? countryCode,
  }) {
    return copyWith(
      cityName: cityName,
      countryName: countryName,
      countryCode: countryCode,
    );
  }

  @override
  String toString() {
    return 'CandidateTrip($displayName, $durationDays天, ${distanceFromHome.toStringAsFixed(0)}km)';
  }
}
