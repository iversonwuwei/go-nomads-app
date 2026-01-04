/// 访问地点 API DTO（匹配后端 API 返回格式）
class VisitedPlaceApiDto {
  final String id;
  final String travelHistoryId;
  final String userId;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? placeType;
  final String? address;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final int durationMinutes;
  final String? photoUrl;
  final String? notes;
  final bool isHighlight;
  final String? googlePlaceId;
  final String? clientId;
  final String formattedDuration;
  final String iconType;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisitedPlaceApiDto({
    required this.id,
    required this.travelHistoryId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.placeType,
    this.address,
    required this.arrivalTime,
    required this.departureTime,
    required this.durationMinutes,
    this.photoUrl,
    this.notes,
    required this.isHighlight,
    this.googlePlaceId,
    this.clientId,
    required this.formattedDuration,
    required this.iconType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitedPlaceApiDto.fromJson(Map<String, dynamic> json) {
    return VisitedPlaceApiDto(
      id: json['id'] as String,
      travelHistoryId: json['travelHistoryId'] as String,
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String?,
      placeType: json['placeType'] as String?,
      address: json['address'] as String?,
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      departureTime: DateTime.parse(json['departureTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      isHighlight: json['isHighlight'] as bool? ?? false,
      googlePlaceId: json['googlePlaceId'] as String?,
      clientId: json['clientId'] as String?,
      formattedDuration: json['formattedDuration'] as String? ?? '',
      iconType: json['iconType'] as String? ?? 'place',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelHistoryId': travelHistoryId,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      if (placeName != null) 'placeName': placeName,
      if (placeType != null) 'placeType': placeType,
      if (address != null) 'address': address,
      'arrivalTime': arrivalTime.toIso8601String(),
      'departureTime': departureTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (notes != null) 'notes': notes,
      'isHighlight': isHighlight,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (clientId != null) 'clientId': clientId,
      'formattedDuration': formattedDuration,
      'iconType': iconType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 创建访问地点请求 DTO
class CreateVisitedPlaceRequest {
  final String travelHistoryId;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? placeType;
  final String? address;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final String? photoUrl;
  final String? notes;
  final bool isHighlight;
  final String? googlePlaceId;
  final String? clientId;

  CreateVisitedPlaceRequest({
    required this.travelHistoryId,
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
    this.googlePlaceId,
    this.clientId,
  });

  Map<String, dynamic> toJson() {
    return {
      'travelHistoryId': travelHistoryId,
      'latitude': latitude,
      'longitude': longitude,
      if (placeName != null) 'placeName': placeName,
      if (placeType != null) 'placeType': placeType,
      if (address != null) 'address': address,
      'arrivalTime': arrivalTime.toIso8601String(),
      'departureTime': departureTime.toIso8601String(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (notes != null) 'notes': notes,
      'isHighlight': isHighlight,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (clientId != null) 'clientId': clientId,
    };
  }
}

/// 批量创建访问地点请求 DTO
class BatchCreateVisitedPlaceRequest {
  final String travelHistoryId;
  final List<CreateVisitedPlaceRequest> items;

  BatchCreateVisitedPlaceRequest({
    required this.travelHistoryId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'travelHistoryId': travelHistoryId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// 访问地点统计 DTO
class VisitedPlaceStatsDto {
  final String travelHistoryId;
  final int totalPlaces;
  final int highlightPlaces;
  final int totalDurationMinutes;
  final Map<String, int> placeTypeDistribution;

  VisitedPlaceStatsDto({
    required this.travelHistoryId,
    required this.totalPlaces,
    required this.highlightPlaces,
    required this.totalDurationMinutes,
    required this.placeTypeDistribution,
  });

  factory VisitedPlaceStatsDto.fromJson(Map<String, dynamic> json) {
    return VisitedPlaceStatsDto(
      travelHistoryId: json['travelHistoryId'] as String,
      totalPlaces: json['totalPlaces'] as int,
      highlightPlaces: json['highlightPlaces'] as int,
      totalDurationMinutes: json['totalDurationMinutes'] as int,
      placeTypeDistribution: (json['placeTypeDistribution'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
    );
  }
}
