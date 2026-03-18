import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart' as domain;

/// Hotel DTO - 匹配后端 AccommodationService API 返回格式
class HotelDto {
  final String id;
  final String source;
  final String externalStatus;
  final String name;
  final String? description;
  final String address;
  final String? cityId;
  final String? cityName;
  final String? country;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String category;
  final int? starRating;
  final double pricePerNight;
  final String currency;
  final bool isFeatured;

  // 联系方式
  final String? phone;
  final String? email;
  final String? website;

  // 数字游民特性
  final int? wifiSpeed;
  final bool hasWifi;
  final bool hasWorkDesk;
  final bool hasCoworkingSpace;
  final bool hasAirConditioning;
  final bool hasKitchen;
  final bool hasLaundry;
  final bool hasParking;
  final bool hasPool;
  final bool hasGym;
  final bool has24HReception;
  final bool hasLongStayDiscount;
  final double? longStayDiscountPercent;
  final bool isPetFriendly;

  // 计算字段
  final int nomadScore;

  // 房型列表
  final List<RoomTypeDto> roomTypes;

  final DateTime createdAt;
  final String? createdBy;

  HotelDto({
    required this.id,
    this.source = 'community',
    this.externalStatus = 'internal',
    required this.name,
    this.description,
    required this.address,
    this.cityId,
    this.cityName,
    this.country,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.category,
    this.starRating,
    required this.pricePerNight,
    required this.currency,
    this.isFeatured = false,
    this.phone,
    this.email,
    this.website,
    this.wifiSpeed,
    this.hasWifi = false,
    this.hasWorkDesk = false,
    this.hasCoworkingSpace = false,
    this.hasAirConditioning = false,
    this.hasKitchen = false,
    this.hasLaundry = false,
    this.hasParking = false,
    this.hasPool = false,
    this.hasGym = false,
    this.has24HReception = false,
    this.hasLongStayDiscount = false,
    this.longStayDiscountPercent,
    this.isPetFriendly = false,
    this.nomadScore = 0,
    this.roomTypes = const [],
    required this.createdAt,
    this.createdBy,
  });

  factory HotelDto.fromMap(Map<String, dynamic> map) {
    // 解析 images - 可能是数组或逗号分隔的字符串
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is List) {
        return imagesData.map((e) => e.toString()).toList();
      }
      if (imagesData is String) {
        return imagesData.isNotEmpty ? imagesData.split(',') : [];
      }
      return [];
    }

    return HotelDto(
      id: map['id']?.toString() ?? '',
      source: map['source'] as String? ?? 'community',
      externalStatus: map['externalStatus'] as String? ??
          ((map['source'] as String? ?? 'community') == 'booking' ? 'live' : 'internal'),
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      address: map['address'] as String? ?? '',
      cityId: map['cityId']?.toString(),
      cityName: map['cityName'] as String?,
      country: map['country'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      images: parseImages(map['images']),
      category: map['category'] as String? ?? 'mid-range',
      starRating: map['starRating'] as int?,
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      isFeatured: map['isFeatured'] as bool? ?? false,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      wifiSpeed: map['wifiSpeed'] as int?,
      hasWifi: map['hasWifi'] as bool? ?? false,
      hasWorkDesk: map['hasWorkDesk'] as bool? ?? false,
      hasCoworkingSpace: map['hasCoworkingSpace'] as bool? ?? false,
      hasAirConditioning: map['hasAirConditioning'] as bool? ?? false,
      hasKitchen: map['hasKitchen'] as bool? ?? false,
      hasLaundry: map['hasLaundry'] as bool? ?? false,
      hasParking: map['hasParking'] as bool? ?? false,
      hasPool: map['hasPool'] as bool? ?? false,
      hasGym: map['hasGym'] as bool? ?? false,
      has24HReception: map['has24HReception'] as bool? ?? false,
      hasLongStayDiscount: map['hasLongStayDiscount'] as bool? ?? false,
      longStayDiscountPercent: (map['longStayDiscountPercent'] as num?)?.toDouble(),
      isPetFriendly: map['isPetFriendly'] as bool? ?? false,
      nomadScore: map['nomadScore'] as int? ?? 0,
      roomTypes: _parseRoomTypes(map['roomTypes']),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy']?.toString(),
    );
  }

  /// 解析房型列表
  static List<RoomTypeDto> _parseRoomTypes(dynamic roomTypesData) {
    if (roomTypesData == null) return [];
    if (roomTypesData is! List) return [];
    return roomTypesData.map((e) => RoomTypeDto.fromApiMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'cityId': cityId,
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerNight': pricePerNight,
      'currency': currency,
      'phone': phone,
      'email': email,
      'website': website,
      'wifiSpeed': wifiSpeed,
      'hasWifi': hasWifi,
      'hasWorkDesk': hasWorkDesk,
      'hasCoworkingSpace': hasCoworkingSpace,
      'hasAirConditioning': hasAirConditioning,
      'hasKitchen': hasKitchen,
      'hasLaundry': hasLaundry,
      'hasParking': hasParking,
      'hasPool': hasPool,
      'hasGym': hasGym,
      'has24HReception': has24HReception,
      'hasLongStayDiscount': hasLongStayDiscount,
      'longStayDiscountPercent': longStayDiscountPercent,
      'isPetFriendly': isPetFriendly,
      'images': images,
    };
  }

  domain.Hotel toDomain() {
    return domain.Hotel(
      id: id,
      source: source,
      externalStatus: externalStatus,
      name: name,
      cityId: cityId ?? '',
      cityName: cityName ?? '',
      country: country,
      address: address,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      reviewCount: reviewCount,
      description: description ?? '',
      amenities: _buildAmenities(),
      images: images,
      category: category,
      starRating: starRating,
      pricePerNight: pricePerNight,
      currency: currency,
      isFeatured: isFeatured,
      roomTypes: roomTypes.map((rt) => rt.toDomain()).toList(),
      createdAt: createdAt,
      createdBy: createdBy,
      phone: phone,
      email: email,
      website: website,
      wifiSpeed: wifiSpeed,
      hasWifi: hasWifi,
      hasWorkDesk: hasWorkDesk,
      hasCoworkingSpace: hasCoworkingSpace,
      hasAirConditioning: hasAirConditioning,
      hasKitchen: hasKitchen,
      hasLaundry: hasLaundry,
      hasParking: hasParking,
      hasPool: hasPool,
      hasGym: hasGym,
      has24HReception: has24HReception,
      hasLongStayDiscount: hasLongStayDiscount,
      longStayDiscountPercent: longStayDiscountPercent,
      isPetFriendly: isPetFriendly,
      nomadScore: nomadScore,
    );
  }

  /// 根据特性字段构建 amenities 列表
  List<String> _buildAmenities() {
    final amenities = <String>[];
    if (hasWifi) amenities.add('WiFi');
    if (hasWorkDesk) amenities.add('Work Desk');
    if (hasCoworkingSpace) amenities.add('Coworking Space');
    if (hasAirConditioning) amenities.add('Air Conditioning');
    if (hasKitchen) amenities.add('Kitchen');
    if (hasLaundry) amenities.add('Laundry');
    if (hasParking) amenities.add('Parking');
    if (hasPool) amenities.add('Pool');
    if (hasGym) amenities.add('Gym');
    if (has24HReception) amenities.add('24H Reception');
    if (hasLongStayDiscount) amenities.add('Long Stay Discount');
    if (isPetFriendly) amenities.add('Pet Friendly');
    return amenities;
  }
}

/// RoomType DTO
class RoomTypeDto {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final int maxOccupancy;
  final double size;
  final String bedType;
  final double pricePerNight;
  final String currency;
  final int availableRooms;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final DateTime createdAt;

  RoomTypeDto({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.maxOccupancy,
    required this.size,
    required this.bedType,
    required this.pricePerNight,
    required this.currency,
    required this.availableRooms,
    required this.amenities,
    required this.images,
    this.isAvailable = true,
    required this.createdAt,
  });

  /// 从本地数据库格式解析 (snake_case)
  factory RoomTypeDto.fromMap(Map<String, dynamic> map) {
    return RoomTypeDto(
      id: map['id'].toString(),
      hotelId: map['hotel_id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      maxOccupancy: map['max_occupancy'] as int? ?? 2,
      size: (map['size'] as num?)?.toDouble() ?? 25.0,
      bedType: map['bed_type'] as String? ?? 'Queen',
      pricePerNight: (map['price_per_night'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      availableRooms: map['available_rooms'] as int? ?? 0,
      amenities: (map['amenities'] as String?)?.split(',') ?? [],
      images: (map['images'] as String?)?.split(',') ?? [],
      isAvailable: (map['is_available'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 从 API 返回格式解析 (camelCase)
  factory RoomTypeDto.fromApiMap(Map<String, dynamic> map) {
    // 解析 amenities - 可能是数组或逗号分隔字符串
    List<String> parseAmenities(dynamic data) {
      if (data == null) return [];
      if (data is List) return data.map((e) => e.toString()).toList();
      if (data is String) return data.isNotEmpty ? data.split(',') : [];
      return [];
    }

    // 解析 images - 可能是数组或逗号分隔字符串
    List<String> parseImages(dynamic data) {
      if (data == null) return [];
      if (data is List) return data.map((e) => e.toString()).toList();
      if (data is String) return data.isNotEmpty ? data.split(',') : [];
      return [];
    }

    return RoomTypeDto(
      id: map['id']?.toString() ?? '',
      hotelId: map['hotelId']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      maxOccupancy: map['maxOccupancy'] as int? ?? 2,
      size: (map['size'] as num?)?.toDouble() ?? 25.0,
      bedType: map['bedType'] as String? ?? 'Queen',
      pricePerNight: (map['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      availableRooms: map['availableRooms'] as int? ?? 0,
      amenities: parseAmenities(map['amenities']),
      images: parseImages(map['images']),
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'description': description,
      'max_occupancy': maxOccupancy,
      'size': size,
      'bed_type': bedType,
      'price_per_night': pricePerNight,
      'currency': currency,
      'available_rooms': availableRooms,
      'amenities': amenities.join(','),
      'images': images.join(','),
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  domain.RoomType toDomain() {
    return domain.RoomType(
      id: id,
      hotelId: hotelId,
      name: name,
      description: description,
      maxOccupancy: maxOccupancy,
      size: size,
      bedType: bedType,
      pricePerNight: pricePerNight,
      currency: currency,
      availableRooms: availableRooms,
      amenities: amenities,
      images: images,
      isAvailable: isAvailable,
      createdAt: createdAt,
    );
  }
}

/// HotelBooking DTO
class HotelBookingDto {
  final String id;
  final String hotelId;
  final String hotelName;
  final String roomTypeId;
  final String roomTypeName;
  final String userId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfRooms;
  final int numberOfGuests;
  final double totalPrice;
  final String currency;
  final String status;
  final String? specialRequests;
  final DateTime createdAt;

  HotelBookingDto({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfRooms,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.currency,
    required this.status,
    this.specialRequests,
    required this.createdAt,
  });

  factory HotelBookingDto.fromMap(Map<String, dynamic> map) {
    return HotelBookingDto(
      id: map['id'].toString(),
      hotelId: map['hotel_id'].toString(),
      hotelName: map['hotel_name'] as String? ?? '',
      roomTypeId: map['room_type_id'].toString(),
      roomTypeName: map['room_type_name'] as String? ?? '',
      userId: map['user_id'].toString(),
      checkInDate: DateTime.parse(map['check_in_date'] as String),
      checkOutDate: DateTime.parse(map['check_out_date'] as String),
      numberOfRooms: map['number_of_rooms'] as int? ?? 1,
      numberOfGuests: map['number_of_guests'] as int? ?? 1,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      status: map['status'] as String? ?? 'pending',
      specialRequests: map['special_requests'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'room_type_id': roomTypeId,
      'user_id': userId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'number_of_rooms': numberOfRooms,
      'number_of_guests': numberOfGuests,
      'total_price': totalPrice,
      'currency': currency,
      'status': status,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
    };
  }

  domain.HotelBooking toDomain() {
    return domain.HotelBooking(
      id: id,
      hotelId: hotelId,
      hotelName: hotelName,
      roomTypeId: roomTypeId,
      roomTypeName: roomTypeName,
      userId: userId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfRooms: numberOfRooms,
      numberOfGuests: numberOfGuests,
      totalPrice: totalPrice,
      currency: currency,
      status: status,
      specialRequests: specialRequests,
      createdAt: createdAt,
    );
  }
}
