/// Moderator Domain Entity - 版主实体
class Moderator {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final ModeratorTravelStats? stats;
  final ModeratorTravelHistory? latestTravelHistory;

  const Moderator({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    this.stats,
    this.latestTravelHistory,
  });

  factory Moderator.fromJson(Map<String, dynamic> json) {
    return Moderator(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      stats: json['stats'] != null ? ModeratorTravelStats.fromJson(json['stats'] as Map<String, dynamic>) : null,
      latestTravelHistory: json['latestTravelHistory'] != null
          ? ModeratorTravelHistory.fromJson(json['latestTravelHistory'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (avatar != null) 'avatar': avatar,
      if (stats != null) 'stats': stats!.toJson(),
      if (latestTravelHistory != null) 'latestTravelHistory': latestTravelHistory!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Moderator && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Moderator(id: $id, name: $name)';
}

/// 版主旅行统计
class ModeratorTravelStats {
  final int countriesVisited;
  final int citiesVisited;
  final int totalDays;
  final int totalTrips;

  const ModeratorTravelStats({
    this.countriesVisited = 0,
    this.citiesVisited = 0,
    this.totalDays = 0,
    this.totalTrips = 0,
  });

  factory ModeratorTravelStats.fromJson(Map<String, dynamic> json) {
    return ModeratorTravelStats(
      countriesVisited: json['countriesVisited'] as int? ?? 0,
      citiesVisited: json['citiesVisited'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
      totalTrips: json['totalTrips'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countriesVisited': countriesVisited,
      'citiesVisited': citiesVisited,
      'totalDays': totalDays,
      'totalTrips': totalTrips,
    };
  }
}

/// 版主最新旅行历史
class ModeratorTravelHistory {
  final String? cityName;
  final String? countryName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const ModeratorTravelHistory({
    this.cityName,
    this.countryName,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory ModeratorTravelHistory.fromJson(Map<String, dynamic> json) {
    return ModeratorTravelHistory(
      cityName: json['cityName'] as String?,
      countryName: json['countryName'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cityName != null) 'cityName': cityName,
      if (countryName != null) 'countryName': countryName,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (status != null) 'status': status,
    };
  }
}

/// City Domain Entity - 城市实体
///
/// 代表系统中的核心城市概念,包含城市的基本信息和业务逻辑
class City {
  final String id; // UUID
  final String name; // 城市名称
  final String? nameEn; // 英文名称
  final String? country; // 国家
  final String? region; // 地区 (如 Asia, Europe)
  final String? imageUrl; // 城市图片（主图，向后兼容）
  final String? portraitImageUrl; // 竖屏封面图 (720x1280)
  final List<String>? landscapeImageUrls; // 横屏图片列表 (1280x720)
  final String? description; // 描述
  final String? timezone; // 时区
  final String? population; // 人口
  final String? currency; // 货币

  // 天气相关（实时数据，仅在详情页加载）
  final int? temperature; // 温度
  final int? feelsLike; // 体感温度
  final String? weather; // 天气状况
  final int? humidity; // 湿度
  final int? airQualityIndex; // 空气质量指数

  // 评分相关 - 数字游民核心关注指标
  final double? overallScore; // 总体评分
  final double? costScore; // 成本评分
  final double? internetScore; // 网速评分
  final double? safetyScore; // 安全评分
  final double? likedScore; // 喜爱度
  final double? communityScore; // 社区活跃度评分
  final double? weatherScore; // 天气评分（静态评分）

  // 城市标签 - 快速了解城市特点
  final List<String>? tags;

  // 统计数据
  final int? meetupCount; // Meetup 数量
  final int? reviewCount; // 评论数量
  final int? coworkingCount; // Coworking 空间数量

  // 社区数据
  final double? averageCost; // 平均花费（社区统计）

  // 地理坐标
  final double? latitude; // 纬度
  final double? longitude; // 经度

  // 用户交互
  final bool isFavorite; // 是否收藏

  // 版主信息
  final String? moderatorId; // 版主 ID
  final Moderator? moderator; // 版主详情

  // 当前用户权限（由后端返回）
  final bool isCurrentUserModerator; // 当前用户是否为该城市版主
  final bool isCurrentUserAdmin; // 当前用户是否为管理员

  const City({
    required this.id,
    required this.name,
    this.nameEn,
    this.country,
    this.region,
    this.imageUrl,
    this.portraitImageUrl,
    this.landscapeImageUrls,
    this.description,
    this.timezone,
    this.population,
    this.currency,
    this.temperature,
    this.feelsLike,
    this.weather,
    this.humidity,
    this.airQualityIndex,
    this.overallScore,
    this.costScore,
    this.internetScore,
    this.safetyScore,
    this.likedScore,
    this.communityScore,
    this.weatherScore,
    this.tags,
    this.meetupCount,
    this.reviewCount,
    this.coworkingCount,
    this.averageCost,
    this.latitude,
    this.longitude,
    this.isFavorite = false,
    this.moderatorId,
    this.moderator,
    this.isCurrentUserModerator = false,
    this.isCurrentUserAdmin = false,
  });

  /// Business Logic Methods

  /// 是否有版主
  bool get hasModerator => moderatorId != null && moderatorId!.isNotEmpty;

  /// 获取空气质量等级
  String get airQualityLevel {
    if (airQualityIndex == null) return 'Unknown';
    if (airQualityIndex! <= 50) return 'Good';
    if (airQualityIndex! <= 100) return 'Moderate';
    if (airQualityIndex! <= 150) return 'Unhealthy for Sensitive';
    if (airQualityIndex! <= 200) return 'Unhealthy';
    if (airQualityIndex! <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// 是否为高质量城市 (overall >= 4.0)
  bool get isHighQuality => (overallScore ?? 0) >= 4.0;

  /// 是否为热门城市 (meetup count > 5)
  bool get isPopular => (meetupCount ?? 0) > 5;

  /// 是否有 Coworking 空间
  bool get hasCoworking => (coworkingCount ?? 0) > 0;

  /// 获取显示名称 (优先英文)
  String get displayName => nameEn ?? name;

  /// 获取完整地址 (城市, 国家)
  String get fullLocation {
    if (country == null) return name;
    return '$name, $country';
  }

  // ============================================================
  // 智能默认值 Getters - 用于 UI 显示，确保不显示 null
  // ============================================================

  /// 显示用国家名（默认: 未知）
  String get displayCountry => country ?? 'Unknown';

  /// 显示用地区（默认: Global）
  String get displayRegion => region ?? 'Global';

  /// 显示用温度（默认: 25°C）
  int get displayTemperature => temperature ?? 25;

  /// 显示用天气（默认: Sunny）
  String get displayWeather => weather ?? 'Sunny';

  /// 显示用湿度（默认: 60%）
  int get displayHumidity => humidity ?? 60;

  /// 显示用空气质量指数（默认: 50 - Good）
  int get displayAirQualityIndex => airQualityIndex ?? 50;

  /// 显示用综合评分（默认: 3.0）
  double get displayOverallScore => overallScore ?? 3.0;

  /// 显示用成本评分（默认: 3.0）
  double get displayCostScore => costScore ?? 3.0;

  /// 显示用网速评分（默认: 3.0）
  double get displayInternetScore => internetScore ?? 3.0;

  /// 显示用安全评分（默认: 3.0）
  double get displaySafetyScore => safetyScore ?? 3.0;

  /// 显示用喜爱度（默认: 3.0）
  double get displayLikedScore => likedScore ?? 3.0;

  /// 显示用 Meetup 数量（默认: 0）
  int get displayMeetupCount => meetupCount ?? 0;

  /// 显示用评论数量（默认: 0）
  int get displayReviewCount => reviewCount ?? 0;

  /// 显示用 Coworking 数量（默认: 0）
  int get displayCoworkingCount => coworkingCount ?? 0;

  /// 显示用平均花费（默认: 1500 USD/月）
  double get displayAverageCost => averageCost ?? 1500.0;

  /// 显示用人口（默认: 未知）
  String get displayPopulation => population ?? 'Unknown';

  /// 显示用时区（默认: UTC）
  String get displayTimezone => timezone ?? 'UTC';

  /// 显示用描述（默认: 城市简介）
  String get displayDescription => description ?? 'A vibrant city waiting to be explored by digital nomads.';

  /// 显示用图片（默认占位图）
  String get displayImageUrl => imageUrl ?? 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800';

  /// 显示用竖屏图片（默认占位图）
  String get displayPortraitImageUrl =>
      portraitImageUrl ?? 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=720&h=1280&fit=crop';

  /// 获取天气图标
  String get weatherIcon {
    switch (displayWeather.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'overcast':
        return '☁️';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'snowy':
      case 'snow':
        return '❄️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      default:
        return '🌤️';
    }
  }

  /// 从 JSON 创建实体
  factory City.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'] as Map<String, dynamic>?;
    final moderatorData = json['moderator'] as Map<String, dynamic>?;

    // 解析横屏图片列表
    final rawLandscapeImageUrls = json['landscapeImageUrls'];
    List<String>? landscapeImageUrls;
    if (rawLandscapeImageUrls != null) {
      if (rawLandscapeImageUrls is List) {
        landscapeImageUrls = rawLandscapeImageUrls.map((e) => e.toString()).toList();
      }
    }

    // 解析城市标签
    final rawTags = json['tags'];
    List<String>? tags;
    if (rawTags != null && rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    }

    return City(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      nameEn: json['nameEn'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      imageUrl: json['imageUrl'] as String?,
      portraitImageUrl: json['portraitImageUrl'] as String?,
      landscapeImageUrls: landscapeImageUrls,
      description: json['description'] as String?,
      timezone: json['timeZone'] as String? ?? json['timezone'] as String?,
      population: json['population'] as String?,
      currency: json['currency'] as String?,
      temperature: weather?['temperature']?.toInt(),
      feelsLike: weather?['feelsLike']?.toInt(),
      weather: weather?['weather']?.toString(),
      humidity: weather?['humidity']?.toInt(),
      airQualityIndex: weather?['airQualityIndex']?.toInt(),
      overallScore: json['overallScore']?.toDouble(),
      costScore: json['costScore']?.toDouble(),
      internetScore: json['internetQualityScore']?.toDouble() ?? json['internetScore']?.toDouble(),
      safetyScore: json['safetyScore']?.toDouble(),
      likedScore: json['likedScore']?.toDouble(),
      communityScore: json['communityScore']?.toDouble(),
      weatherScore: json['weatherScore']?.toDouble(),
      tags: tags,
      meetupCount: json['meetupCount']?.toInt(),
      reviewCount: json['reviewCount']?.toInt(),
      coworkingCount: json['coworkingCount']?.toInt(),
      averageCost: json['averageCost']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      moderatorId: json['moderatorId'] as String?,
      moderator: moderatorData != null ? Moderator.fromJson(moderatorData) : null,
      isCurrentUserModerator: json['isCurrentUserModerator'] as bool? ?? false,
      isCurrentUserAdmin: json['isCurrentUserAdmin'] as bool? ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      if (country != null) 'country': country,
      if (region != null) 'region': region,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (portraitImageUrl != null) 'portraitImageUrl': portraitImageUrl,
      if (landscapeImageUrls != null && landscapeImageUrls!.isNotEmpty) 'landscapeImageUrls': landscapeImageUrls,
      if (description != null) 'description': description,
      if (timezone != null) 'timezone': timezone,
      if (population != null) 'population': population,
      if (currency != null) 'currency': currency,
      if (temperature != null || feelsLike != null || weather != null || humidity != null || airQualityIndex != null)
        'weather': {
          if (temperature != null) 'temperature': temperature,
          if (feelsLike != null) 'feelsLike': feelsLike,
          if (weather != null) 'weather': weather,
          if (humidity != null) 'humidity': humidity,
          if (airQualityIndex != null) 'airQualityIndex': airQualityIndex,
        },
      if (overallScore != null) 'overallScore': overallScore,
      if (costScore != null) 'costScore': costScore,
      if (internetScore != null) 'internetScore': internetScore,
      if (safetyScore != null) 'safetyScore': safetyScore,
      if (likedScore != null) 'likedScore': likedScore,
      if (communityScore != null) 'communityScore': communityScore,
      if (weatherScore != null) 'weatherScore': weatherScore,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      if (meetupCount != null) 'meetupCount': meetupCount,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (coworkingCount != null) 'coworkingCount': coworkingCount,
      if (averageCost != null) 'averageCost': averageCost,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isFavorite': isFavorite,
      if (moderatorId != null) 'moderatorId': moderatorId,
      if (moderator != null) 'moderator': moderator!.toJson(),
      'isCurrentUserModerator': isCurrentUserModerator,
      'isCurrentUserAdmin': isCurrentUserAdmin,
    };
  }

  /// 复制并修改字段
  City copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? country,
    String? region,
    String? imageUrl,
    String? portraitImageUrl,
    List<String>? landscapeImageUrls,
    String? description,
    String? timezone,
    String? population,
    String? currency,
    int? temperature,
    int? feelsLike,
    String? weather,
    int? humidity,
    int? airQualityIndex,
    double? overallScore,
    double? costScore,
    double? internetScore,
    double? safetyScore,
    double? likedScore,
    double? communityScore,
    double? weatherScore,
    List<String>? tags,
    int? meetupCount,
    int? reviewCount,
    int? coworkingCount,
    double? averageCost,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    String? moderatorId,
    Moderator? moderator,
    bool? isCurrentUserModerator,
    bool? isCurrentUserAdmin,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      country: country ?? this.country,
      region: region ?? this.region,
      imageUrl: imageUrl ?? this.imageUrl,
      portraitImageUrl: portraitImageUrl ?? this.portraitImageUrl,
      landscapeImageUrls: landscapeImageUrls ?? this.landscapeImageUrls,
      description: description ?? this.description,
      timezone: timezone ?? this.timezone,
      population: population ?? this.population,
      currency: currency ?? this.currency,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      weather: weather ?? this.weather,
      humidity: humidity ?? this.humidity,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      overallScore: overallScore ?? this.overallScore,
      costScore: costScore ?? this.costScore,
      internetScore: internetScore ?? this.internetScore,
      safetyScore: safetyScore ?? this.safetyScore,
      likedScore: likedScore ?? this.likedScore,
      communityScore: communityScore ?? this.communityScore,
      weatherScore: weatherScore ?? this.weatherScore,
      tags: tags ?? this.tags,
      meetupCount: meetupCount ?? this.meetupCount,
      reviewCount: reviewCount ?? this.reviewCount,
      coworkingCount: coworkingCount ?? this.coworkingCount,
      averageCost: averageCost ?? this.averageCost,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      moderatorId: moderatorId ?? this.moderatorId,
      moderator: moderator ?? this.moderator,
      isCurrentUserModerator: isCurrentUserModerator ?? this.isCurrentUserModerator,
      isCurrentUserAdmin: isCurrentUserAdmin ?? this.isCurrentUserAdmin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City(id: $id, name: $name, country: $country)';
}

/// 城市聚合数据 - 用于异步加载
/// 包含需要单独查询的统计数据
class CityCountsData {
  final String cityId;
  final int meetupCount;
  final int coworkingCount;
  final int reviewCount;
  final double averageCost;

  const CityCountsData({
    required this.cityId,
    this.meetupCount = 0,
    this.coworkingCount = 0,
    this.reviewCount = 0,
    this.averageCost = 0,
  });

  factory CityCountsData.fromJson(Map<String, dynamic> json) {
    return CityCountsData(
      cityId: json['cityId'] as String,
      meetupCount: json['meetupCount']?.toInt() ?? 0,
      coworkingCount: json['coworkingCount']?.toInt() ?? 0,
      reviewCount: json['reviewCount']?.toInt() ?? 0,
      averageCost: json['averageCost']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'meetupCount': meetupCount,
      'coworkingCount': coworkingCount,
      'reviewCount': reviewCount,
      'averageCost': averageCost,
    };
  }

  @override
  String toString() =>
      'CityCountsData(cityId: $cityId, meetup: $meetupCount, coworking: $coworkingCount, review: $reviewCount, avgCost: $averageCost)';
}
