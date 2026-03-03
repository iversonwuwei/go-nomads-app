/// 位置点实体
/// 用于存储后台定位获取的位置数据
class LocationPoint {
  final int? id;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime timestamp;
  final bool isProcessed;

  LocationPoint({
    this.id,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
    this.isProcessed = false,
  });

  /// 计算与另一个点的距离（米）
  /// 使用 Haversine 公式
  double distanceTo(LocationPoint other) {
    return _haversineDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Haversine 公式计算两点间距离
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) * _sin(dLon / 2) * _sin(dLon / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _sinImpl(x);
  static double _cos(double x) => _sinImpl(x + 3.141592653589793 / 2);
  static double _sqrt(double x) => x > 0 ? _sqrtImpl(x) : 0;
  static double _atan2(double y, double x) => _atan2Impl(y, x);

  // 简化的数学函数实现（实际使用 dart:math）
  static double _sinImpl(double x) {
    // 使用泰勒级数近似
    x = x % (2 * 3.141592653589793);
    double result = 0;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }

  static double _sqrtImpl(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2Impl(double y, double x) {
    if (x > 0) return _atanImpl(y / x);
    if (x < 0 && y >= 0) return _atanImpl(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atanImpl(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  static double _atanImpl(double x) {
    // 简化的 atan 实现
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * (3.141592653589793 / 2 - _atanImpl(1 / x.abs()));
    }
    double result = 0;
    double term = x;
    for (int i = 0; i < 20; i++) {
      result += term / (2 * i + 1);
      term *= -x * x;
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'is_processed': isProcessed ? 1 : 0,
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracy: map['accuracy'] as double?,
      altitude: map['altitude'] as double?,
      speed: map['speed'] as double?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isProcessed: (map['is_processed'] as int?) == 1,
    );
  }

  LocationPoint copyWith({
    int? id,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    DateTime? timestamp,
    bool? isProcessed,
  }) {
    return LocationPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  @override
  String toString() {
    return 'LocationPoint(lat: $latitude, lon: $longitude, time: $timestamp)';
  }
}
