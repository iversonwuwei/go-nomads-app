/// Hotel Domain Entity - 酒店
class Hotel {
  final String id;
  final String name;
  final String cityId;
  final String cityName;
  final String? country;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final String category;
  final int? starRating;
  final double pricePerNight;
  final String currency;
  final bool isFeatured;
  final List<RoomType> roomTypes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // 创建者信息
  final String? createdBy;

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

  Hotel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
    this.country,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
    required this.images,
    required this.category,
    this.starRating,
    required this.pricePerNight,
    required this.currency,
    required this.isFeatured,
    required this.roomTypes,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
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
  });

  // Business logic methods
  bool get isHighlyRated => rating >= 4.0;

  bool get isPopular => reviewCount > 100;

  bool get hasRooms => roomTypes.isNotEmpty;

  bool get isLuxury => category.toLowerCase() == 'luxury';
  bool get isBudget => category.toLowerCase() == 'budget';
  bool get isHostel => category.toLowerCase() == 'hostel';

  /// 是否适合数字游民
  bool get isNomadFriendly => hasWifi && (hasWorkDesk || hasCoworkingSpace);

  /// 是否有良好的 WiFi（>= 50 Mbps）
  bool get hasGoodWifi => hasWifi && (wifiSpeed ?? 0) >= 50;

  int get availableRoomCount => roomTypes.where((r) => r.isAvailable).length;

  bool hasAmenity(String amenity) => amenities.any((a) => a.toLowerCase() == amenity.toLowerCase());

  RoomType? get cheapestRoom {
    if (roomTypes.isEmpty) return null;
    return roomTypes.reduce((a, b) => a.pricePerNight < b.pricePerNight ? a : b);
  }

  double get lowestPrice => cheapestRoom?.pricePerNight ?? pricePerNight;
}

/// RoomType Value Object - 房型
class RoomType {
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

  RoomType({
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
    required this.isAvailable,
    required this.createdAt,
  });

  // Business logic methods
  bool get hasAvailableRooms => availableRooms > 0 && isAvailable;

  bool get isLargeRoom => size >= 35.0;

  bool canAccommodate(int guests) => guests <= maxOccupancy;

  bool hasAmenity(String amenity) => amenities.any((a) => a.toLowerCase() == amenity.toLowerCase());
}

/// HotelBooking Domain Entity - 酒店预订
class HotelBooking {
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

  HotelBooking({
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

  // Business logic methods
  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isUpcoming {
    final now = DateTime.now();
    return checkInDate.isAfter(now) && !isCancelled;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(checkInDate) && now.isBefore(checkOutDate) && isConfirmed;
  }

  bool get isPast {
    final now = DateTime.now();
    return checkOutDate.isBefore(now);
  }

  double get pricePerNight => totalPrice / numberOfNights;

  bool get hasSpecialRequests => specialRequests != null && specialRequests!.isNotEmpty;
}
