/// CoworkingSpace 领域实体
/// 共享办公空间聚合根
class CoworkingSpace {
  final String id;
  final String name;
  final Location location;
  final ContactInfo contactInfo;
  final SpaceInfo spaceInfo;
  final Pricing pricing;
  final Amenities amenities;
  final Specifications specs;
  final OperationHours operationHours;
  final bool isVerified;
  final DateTime? lastUpdated;

  CoworkingSpace({
    required this.id,
    required this.name,
    required this.location,
    required this.contactInfo,
    required this.spaceInfo,
    required this.pricing,
    required this.amenities,
    required this.specs,
    required this.operationHours,
    this.isVerified = false,
    this.lastUpdated,
  });

  // === 业务逻辑方法 ===

  /// 是否有每日价格
  bool get hasDailyRate => pricing.dailyRate != null;

  /// 是否有月度价格
  bool get hasMonthlyRate => pricing.monthlyRate != null;

  /// 是否提供免费试用
  bool get hasFreeTrial => pricing.hasFreeTrial;

  /// 获取最低价格(用于比较)
  double get lowestPrice {
    final prices = [
      pricing.hourlyRate,
      pricing.dailyRate,
      pricing.weeklyRate,
      pricing.monthlyRate,
    ].whereType<double>().toList();

    if (prices.isEmpty) return 0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  /// 是否高评分 (4.0+)
  bool get isHighlyRated => spaceInfo.rating >= 4.0;

  /// 是否有足够的评论数量
  bool get hasEnoughReviews => spaceInfo.reviewCount >= 10;

  /// 是否可信赖 (已验证 + 高评分 + 足够评论)
  bool get isTrusted => isVerified && isHighlyRated && hasEnoughReviews;

  /// 是否有高速网络 (50+ Mbps)
  bool get hasHighSpeedInternet =>
      specs.wifiSpeed != null && specs.wifiSpeed! >= 50;

  /// 是否适合团队 (有会议室)
  bool get isSuitableForTeams => amenities.hasMeetingRoom;

  /// 是否24/7可用
  bool get is24HourAccess => amenities.has24HourAccess;

  /// 获取完整地址
  String get fullAddress =>
      '${location.address}, ${location.city}, ${location.country}';

  /// 获取地图链接
  String get googleMapsUrl =>
      'https://www.google.com/maps?q=${location.latitude},${location.longitude}';

  /// 获取所有可用设施列表
  List<String> get availableAmenities => amenities.getAvailableAmenities();

  /// 检查是否有特定设施
  bool hasAmenity(String amenity) {
    return availableAmenities
        .any((a) => a.toLowerCase().contains(amenity.toLowerCase()));
  }

  /// 计算性价比分数 (0-100)
  /// 基于价格、评分、设施
  int get valueScore {
    int score = 0;

    // 评分贡献 (40分)
    score += (spaceInfo.rating * 8).toInt();

    // 价格合理性 (30分) - 价格越低越好
    if (pricing.monthlyRate != null) {
      if (pricing.monthlyRate! < 100) {
        score += 30;
      } else if (pricing.monthlyRate! < 200) {
        score += 20;
      } else if (pricing.monthlyRate! < 300) {
        score += 10;
      }
    }

    // 设施丰富度 (30分)
    final amenityCount = availableAmenities.length;
    if (amenityCount >= 10) {
      score += 30;
    } else {
      score += (amenityCount * 3);
    }

    return score.clamp(0, 100);
  }
}

/// Location 值对象
class Location {
  final String? cityId; // 添加 cityId 字段
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    this.cityId, // 添加到构造函数
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// 计算与另一个位置的距离(简化版)
  double distanceTo(Location other) {
    // 简化的距离计算,实际应使用Haversine公式
    final latDiff = (latitude - other.latitude).abs();
    final lonDiff = (longitude - other.longitude).abs();
    return (latDiff + lonDiff) * 111; // 粗略转换为km
  }
}

/// ContactInfo 值对象
class ContactInfo {
  final String phone;
  final String email;
  final String website;

  ContactInfo({
    this.phone = '',
    this.email = '',
    this.website = '',
  });

  bool get hasPhone => phone.isNotEmpty;
  bool get hasEmail => email.isNotEmpty;
  bool get hasWebsite => website.isNotEmpty;
}

/// SpaceInfo 值对象
class SpaceInfo {
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String description;

  SpaceInfo({
    required this.imageUrl,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.description,
  });

  bool get hasMultipleImages => images.length > 1;
  bool get hasDescription => description.isNotEmpty;
}

/// Pricing 值对象
class Pricing {
  final double? hourlyRate;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final String currency;
  final bool hasFreeTrial;
  final String? trialDuration;

  Pricing({
    this.hourlyRate,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.currency = 'USD',
    this.hasFreeTrial = false,
    this.trialDuration,
  });

  /// 获取格式化的价格字符串
  String getFormattedPrice(PricingPeriod period) {
    double? rate;
    switch (period) {
      case PricingPeriod.hourly:
        rate = hourlyRate;
      case PricingPeriod.daily:
        rate = dailyRate;
      case PricingPeriod.weekly:
        rate = weeklyRate;
      case PricingPeriod.monthly:
        rate = monthlyRate;
    }

    if (rate == null) return 'N/A';
    return '$currency ${rate.toStringAsFixed(2)}/${period.abbreviation}';
  }
}

enum PricingPeriod {
  hourly,
  daily,
  weekly,
  monthly;

  String get abbreviation {
    switch (this) {
      case PricingPeriod.hourly:
        return 'hr';
      case PricingPeriod.daily:
        return 'day';
      case PricingPeriod.weekly:
        return 'wk';
      case PricingPeriod.monthly:
        return 'mo';
    }
  }
}

/// Amenities 值对象
class Amenities {
  final bool hasWifi;
  final bool hasCoffee;
  final bool hasPrinter;
  final bool hasMeetingRoom;
  final bool hasPhoneBooth;
  final bool hasKitchen;
  final bool hasParking;
  final bool hasLocker;
  final bool has24HourAccess;
  final bool hasAirConditioning;
  final bool hasStandingDesk;
  final bool hasShower;
  final bool hasBike;
  final bool hasEventSpace;
  final bool hasPetFriendly;
  final List<String> additionalAmenities;

  Amenities({
    this.hasWifi = false,
    this.hasCoffee = false,
    this.hasPrinter = false,
    this.hasMeetingRoom = false,
    this.hasPhoneBooth = false,
    this.hasKitchen = false,
    this.hasParking = false,
    this.hasLocker = false,
    this.has24HourAccess = false,
    this.hasAirConditioning = false,
    this.hasStandingDesk = false,
    this.hasShower = false,
    this.hasBike = false,
    this.hasEventSpace = false,
    this.hasPetFriendly = false,
    this.additionalAmenities = const [],
  });

  /// 获取所有可用的设施列表
  List<String> getAvailableAmenities() {
    List<String> amenities = [];
    if (hasWifi) amenities.add('WiFi');
    if (hasCoffee) amenities.add('Free Coffee');
    if (hasPrinter) amenities.add('Printer');
    if (hasMeetingRoom) amenities.add('Meeting Rooms');
    if (hasPhoneBooth) amenities.add('Phone Booth');
    if (hasKitchen) amenities.add('Kitchen');
    if (hasParking) amenities.add('Parking');
    if (hasLocker) amenities.add('Locker');
    if (has24HourAccess) amenities.add('24/7 Access');
    if (hasAirConditioning) amenities.add('A/C');
    if (hasStandingDesk) amenities.add('Standing Desk');
    if (hasShower) amenities.add('Shower');
    if (hasBike) amenities.add('Bike Storage');
    if (hasEventSpace) amenities.add('Event Space');
    if (hasPetFriendly) amenities.add('Pet Friendly');
    amenities.addAll(additionalAmenities);
    return amenities;
  }
}

/// Specifications 值对象
class Specifications {
  final double? wifiSpeed; // Mbps
  final int? numberOfDesks;
  final int? numberOfMeetingRooms;
  final int? capacity;
  final NoiseLevel? noiseLevel;
  final bool hasNaturalLight;
  final SpaceType? spaceType;

  Specifications({
    this.wifiSpeed,
    this.numberOfDesks,
    this.numberOfMeetingRooms,
    this.capacity,
    this.noiseLevel,
    this.hasNaturalLight = false,
    this.spaceType,
  });

  bool get isQuiet => noiseLevel == NoiseLevel.quiet;
  bool get isPrivate => spaceType == SpaceType.private;
  bool get hasGoodCapacity => capacity != null && capacity! >= 50;
}

enum NoiseLevel {
  quiet,
  moderate,
  loud;

  static NoiseLevel? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'quiet':
        return NoiseLevel.quiet;
      case 'moderate':
        return NoiseLevel.moderate;
      case 'loud':
        return NoiseLevel.loud;
      default:
        return null;
    }
  }

  @override
  String toString() => name;
}

enum SpaceType {
  open,
  private,
  mixed;

  static SpaceType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'open':
        return SpaceType.open;
      case 'private':
        return SpaceType.private;
      case 'mixed':
        return SpaceType.mixed;
      default:
        return null;
    }
  }

  @override
  String toString() => name;
}

/// OperationHours 值对象
class OperationHours {
  final List<String> hours;

  OperationHours({this.hours = const []});

  bool get is24Hour => hours.any((h) => h.toLowerCase().contains('24'));
  bool get hasHours => hours.isNotEmpty;
}

/// CoworkingReview 实体
class CoworkingReview {
  final String id;
  final String coworkingSpaceId;
  final ReviewAuthor author;
  final double rating;
  final String comment;
  final List<String> pros;
  final List<String> cons;
  final DateTime createdAt;
  final int helpfulCount;

  CoworkingReview({
    required this.id,
    required this.coworkingSpaceId,
    required this.author,
    required this.rating,
    required this.comment,
    this.pros = const [],
    this.cons = const [],
    required this.createdAt,
    this.helpfulCount = 0,
  });

  bool get isPositive => rating >= 4.0;
  bool get isNegative => rating < 3.0;
  bool get isHelpful => helpfulCount >= 5;
}

/// ReviewAuthor 值对象
class ReviewAuthor {
  final String userId;
  final String userName;
  final String userAvatar;

  ReviewAuthor({
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });
}
