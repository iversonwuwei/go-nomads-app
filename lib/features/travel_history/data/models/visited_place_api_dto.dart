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
      placeTypeDistribution:
          (json['placeTypeDistribution'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as int)) ??
              {},
    );
  }
}

/// 城市访问摘要 DTO - 用于 Visited Places 页面头部信息
/// 对应后端 VisitedPlacesCitySummaryDto
class VisitedPlacesCitySummaryDto {
  /// 城市 ID
  final String cityId;

  /// 城市名称（本地语言）
  final String cityName;

  /// 城市英文名称
  final String? cityNameEn;

  /// 国家名称
  final String country;

  /// 城市图片 URL
  final String? imageUrl;

  /// 旅行日期（第一次到达）
  final DateTime? travelDate;

  /// 最后访问日期
  final DateTime? lastVisitDate;

  /// 总停留天数
  final int totalDurationDays;

  /// 当前天气信息
  final CityWeatherDto? weather;

  /// 城市综合评分 (0-5)
  final double? overallScore;

  /// 平均每月花费（美元）
  final double? averageMonthlyCost;

  /// 共享办公空间数量
  final int coworkingSpaceCount;

  /// 访问地点分页列表
  final PaginatedVisitedPlacesDto visitedPlaces;

  VisitedPlacesCitySummaryDto({
    required this.cityId,
    required this.cityName,
    this.cityNameEn,
    required this.country,
    this.imageUrl,
    this.travelDate,
    this.lastVisitDate,
    required this.totalDurationDays,
    this.weather,
    this.overallScore,
    this.averageMonthlyCost,
    required this.coworkingSpaceCount,
    required this.visitedPlaces,
  });

  factory VisitedPlacesCitySummaryDto.fromJson(Map<String, dynamic> json) {
    return VisitedPlacesCitySummaryDto(
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      cityNameEn: json['cityNameEn'] as String?,
      country: json['country'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      travelDate: json['travelDate'] != null ? DateTime.tryParse(json['travelDate'] as String) : null,
      lastVisitDate: json['lastVisitDate'] != null ? DateTime.tryParse(json['lastVisitDate'] as String) : null,
      totalDurationDays: json['totalDurationDays'] as int? ?? 0,
      weather: json['weather'] != null ? CityWeatherDto.fromJson(json['weather'] as Map<String, dynamic>) : null,
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      averageMonthlyCost: (json['averageMonthlyCost'] as num?)?.toDouble(),
      coworkingSpaceCount: json['coworkingSpaceCount'] as int? ?? 0,
      visitedPlaces: json['visitedPlaces'] != null
          ? PaginatedVisitedPlacesDto.fromJson(json['visitedPlaces'] as Map<String, dynamic>)
          : PaginatedVisitedPlacesDto.empty(),
    );
  }

  /// 获取显示用的城市名称（优先英文名）
  String get displayName => cityNameEn ?? cityName;

  /// 格式化的停留时长
  String get formattedDuration {
    if (totalDurationDays == 0) return '当天';
    if (totalDurationDays == 1) return '1 天';
    return '$totalDurationDays 天';
  }

  /// 格式化的旅行日期范围
  String get formattedDateRange {
    if (travelDate == null) return '';
    final start = _formatDate(travelDate!);
    if (lastVisitDate == null || lastVisitDate == travelDate) {
      return start;
    }
    return '$start - ${_formatDate(lastVisitDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// 城市天气 DTO
/// 对应后端 CityWeatherDto
class CityWeatherDto {
  /// 当前温度（摄氏度）
  final double temperature;

  /// 体感温度
  final double? feelsLike;

  /// 天气状况描述
  final String condition;

  /// 天气图标代码
  final String icon;

  /// 湿度 (%)
  final int? humidity;

  /// 风速
  final String? windSpeed;

  CityWeatherDto({
    required this.temperature,
    this.feelsLike,
    required this.condition,
    required this.icon,
    this.humidity,
    this.windSpeed,
  });

  factory CityWeatherDto.fromJson(Map<String, dynamic> json) {
    return CityWeatherDto(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble(),
      condition: json['condition'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      humidity: json['humidity'] as int?,
      windSpeed: json['windSpeed'] as String?,
    );
  }

  /// 格式化的温度显示
  String get formattedTemperature => '${temperature.round()}°C';

  /// 格式化的体感温度显示
  String? get formattedFeelsLike => feelsLike != null ? '${feelsLike!.round()}°C' : null;
}

/// 分页访问地点列表 DTO
/// 对应后端 PaginatedVisitedPlacesDto
class PaginatedVisitedPlacesDto {
  /// 访问地点列表
  final List<VisitedPlaceApiDto> items;

  /// 总数量
  final int totalCount;

  /// 当前页码
  final int page;

  /// 每页数量
  final int pageSize;

  PaginatedVisitedPlacesDto({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedVisitedPlacesDto.fromJson(Map<String, dynamic> json) {
    return PaginatedVisitedPlacesDto(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => VisitedPlaceApiDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  /// 创建空的分页结果
  factory PaginatedVisitedPlacesDto.empty() {
    return PaginatedVisitedPlacesDto(
      items: [],
      totalCount: 0,
      page: 1,
      pageSize: 20,
    );
  }

  /// 是否有更多数据
  bool get hasMore => page * pageSize < totalCount;

  /// 是否为空
  bool get isEmpty => items.isEmpty;

  /// 是否有数据
  bool get isNotEmpty => items.isNotEmpty;
}
