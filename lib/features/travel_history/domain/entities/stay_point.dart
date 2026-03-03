import 'location_point.dart';

/// 停留点实体
/// 当检测到用户在同一地理区域（如 300m 内）停留超过一定时间（如 4-8 小时）时创建
class StayPoint {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final int pointCount; // 组成该停留点的位置点数量
  final double radius; // 停留点的半径（米）
  final bool isProcessed; // 是否已处理（用于旅行判断）

  StayPoint({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
    required this.departureTime,
    required this.pointCount,
    this.radius = 300,
    this.isProcessed = false,
  });

  /// 停留时长（小时）
  double get durationHours {
    return departureTime.difference(arrivalTime).inMinutes / 60.0;
  }

  /// 停留时长（分钟）
  int get durationMinutes {
    return departureTime.difference(arrivalTime).inMinutes;
  }

  /// 是否为有效停留点（停留时间超过阈值）
  bool isValidStayPoint({int minHours = 4}) {
    return durationHours >= minHours;
  }

  /// 是否可能是过夜停留（停留超过8小时）
  bool get isOvernightStay => durationHours >= 8;

  /// 计算与另一个点的距离（米）
  double distanceTo(StayPoint other) {
    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: arrivalTime,
    ).distanceTo(LocationPoint(
      latitude: other.latitude,
      longitude: other.longitude,
      timestamp: other.arrivalTime,
    ));
  }

  /// 计算与经纬度的距离（米）
  double distanceToCoordinates(double lat, double lon) {
    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: arrivalTime,
    ).distanceTo(LocationPoint(
      latitude: lat,
      longitude: lon,
      timestamp: arrivalTime,
    ));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'arrival_time': arrivalTime.toIso8601String(),
      'departure_time': departureTime.toIso8601String(),
      'point_count': pointCount,
      'radius': radius,
      'is_processed': isProcessed ? 1 : 0,
    };
  }

  factory StayPoint.fromMap(Map<String, dynamic> map) {
    return StayPoint(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      arrivalTime: DateTime.parse(map['arrival_time'] as String),
      departureTime: DateTime.parse(map['departure_time'] as String),
      pointCount: map['point_count'] as int,
      radius: map['radius'] as double? ?? 300,
      isProcessed: (map['is_processed'] as int?) == 1,
    );
  }

  StayPoint copyWith({
    int? id,
    double? latitude,
    double? longitude,
    DateTime? arrivalTime,
    DateTime? departureTime,
    int? pointCount,
    double? radius,
    bool? isProcessed,
  }) {
    return StayPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      pointCount: pointCount ?? this.pointCount,
      radius: radius ?? this.radius,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  @override
  String toString() {
    return 'StayPoint(lat: $latitude, lon: $longitude, duration: ${durationHours.toStringAsFixed(1)}h)';
  }
}

/// 从位置点列表创建停留点的工厂方法
class StayPointFactory {
  /// 停留点检测的距离阈值（米）
  static const double distanceThreshold = 300;

  /// 停留点检测的最小时间阈值（小时）
  static const int minStayHours = 4;

  /// 从位置点列表检测停留点
  static List<StayPoint> detectStayPoints(List<LocationPoint> points) {
    if (points.length < 2) return [];

    // 按时间排序
    final sortedPoints = List<LocationPoint>.from(points)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final stayPoints = <StayPoint>[];
    var currentCluster = <LocationPoint>[sortedPoints.first];

    for (int i = 1; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      final clusterCenter = _calculateCenter(currentCluster);

      // 检查当前点是否在聚类范围内
      if (_isWithinDistance(point, clusterCenter, distanceThreshold)) {
        currentCluster.add(point);
      } else {
        // 当前聚类结束，检查是否满足停留条件
        if (currentCluster.length >= 2) {
          final stayPoint = _createStayPoint(currentCluster);
          if (stayPoint != null && stayPoint.durationHours >= minStayHours) {
            stayPoints.add(stayPoint);
          }
        }
        // 开始新聚类
        currentCluster = [point];
      }
    }

    // 处理最后一个聚类
    if (currentCluster.length >= 2) {
      final stayPoint = _createStayPoint(currentCluster);
      if (stayPoint != null && stayPoint.durationHours >= minStayHours) {
        stayPoints.add(stayPoint);
      }
    }

    return stayPoints;
  }

  /// 计算聚类中心
  static LocationPoint _calculateCenter(List<LocationPoint> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double sumLat = 0, sumLon = 0;
    for (final point in points) {
      sumLat += point.latitude;
      sumLon += point.longitude;
    }

    return LocationPoint(
      latitude: sumLat / points.length,
      longitude: sumLon / points.length,
      timestamp: points.first.timestamp,
    );
  }

  /// 检查点是否在距离阈值内
  static bool _isWithinDistance(
    LocationPoint point,
    LocationPoint center,
    double threshold,
  ) {
    return point.distanceTo(center) <= threshold;
  }

  /// 从聚类创建停留点
  static StayPoint? _createStayPoint(List<LocationPoint> cluster) {
    if (cluster.isEmpty) return null;

    final center = _calculateCenter(cluster);
    final sortedCluster = List<LocationPoint>.from(cluster)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 计算最大半径
    double maxRadius = 0;
    for (final point in cluster) {
      final distance = point.distanceTo(center);
      if (distance > maxRadius) maxRadius = distance;
    }

    return StayPoint(
      latitude: center.latitude,
      longitude: center.longitude,
      arrivalTime: sortedCluster.first.timestamp,
      departureTime: sortedCluster.last.timestamp,
      pointCount: cluster.length,
      radius: maxRadius,
    );
  }
}
