/// Coworking Space Model
/// 共享办公空间数据模型
class CoworkingSpace {
  final String id;
  final String name;
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
  final CoworkingPricing pricing;
  final CoworkingAmenities amenities;
  final CoworkingSpecs specs;
  final List<String> openingHours;
  final String phone;
  final String email;
  final String website;
  final bool isVerified;
  final DateTime? lastUpdated;

  CoworkingSpace({
    required this.id,
    required this.name,
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
  });

  factory CoworkingSpace.fromJson(Map<String, dynamic> json) {
    return CoworkingSpace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      pricing: CoworkingPricing.fromJson(json['pricing'] ?? {}),
      amenities: CoworkingAmenities.fromJson(json['amenities'] ?? {}),
      specs: CoworkingSpecs.fromJson(json['specs'] ?? {}),
      openingHours: List<String>.from(json['openingHours'] ?? []),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      isVerified: json['isVerified'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'pricing': pricing.toJson(),
      'amenities': amenities.toJson(),
      'specs': specs.toJson(),
      'openingHours': openingHours,
      'phone': phone,
      'email': email,
      'website': website,
      'isVerified': isVerified,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}

/// Coworking Pricing Information
/// 价格信息
class CoworkingPricing {
  final double? hourlyRate;
  final double? dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final String currency;
  final bool hasFreeTrial;
  final String? trialDuration;

  CoworkingPricing({
    this.hourlyRate,
    this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.currency = 'USD',
    this.hasFreeTrial = false,
    this.trialDuration,
  });

  factory CoworkingPricing.fromJson(Map<String, dynamic> json) {
    return CoworkingPricing(
      hourlyRate: json['hourlyRate']?.toDouble(),
      dailyRate: json['dailyRate']?.toDouble(),
      weeklyRate: json['weeklyRate']?.toDouble(),
      monthlyRate: json['monthlyRate']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      hasFreeTrial: json['hasFreeTrial'] ?? false,
      trialDuration: json['trialDuration'],
    );
  }

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
}

/// Coworking Amenities
/// 设施信息
class CoworkingAmenities {
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

  CoworkingAmenities({
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

  factory CoworkingAmenities.fromJson(Map<String, dynamic> json) {
    return CoworkingAmenities(
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
      additionalAmenities:
          List<String>.from(json['additionalAmenities'] ?? []),
    );
  }

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

/// Coworking Specs
/// 技术规格
class CoworkingSpecs {
  final double? wifiSpeed; // Mbps
  final int? numberOfDesks;
  final int? numberOfMeetingRooms;
  final int? capacity;
  final String? noiseLevel; // quiet, moderate, loud
  final bool hasNaturalLight;
  final String? spaceType; // open, private, mixed

  CoworkingSpecs({
    this.wifiSpeed,
    this.numberOfDesks,
    this.numberOfMeetingRooms,
    this.capacity,
    this.noiseLevel,
    this.hasNaturalLight = false,
    this.spaceType,
  });

  factory CoworkingSpecs.fromJson(Map<String, dynamic> json) {
    return CoworkingSpecs(
      wifiSpeed: json['wifiSpeed']?.toDouble(),
      numberOfDesks: json['numberOfDesks'],
      numberOfMeetingRooms: json['numberOfMeetingRooms'],
      capacity: json['capacity'],
      noiseLevel: json['noiseLevel'],
      hasNaturalLight: json['hasNaturalLight'] ?? false,
      spaceType: json['spaceType'],
    );
  }

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
}

/// Coworking Review Model
/// 评论模型
class CoworkingReview {
  final String id;
  final String coworkingSpaceId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final List<String> pros;
  final List<String> cons;
  final DateTime createdAt;
  final int helpfulCount;

  CoworkingReview({
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

  factory CoworkingReview.fromJson(Map<String, dynamic> json) {
    return CoworkingReview(
      id: json['id'] ?? '',
      coworkingSpaceId: json['coworkingSpaceId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }

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
      'createdAt': createdAt.toIso8601String(),
      'helpfulCount': helpfulCount,
    };
  }
}
