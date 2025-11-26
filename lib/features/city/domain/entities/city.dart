/// Moderator Domain Entity - 版主实体
class Moderator {
  final String id;
  final String name;
  final String? email;
  final String? avatar;

  const Moderator({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });

  factory Moderator.fromJson(Map<String, dynamic> json) {
    return Moderator(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (avatar != null) 'avatar': avatar,
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

/// City Domain Entity - 城市实体
///
/// 代表系统中的核心城市概念,包含城市的基本信息和业务逻辑
class City {
  final String id; // UUID
  final String name; // 城市名称
  final String? nameEn; // 英文名称
  final String? country; // 国家
  final String? region; // 地区 (如 Asia, Europe)
  final String? imageUrl; // 城市图片
  final String? description; // 描述
  final String? timezone; // 时区
  final String? population; // 人口

  // 天气相关
  final int? temperature; // 温度
  final int? feelsLike; // 体感温度
  final String? weather; // 天气状况
  final int? humidity; // 湿度
  final int? airQualityIndex; // 空气质量指数

  // 评分相关
  final double? overallScore; // 总体评分
  final double? costScore; // 成本评分
  final double? internetScore; // 网速评分
  final double? safetyScore; // 安全评分
  final double? likedScore; // 喜爱度

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
    this.description,
    this.timezone,
    this.population,
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

  /// 获取天气图标
  String get weatherIcon {
    switch (weather?.toLowerCase()) {
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

    // 调试日志
    print(
        '🔍 City.fromJson: reviewCount=${json['reviewCount']}, averageCost=${json['averageCost']}');
    
    return City(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      nameEn: json['nameEn'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      timezone: json['timezone'] as String?,
      population: json['population'] as String?,
      temperature: weather?['temperature']?.toInt(),
      feelsLike: weather?['feelsLike']?.toInt(),
      weather: weather?['weather']?.toString(),
      humidity: weather?['humidity']?.toInt(),
      airQualityIndex: weather?['airQualityIndex']?.toInt(),
      overallScore: json['overallScore']?.toDouble(),
      costScore: json['costScore']?.toDouble(),
      internetScore: json['internetScore']?.toDouble(),
      safetyScore: json['safetyScore']?.toDouble(),
      likedScore: json['likedScore']?.toDouble(),
      meetupCount: json['meetupCount']?.toInt(),
      reviewCount: json['reviewCount']?.toInt(),
      coworkingCount: json['coworkingCount']?.toInt(),
      averageCost: json['averageCost']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      moderatorId: json['moderatorId'] as String?,
      moderator:
          moderatorData != null ? Moderator.fromJson(moderatorData) : null,
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
      if (description != null) 'description': description,
      if (timezone != null) 'timezone': timezone,
      if (population != null) 'population': population,
      if (temperature != null ||
          feelsLike != null ||
          weather != null ||
          humidity != null ||
          airQualityIndex != null)
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
    String? description,
    String? timezone,
    String? population,
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
      description: description ?? this.description,
      timezone: timezone ?? this.timezone,
      population: population ?? this.population,
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
      meetupCount: meetupCount ?? this.meetupCount,
      reviewCount: reviewCount ?? this.reviewCount,
      coworkingCount: coworkingCount ?? this.coworkingCount,
      averageCost: averageCost ?? this.averageCost,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      moderatorId: moderatorId ?? this.moderatorId,
      moderator: moderator ?? this.moderator,
      isCurrentUserModerator:
          isCurrentUserModerator ?? this.isCurrentUserModerator,
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
