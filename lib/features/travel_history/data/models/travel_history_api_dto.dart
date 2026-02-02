/// 旅行历史 DTO（匹配后端 API 返回格式）
class TravelHistoryApiDto {
  final String id;
  final String userId;
  final String city;
  final String country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final bool isConfirmed;
  final String? review;
  final double? rating;
  final List<String>? photos;
  final String? cityId;
  final int? durationDays;
  final bool isOngoing;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelHistoryApiDto({
    required this.id,
    required this.userId,
    required this.city,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    required this.arrivalTime,
    this.departureTime,
    required this.isConfirmed,
    this.review,
    this.rating,
    this.photos,
    this.cityId,
    this.durationDays,
    required this.isOngoing,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelHistoryApiDto.fromJson(Map<String, dynamic> json) {
    // 安全解析 durationDays，可能是 int 或 String
    int? parseDurationDays(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return TravelHistoryApiDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime'] as String) : null,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      review: json['review'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cityId: json['cityId'] as String?,
      durationDays: parseDurationDays(json['durationDays']),
      isOngoing: json['isOngoing'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'city': city,
      'country': country,
      if (countryCode != null) 'countryCode': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'arrivalTime': arrivalTime.toIso8601String(),
      if (departureTime != null) 'departureTime': departureTime!.toIso8601String(),
      'isConfirmed': isConfirmed,
      if (review != null) 'review': review,
      if (rating != null) 'rating': rating,
      if (photos != null) 'photos': photos,
      if (cityId != null) 'cityId': cityId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 创建旅行历史请求 DTO
class CreateTravelHistoryRequest {
  final String city;
  final String country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final bool isConfirmed;
  final String? review;
  final double? rating;
  final List<String>? photos;
  final String? cityId;

  CreateTravelHistoryRequest({
    required this.city,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    required this.arrivalTime,
    this.departureTime,
    this.isConfirmed = true,
    this.review,
    this.rating,
    this.photos,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      if (countryCode != null) 'countryCode': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'arrivalTime': arrivalTime.toIso8601String(),
      if (departureTime != null) 'departureTime': departureTime!.toIso8601String(),
      'isConfirmed': isConfirmed,
      if (review != null) 'review': review,
      if (rating != null) 'rating': rating,
      if (photos != null) 'photos': photos,
      if (cityId != null) 'cityId': cityId,
    };
  }
}

/// 更新旅行历史请求 DTO
class UpdateTravelHistoryRequest {
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final bool? isConfirmed;
  final String? review;
  final double? rating;
  final List<String>? photos;
  final String? cityId;

  UpdateTravelHistoryRequest({
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.arrivalTime,
    this.departureTime,
    this.isConfirmed,
    this.review,
    this.rating,
    this.photos,
    this.cityId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (city != null) json['city'] = city;
    if (country != null) json['country'] = country;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (arrivalTime != null) {
      json['arrivalTime'] = arrivalTime!.toIso8601String();
    }
    if (departureTime != null) {
      json['departureTime'] = departureTime!.toIso8601String();
    }
    if (isConfirmed != null) json['isConfirmed'] = isConfirmed;
    if (review != null) json['review'] = review;
    if (rating != null) json['rating'] = rating;
    if (photos != null) json['photos'] = photos;
    if (cityId != null) json['cityId'] = cityId;
    return json;
  }
}

/// 批量创建旅行历史请求 DTO
class BatchCreateTravelHistoryRequest {
  final List<CreateTravelHistoryRequest> items;

  BatchCreateTravelHistoryRequest({required this.items});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// 旅行历史统计 DTO
class TravelHistoryStatsDto {
  final int totalTrips;
  final int confirmedTrips;
  final int unconfirmedTrips;
  final int countriesVisited;
  final int citiesVisited;
  final int totalDays;

  TravelHistoryStatsDto({
    required this.totalTrips,
    required this.confirmedTrips,
    required this.unconfirmedTrips,
    required this.countriesVisited,
    required this.citiesVisited,
    required this.totalDays,
  });

  factory TravelHistoryStatsDto.fromJson(Map<String, dynamic> json) {
    return TravelHistoryStatsDto(
      totalTrips: json['totalTrips'] as int? ?? 0,
      confirmedTrips: json['confirmedTrips'] as int? ?? 0,
      unconfirmedTrips: json['unconfirmedTrips'] as int? ?? 0,
      countriesVisited: json['countriesVisited'] as int? ?? 0,
      citiesVisited: json['citiesVisited'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
    );
  }
}

/// 旅行历史简要 DTO（用于列表展示）
class TravelHistorySummaryDto {
  final String id;
  final String city;
  final String country;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final int? durationDays;
  final bool isConfirmed;
  final double? rating;

  TravelHistorySummaryDto({
    required this.id,
    required this.city,
    required this.country,
    required this.arrivalTime,
    this.departureTime,
    this.durationDays,
    required this.isConfirmed,
    this.rating,
  });

  factory TravelHistorySummaryDto.fromJson(Map<String, dynamic> json) {
    return TravelHistorySummaryDto(
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime'] as String) : null,
      durationDays: json['durationDays'] as int?,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
