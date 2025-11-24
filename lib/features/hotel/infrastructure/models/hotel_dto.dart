import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart'
    as domain;

/// Hotel DTO
class HotelDto {
  final String id;
  final String name;
  final String cityId;
  final String cityName;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final String category;
  final double pricePerNight;
  final String currency;
  final bool isFeatured;
  final List<RoomTypeDto> roomTypes;
  final DateTime createdAt;
  final DateTime updatedAt;

  HotelDto({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
    required this.images,
    required this.category,
    required this.pricePerNight,
    required this.currency,
    this.isFeatured = false,
    required this.roomTypes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HotelDto.fromMap(Map<String, dynamic> map) {
    return HotelDto(
      id: map['id'].toString(),
      name: map['name'] as String,
      cityId: map['city_id'].toString(),
      cityName: map['city_name'] as String? ?? '',
      address: map['address'] as String,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] as int? ?? 0,
      description: map['description'] as String? ?? '',
      amenities: (map['amenities'] as String?)?.split(',') ?? [],
      images: (map['images'] as String?)?.split(',') ?? [],
      category: map['category'] as String? ?? 'mid-range',
      pricePerNight: (map['price_per_night'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      isFeatured: (map['is_featured'] as int?) == 1,
      roomTypes: [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'review_count': reviewCount,
      'description': description,
      'amenities': amenities.join(','),
      'images': images.join(','),
      'category': category,
      'price_per_night': pricePerNight,
      'currency': currency,
      'is_featured': isFeatured ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  domain.Hotel toDomain() {
    return domain.Hotel(
      id: id,
      name: name,
      cityId: cityId,
      cityName: cityName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      rating: rating,
      reviewCount: reviewCount,
      description: description,
      amenities: amenities,
      images: images,
      category: category,
      pricePerNight: pricePerNight,
      currency: currency,
      isFeatured: isFeatured,
      roomTypes: roomTypes.map((r) => r.toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
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
