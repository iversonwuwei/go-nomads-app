// import '../../../../models/coworking_space_model.dart' as legacy;
import '../../domain/entities/coworking_space.dart' as entity;

// Type aliases for backward compatibility
typedef CoworkingSpace = CoworkingSpaceDto;
typedef CoworkingPricing = CoworkingPricingDto;
typedef CoworkingAmenities = CoworkingAmenitiesDto;
typedef CoworkingSpecs = CoworkingSpecsDto;
typedef CoworkingReview = CoworkingReviewDto;

/// CoworkingSpace DTO - 基础设施层数据传输对象
class CoworkingSpaceDto {
  final String id;
  final String name;
  final String? cityId; // 添加 cityId 字段
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String description;
  final CoworkingPricingDto pricing;
  final CoworkingAmenitiesDto amenities;
  final CoworkingSpecsDto specs;
  final List<String> openingHours;
  final String phone;
  final String email;
  final String website;
  final bool isVerified;
  final String? lastUpdated;
  final String? createdBy;
  final String? creatorName;
  final int verificationVotes;
  final bool isOwner;

  CoworkingSpaceDto({
    required this.id,
    required this.name,
    this.cityId, // 添加到构造函数
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.description,
    required this.pricing,
    required this.amenities,
    required this.specs,
    this.openingHours = const [],
    this.phone = '',
    this.email = '',
    this.website = '',
    this.isVerified = false,
    this.lastUpdated,
    this.createdBy,
    this.creatorName,
    this.verificationVotes = 0,
    this.isOwner = false,
  });

  Map<String, dynamic> toJson() {
    // 获取可用的设施列表
    final availableAmenities = amenities.getAvailableAmenities();

    return {
      'id': id,
      'name': name,
      'cityId': cityId, // 使用传入的 cityId
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'images': images,
      'description': description,
      // 扁平化 pricing 字段
      'pricePerHour': pricing.hourlyRate,
      'pricePerDay': pricing.dailyRate,
      'pricePerMonth': pricing.monthlyRate,
      'currency': pricing.currency,
      // 扁平化 amenities 字段 - 后端期望 string[]
      'amenities': availableAmenities,
      'hasMeetingRoom': amenities.hasMeetingRoom,
      'hasCoffee': amenities.hasCoffee,
      'hasParking': amenities.hasParking,
      'has247Access': amenities.has24HourAccess,
      // 扁平化 specs 字段
      'wifiSpeed': specs.wifiSpeed,
      'capacity': specs.capacity,
      // openingHours
      'openingHours': openingHours.isNotEmpty ? openingHours.join('; ') : null,
      // contact info - 空字符串转为 null 避免后端验证失败
      'phone': phone.isNotEmpty ? phone : null,
      'email': email.isNotEmpty ? email : null,
      'website': website.isNotEmpty ? website : null,
      // metadata
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'lastUpdated': lastUpdated,
      'createdBy': createdBy,
      'verificationVotes': verificationVotes,
    };
  }

  factory CoworkingSpaceDto.fromJson(Map<String, dynamic> json) {
    // 适配后端实际返回的扁平化数据结构
    return CoworkingSpaceDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cityId: json['cityId'], // 添加 cityId
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude:
          json['latitude'] != null ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : 0.0,
      imageUrl: json['imageUrl'] ?? '',
      images: json['images'] != null && json['images'] is List
          ? List<String>.from(json['images'])
          : (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty
              ? [json['imageUrl'].toString()]
              : []),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      // 适配后端扁平化的 pricing 字段
      pricing: CoworkingPricingDto.fromJson({
        'hourlyRate': json['pricePerHour'],
        'dailyRate': json['pricePerDay'],
        'monthlyRate': json['pricePerMonth'],
        'currency': json['currency'] ?? 'CNY',
      }),
      // 适配后端扁平化的 amenities 字段
      amenities: CoworkingAmenitiesDto.fromJson({
        'hasWifi': json['amenities']?.contains('wifi') ?? false,
        'hasMeetingRoom': json['hasMeetingRoom'] ??
            json['amenities']?.contains('meeting_room') ??
            false,
        'hasCoffee':
            json['hasCoffee'] ?? json['amenities']?.contains('coffee') ?? false,
        'hasParking': json['hasParking'] ??
            json['amenities']?.contains('parking') ??
            false,
        'has24HourAccess': json['has247Access'] ??
            json['amenities']?.contains('24_hour') ??
            false,
      }),
      // 适配后端扁平化的 specs 字段
      specs: CoworkingSpecsDto.fromJson({
        'capacity': json['capacity'],
        'desks': json['desks'],
        'privateRooms': json['privateRooms'],
        'meetingRooms': json['meetingRooms'],
        'wifiSpeed': json['wifiSpeed'],
      }),
      openingHours: json['openingHours'] != null && json['openingHours'] is List
          ? List<String>.from(json['openingHours'])
          : [],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      isVerified: _parseVerificationStatus(json),
      lastUpdated: json['updatedAt'] ?? json['lastUpdated'],
      createdBy: json['createdBy']?.toString(),
      creatorName: json['creatorName']?.toString(),
      verificationVotes: _parseVerificationVotes(json),
      isOwner: json['isOwner'] == true,
    );
  }

  /// 转换为领域实体
  entity.CoworkingSpace toDomain() {
    return entity.CoworkingSpace(
      id: id,
      name: name,
      location: entity.Location(
        address: address,
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
      ),
      contactInfo: entity.ContactInfo(
        phone: phone,
        email: email,
        website: website,
      ),
      spaceInfo: entity.SpaceInfo(
        imageUrl: imageUrl,
        images: images,
        rating: rating,
        reviewCount: reviewCount,
        description: description,
      ),
      pricing: pricing.toDomain(),
      amenities: amenities.toDomain(),
      specs: specs.toDomain(),
      operationHours: entity.OperationHours(hours: openingHours),
      isVerified: isVerified,
      lastUpdated: lastUpdated != null ? DateTime.tryParse(lastUpdated!) : null,
      createdBy: createdBy,
      creatorName: creatorName,
      verificationVotes: verificationVotes,
      isOwner: isOwner,
    );
  }

  /// 后端返回 verificationStatus 字段时转换为布尔值
  static bool _parseVerificationStatus(Map<String, dynamic> json) {
    final status = (json['verificationStatus'] ?? json['verification_status'])
        ?.toString()
        .toLowerCase();

    if (status == 'verified') return true;

    // 兼容旧数据，仅当明确为 verified 时才返回 true
    if (json.containsKey('isVerified')) {
      final legacyValue = json['isVerified'];
      if (legacyValue is bool) return legacyValue;
      if (legacyValue is String) {
        final normalized = legacyValue.toLowerCase();
        return normalized == 'true' || normalized == '1';
      }
    }

    return false;
  }

  static int _parseVerificationVotes(Map<String, dynamic> json) {
    final dynamic value =
        json['verificationVotes'] ?? json['verification_votes'];
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  // factory CoworkingSpaceDto.fromLegacyModel(legacy.CoworkingSpace model) {
  //   return CoworkingSpaceDto(
  //     id: model.id,
  //     name: model.name,
  //     address: model.address,
  //     city: model.city,
  //     country: model.country,
  //     latitude: model.latitude,
  //     longitude: model.longitude,
  //     imageUrl: model.imageUrl,
  //     images: model.images,
  //     rating: model.rating,
  //     reviewCount: model.reviewCount,
  //     description: model.description,
  //     pricing: CoworkingPricingDto.fromLegacyModel(model.pricing),
  //     amenities: CoworkingAmenitiesDto.fromLegacyModel(model.amenities),
  //     specs: CoworkingSpecsDto.fromLegacyModel(model.specs),
  //     openingHours: model.openingHours,
  //     phone: model.phone,
  //     email: model.email,
  //     website: model.website,
  //     isVerified: model.isVerified,
  //     lastUpdated: model.lastUpdated?.toIso8601String(),
  //   );
  // }
}

/// CoworkingPricing DTO
class CoworkingPricingDto {
  final double? hourlyRate;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final String currency;
  final bool hasFreeTrial;
  final String? trialDuration;

  CoworkingPricingDto({
    this.hourlyRate,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.currency = 'USD',
    this.hasFreeTrial = false,
    this.trialDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'weeklyRate': weeklyRate,
      'monthlyRate': monthlyRate,
      'currency': currency,
      'hasFreeTrial': hasFreeTrial,
      'trialDuration': trialDuration,
    };
  }

  factory CoworkingPricingDto.fromJson(Map<String, dynamic> json) {
    return CoworkingPricingDto(
      hourlyRate: json['hourlyRate']?.toDouble(),
      dailyRate: json['dailyRate']?.toDouble(),
      weeklyRate: json['weeklyRate']?.toDouble(),
      monthlyRate: json['monthlyRate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      hasFreeTrial: json['hasFreeTrial'] ?? false,
      trialDuration: json['trialDuration'],
    );
  }

  entity.Pricing toDomain() {
    return entity.Pricing(
      hourlyRate: hourlyRate,
      dailyRate: dailyRate,
      weeklyRate: weeklyRate,
      monthlyRate: monthlyRate,
      currency: currency,
      hasFreeTrial: hasFreeTrial,
      trialDuration: trialDuration,
    );
  }

  // factory CoworkingPricingDto.fromLegacyModel(legacy.CoworkingPricing model) {
  //   return CoworkingPricingDto(
  //     hourlyRate: model.hourlyRate,
  //     dailyRate: model.dailyRate,
  //     weeklyRate: model.weeklyRate,
  //     monthlyRate: model.monthlyRate,
  //     currency: model.currency,
  //     hasFreeTrial: model.hasFreeTrial,
  //     trialDuration: model.trialDuration,
  //   );
  // }
}

/// CoworkingAmenities DTO
class CoworkingAmenitiesDto {
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

  CoworkingAmenitiesDto({
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

  Map<String, dynamic> toJson() {
    return {
      'hasWifi': hasWifi,
      'hasCoffee': hasCoffee,
      'hasPrinter': hasPrinter,
      'hasMeetingRoom': hasMeetingRoom,
      'hasPhoneBooth': hasPhoneBooth,
      'hasKitchen': hasKitchen,
      'hasParking': hasParking,
      'hasLocker': hasLocker,
      'has24HourAccess': has24HourAccess,
      'hasAirConditioning': hasAirConditioning,
      'hasStandingDesk': hasStandingDesk,
      'hasShower': hasShower,
      'hasBike': hasBike,
      'hasEventSpace': hasEventSpace,
      'hasPetFriendly': hasPetFriendly,
      'additionalAmenities': additionalAmenities,
    };
  }

  factory CoworkingAmenitiesDto.fromJson(Map<String, dynamic> json) {
    return CoworkingAmenitiesDto(
      hasWifi: json['hasWifi'] ?? false,
      hasCoffee: json['hasCoffee'] ?? false,
      hasPrinter: json['hasPrinter'] ?? false,
      hasMeetingRoom: json['hasMeetingRoom'] ?? false,
      hasPhoneBooth: json['hasPhoneBooth'] ?? false,
      hasKitchen: json['hasKitchen'] ?? false,
      hasParking: json['hasParking'] ?? false,
      hasLocker: json['hasLocker'] ?? false,
      has24HourAccess: json['has24HourAccess'] ?? false,
      hasAirConditioning: json['hasAirConditioning'] ?? false,
      hasStandingDesk: json['hasStandingDesk'] ?? false,
      hasShower: json['hasShower'] ?? false,
      hasBike: json['hasBike'] ?? false,
      hasEventSpace: json['hasEventSpace'] ?? false,
      hasPetFriendly: json['hasPetFriendly'] ?? false,
      additionalAmenities: List<String>.from(json['additionalAmenities'] ?? []),
    );
  }

  entity.Amenities toDomain() {
    return entity.Amenities(
      hasWifi: hasWifi,
      hasCoffee: hasCoffee,
      hasPrinter: hasPrinter,
      hasMeetingRoom: hasMeetingRoom,
      hasPhoneBooth: hasPhoneBooth,
      hasKitchen: hasKitchen,
      hasParking: hasParking,
      hasLocker: hasLocker,
      has24HourAccess: has24HourAccess,
      hasAirConditioning: hasAirConditioning,
      hasStandingDesk: hasStandingDesk,
      hasShower: hasShower,
      hasBike: hasBike,
      hasEventSpace: hasEventSpace,
      hasPetFriendly: hasPetFriendly,
      additionalAmenities: additionalAmenities,
    );
  }

  /// 获取可用的设施列表
  List<String> getAvailableAmenities() {
    final List<String> amenities = [];

    if (hasWifi) amenities.add('WiFi');
    if (hasCoffee) amenities.add('Coffee');
    if (hasPrinter) amenities.add('Printer');
    if (hasMeetingRoom) amenities.add('Meeting Room');
    if (hasPhoneBooth) amenities.add('Phone Booth');
    if (hasKitchen) amenities.add('Kitchen');
    if (hasParking) amenities.add('Parking');
    if (hasLocker) amenities.add('Locker');
    if (has24HourAccess) amenities.add('24/7 Access');
    if (hasAirConditioning) amenities.add('Air Conditioning');
    if (hasStandingDesk) amenities.add('Standing Desk');
    if (hasShower) amenities.add('Shower');
    if (hasBike) amenities.add('Bike');
    if (hasEventSpace) amenities.add('Event Space');
    if (hasPetFriendly) amenities.add('Pet Friendly');

    amenities.addAll(additionalAmenities);

    return amenities;
  }

  // factory CoworkingAmenitiesDto.fromLegacyModel(
  //     legacy.CoworkingAmenities model) {
  //   return CoworkingAmenitiesDto(
  //     hasWifi: model.hasWifi,
  //     hasCoffee: model.hasCoffee,
  //     hasPrinter: model.hasPrinter,
  //     hasMeetingRoom: model.hasMeetingRoom,
  //     hasPhoneBooth: model.hasPhoneBooth,
  //     hasKitchen: model.hasKitchen,
  //     hasParking: model.hasParking,
  //     hasLocker: model.hasLocker,
  //     has24HourAccess: model.has24HourAccess,
  //     hasAirConditioning: model.hasAirConditioning,
  //     hasStandingDesk: model.hasStandingDesk,
  //     hasShower: model.hasShower,
  //     hasBike: model.hasBike,
  //     hasEventSpace: model.hasEventSpace,
  //     hasPetFriendly: model.hasPetFriendly,
  //     additionalAmenities: model.additionalAmenities,
  //   );
  // }
}

/// CoworkingSpecs DTO
class CoworkingSpecsDto {
  final double? wifiSpeed;
  final int? numberOfDesks;
  final int? numberOfMeetingRooms;
  final int? capacity;
  final String? noiseLevel;
  final bool hasNaturalLight;
  final String? spaceType;

  CoworkingSpecsDto({
    this.wifiSpeed,
    this.numberOfDesks,
    this.numberOfMeetingRooms,
    this.capacity,
    this.noiseLevel,
    this.hasNaturalLight = false,
    this.spaceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'wifiSpeed': wifiSpeed,
      'numberOfDesks': numberOfDesks,
      'numberOfMeetingRooms': numberOfMeetingRooms,
      'capacity': capacity,
      'noiseLevel': noiseLevel,
      'hasNaturalLight': hasNaturalLight,
      'spaceType': spaceType,
    };
  }

  factory CoworkingSpecsDto.fromJson(Map<String, dynamic> json) {
    return CoworkingSpecsDto(
      wifiSpeed: json['wifiSpeed']?.toDouble(),
      numberOfDesks: json['numberOfDesks'],
      numberOfMeetingRooms: json['numberOfMeetingRooms'],
      capacity: json['capacity'],
      noiseLevel: json['noiseLevel'],
      hasNaturalLight: json['hasNaturalLight'] ?? false,
      spaceType: json['spaceType'],
    );
  }

  entity.Specifications toDomain() {
    return entity.Specifications(
      wifiSpeed: wifiSpeed,
      numberOfDesks: numberOfDesks,
      numberOfMeetingRooms: numberOfMeetingRooms,
      capacity: capacity,
      noiseLevel: entity.NoiseLevel.fromString(noiseLevel),
      hasNaturalLight: hasNaturalLight,
      spaceType: entity.SpaceType.fromString(spaceType),
    );
  }

  // factory CoworkingSpecsDto.fromLegacyModel(legacy.CoworkingSpecs model) {
  //   return CoworkingSpecsDto(
  //     wifiSpeed: model.wifiSpeed,
  //     numberOfDesks: model.numberOfDesks,
  //     numberOfMeetingRooms: model.numberOfMeetingRooms,
  //     capacity: model.capacity,
  //     noiseLevel: model.noiseLevel,
  //     hasNaturalLight: model.hasNaturalLight,
  //     spaceType: model.spaceType,
  //   );
  // }
}

/// CoworkingReview DTO
class CoworkingReviewDto {
  final String id;
  final String coworkingSpaceId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final List<String> pros;
  final List<String> cons;
  final String createdAt;
  final int helpfulCount;

  CoworkingReviewDto({
    required this.id,
    required this.coworkingSpaceId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    this.pros = const [],
    this.cons = const [],
    required this.createdAt,
    this.helpfulCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coworkingSpaceId': coworkingSpaceId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'pros': pros,
      'cons': cons,
      'createdAt': createdAt,
      'helpfulCount': helpfulCount,
    };
  }

  factory CoworkingReviewDto.fromJson(Map<String, dynamic> json) {
    return CoworkingReviewDto(
      id: json['id'] ?? '',
      coworkingSpaceId: json['coworkingSpaceId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      createdAt: json['createdAt'] ?? '',
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }

  entity.CoworkingReview toDomain() {
    return entity.CoworkingReview(
      id: id,
      coworkingSpaceId: coworkingSpaceId,
      author: entity.ReviewAuthor(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      ),
      rating: rating,
      comment: comment,
      pros: pros,
      cons: cons,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      helpfulCount: helpfulCount,
    );
  }

  // factory CoworkingReviewDto.fromLegacyModel(legacy.CoworkingReview model) {
  //   return CoworkingReviewDto(
  //     id: model.id,
  //     coworkingSpaceId: model.coworkingSpaceId,
  //     userId: model.userId,
  //     userName: model.userName,
  //     userAvatar: model.userAvatar,
  //     rating: model.rating,
  //     comment: model.comment,
  //     pros: model.pros,
  //     cons: model.cons,
  //     createdAt: model.createdAt.toIso8601String(),
  //     helpfulCount: model.helpfulCount,
  //   );
  // }
}
