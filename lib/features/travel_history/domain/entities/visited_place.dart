/// 访问地点实体
/// 记录用户在旅行中访问过的具体地点（停留40分钟以上）
class VisitedPlace {
  final int? id;
  final String tripId; // 关联的旅行 ID
  final double latitude;
  final double longitude;
  final String? placeName; // 地点名称（通过逆地理编码获取）
  final String? placeType; // 地点类型（餐厅、咖啡馆、景点等）
  final String? address; // 详细地址
  final DateTime arrivalTime; // 到达时间
  final DateTime departureTime; // 离开时间
  final String? photoUrl; // 地点照片（可选）
  final String? notes; // 用户备注（可选）
  final bool isHighlight; // 是否为精选地点

  VisitedPlace({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.placeType,
    this.address,
    required this.arrivalTime,
    required this.departureTime,
    this.photoUrl,
    this.notes,
    this.isHighlight = false,
  });

  /// 停留时长（分钟）
  int get durationMinutes {
    return departureTime.difference(arrivalTime).inMinutes;
  }

  /// 停留时长（小时）
  double get durationHours {
    return durationMinutes / 60.0;
  }

  /// 格式化的停留时长
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  /// 获取地点图标类型
  String get iconType {
    switch (placeType?.toLowerCase()) {
      case 'restaurant':
      case 'food':
      case 'cafe':
      case 'coffee':
        return 'food';
      case 'hotel':
      case 'lodging':
      case 'accommodation':
        return 'hotel';
      case 'park':
      case 'nature':
      case 'outdoor':
        return 'nature';
      case 'shopping':
      case 'store':
      case 'mall':
        return 'shopping';
      case 'museum':
      case 'art':
      case 'culture':
        return 'culture';
      case 'coworking':
      case 'office':
      case 'work':
        return 'work';
      case 'entertainment':
      case 'bar':
      case 'nightlife':
        return 'entertainment';
      default:
        return 'place';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'place_name': placeName,
      'place_type': placeType,
      'address': address,
      'arrival_time': arrivalTime.toIso8601String(),
      'departure_time': departureTime.toIso8601String(),
      'photo_url': photoUrl,
      'notes': notes,
      'is_highlight': isHighlight ? 1 : 0,
    };
  }

  factory VisitedPlace.fromMap(Map<String, dynamic> map) {
    return VisitedPlace(
      id: map['id'] as int?,
      tripId: map['trip_id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      placeName: map['place_name'] as String?,
      placeType: map['place_type'] as String?,
      address: map['address'] as String?,
      arrivalTime: DateTime.parse(map['arrival_time'] as String),
      departureTime: DateTime.parse(map['departure_time'] as String),
      photoUrl: map['photo_url'] as String?,
      notes: map['notes'] as String?,
      isHighlight: (map['is_highlight'] as int?) == 1,
    );
  }

  VisitedPlace copyWith({
    int? id,
    String? tripId,
    double? latitude,
    double? longitude,
    String? placeName,
    String? placeType,
    String? address,
    DateTime? arrivalTime,
    DateTime? departureTime,
    String? photoUrl,
    String? notes,
    bool? isHighlight,
  }) {
    return VisitedPlace(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      placeType: placeType ?? this.placeType,
      address: address ?? this.address,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      isHighlight: isHighlight ?? this.isHighlight,
    );
  }

  @override
  String toString() {
    return 'VisitedPlace(id: $id, tripId: $tripId, placeName: $placeName, duration: $formattedDuration)';
  }
}
