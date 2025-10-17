import 'package:df_admin_mobile/services/database/hotel_dao.dart';
import 'package:df_admin_mobile/services/database_service.dart';

class HotelDataInitializer {
  final HotelDao _hotelDao = HotelDao();
  final DatabaseService _dbService = DatabaseService();

  // 初始化酒店数据
  Future<void> initializeHotelData() async {
    // 检查是否已经有酒店数据
    final hotels = await _hotelDao.getAllHotels();
    if (hotels.isNotEmpty) {
      print('酒店数据已存在，跳过初始化');
      return;
    }

    print('开始初始化酒店示例数据...');

    // 获取所有城市ID (假设城市已经初始化)
    final db = await _dbService.database;
    final cities = await db.query('cities', columns: ['id', 'name']);

    for (var city in cities) {
      final cityId = city['id'] as int;
      final cityName = city['name'] as String;

      // 为每个城市生成5-10个酒店
      await _generateHotelsForCity(cityId, cityName);
    }

    print('酒店示例数据初始化完成');
  }

  // 为指定城市生成酒店
  Future<void> _generateHotelsForCity(int cityId, String cityName) async {
    final hotelCount = 5 + (cityId % 6); // 5-10个酒店

    for (int i = 0; i < hotelCount; i++) {
      final hotelData = _generateHotelData(cityId, cityName, i);
      final hotelId = await _hotelDao.insertHotel(hotelData);

      // 为每个酒店生成2-4个房型
      final roomTypeCount = 2 + (i % 3);
      for (int j = 0; j < roomTypeCount; j++) {
        final roomData = _generateRoomTypeData(hotelId, j);
        await _hotelDao.insertRoomType(roomData);
      }
    }

    print('为城市 $cityName 生成了 $hotelCount 个酒店');
  }

  // 生成酒店数据
  Map<String, dynamic> _generateHotelData(
      int cityId, String cityName, int index) {
    final categories = ['Luxury', 'Mid-range', 'Budget', 'Hostel'];
    final category = categories[index % 4];

    // 根据类别设置不同的价格范围和评分
    final basePrice = _getBasePriceForCategory(category);
    final rating = _getRatingForCategory(category);

    // 酒店名称模板
    final hotelNames = {
      'Luxury': ['Grand', 'Royal', 'Imperial', 'Palace', 'Ritz'],
      'Mid-range': ['Central', 'Plaza', 'Garden', 'City', 'Park'],
      'Budget': ['Express', 'Inn', 'Lodge', 'Stay', 'Comfort'],
      'Hostel': ['Backpacker', 'Youth', 'Nomad', 'Traveler', 'Cozy'],
    };

    final nameTemplates = hotelNames[category]!;
    final hotelName =
        '${nameTemplates[index % nameTemplates.length]} $cityName Hotel ${index + 1}';

    // 生成坐标 (基于cityId生成变化)
    final baseLat = 13.7563 + (cityId * 0.5) + (index * 0.01);
    final baseLong = 100.5018 + (cityId * 0.5) + (index * 0.01);

    // 生成地址
    final address =
        '${100 + index * 10} ${_getStreetName(index)} Street, $cityName';

    // 生成设施列表
    final amenities = _getAmenitiesForCategory(category);

    // 生成图片URL
    final images = _generateHotelImages(category, index);

    // 生成描述
    final description = _generateDescription(category, cityName);

    return {
      'name': hotelName,
      'city_id': cityId,
      'address': address,
      'latitude': baseLat,
      'longitude': baseLong,
      'rating': rating,
      'review_count': 50 + (index * 20),
      'description': description,
      'amenities': amenities.join(','),
      'images': images.join(','),
      'category': category,
      'price_per_night': basePrice,
      'currency': 'USD',
      'is_featured': index == 0 ? 1 : 0, // 第一个酒店设为精选
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // 生成房型数据
  Map<String, dynamic> _generateRoomTypeData(int hotelId, int index) {
    final roomTypes = [
      {
        'name': 'Standard Room',
        'bed_type': 'Double Bed',
        'max_occupancy': 2,
        'size': 25.0,
        'price_multiplier': 1.0,
      },
      {
        'name': 'Deluxe Room',
        'bed_type': 'Queen Bed',
        'max_occupancy': 2,
        'size': 35.0,
        'price_multiplier': 1.5,
      },
      {
        'name': 'Suite',
        'bed_type': 'King Bed',
        'max_occupancy': 4,
        'size': 50.0,
        'price_multiplier': 2.5,
      },
      {
        'name': 'Family Room',
        'bed_type': 'Twin Beds',
        'max_occupancy': 4,
        'size': 40.0,
        'price_multiplier': 2.0,
      },
    ];

    final roomType = roomTypes[index % roomTypes.length];

    // 房间设施
    final amenities = [
      'Air Conditioning',
      'Flat-screen TV',
      'Mini Bar',
      'Safe',
      'Wifi',
      'Bathroom',
      'Hair Dryer',
      'Desk',
    ];

    // 房间图片
    final images = [
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
      'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800',
    ];

    // 基础价格 (从酒店价格衍生)
    final basePrice = 80.0;
    final multiplier = roomType['price_multiplier'] as double;
    final price = (basePrice * multiplier).round();

    return {
      'hotel_id': hotelId,
      'name': roomType['name'],
      'description':
          'Comfortable ${roomType['name']} with ${roomType['bed_type']}',
      'max_occupancy': roomType['max_occupancy'],
      'size': roomType['size'],
      'bed_type': roomType['bed_type'],
      'price_per_night': price,
      'currency': 'USD',
      'available_rooms': 5 + (index * 2), // 5-13间可用房间
      'amenities': amenities.join(','),
      'images': images.join(','),
      'is_available': 1,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // 辅助函数：根据类别获取基础价格
  double _getBasePriceForCategory(String category) {
    switch (category) {
      case 'Luxury':
        return 200.0 + (DateTime.now().millisecondsSinceEpoch % 100);
      case 'Mid-range':
        return 80.0 + (DateTime.now().millisecondsSinceEpoch % 40);
      case 'Budget':
        return 30.0 + (DateTime.now().millisecondsSinceEpoch % 20);
      case 'Hostel':
        return 15.0 + (DateTime.now().millisecondsSinceEpoch % 10);
      default:
        return 50.0;
    }
  }

  // 辅助函数：根据类别获取评分
  double _getRatingForCategory(String category) {
    switch (category) {
      case 'Luxury':
        return 4.5 + (DateTime.now().millisecondsSinceEpoch % 5) / 10;
      case 'Mid-range':
        return 4.0 + (DateTime.now().millisecondsSinceEpoch % 5) / 10;
      case 'Budget':
        return 3.5 + (DateTime.now().millisecondsSinceEpoch % 5) / 10;
      case 'Hostel':
        return 3.8 + (DateTime.now().millisecondsSinceEpoch % 4) / 10;
      default:
        return 4.0;
    }
  }

  // 辅助函数：根据类别获取设施
  List<String> _getAmenitiesForCategory(String category) {
    final baseAmenities = [
      'Free WiFi',
      'Reception',
      'Housekeeping',
    ];

    switch (category) {
      case 'Luxury':
        return [
          ...baseAmenities,
          'Swimming Pool',
          'Spa',
          'Gym',
          'Restaurant',
          'Bar',
          'Concierge',
          'Airport Shuttle',
          'Valet Parking',
          'Business Center',
        ];
      case 'Mid-range':
        return [
          ...baseAmenities,
          'Restaurant',
          'Gym',
          'Free Parking',
          'Breakfast Included',
          'Laundry Service',
        ];
      case 'Budget':
        return [
          ...baseAmenities,
          'Free Parking',
          'Breakfast Available',
          'Luggage Storage',
        ];
      case 'Hostel':
        return [
          ...baseAmenities,
          'Shared Kitchen',
          'Common Room',
          'Luggage Storage',
          'Laundry Facilities',
        ];
      default:
        return baseAmenities;
    }
  }

  // 辅助函数：生成街道名称
  String _getStreetName(int index) {
    final streets = [
      'Main',
      'Central',
      'Beach',
      'River',
      'Mountain',
      'Garden',
      'Park',
      'Ocean',
      'Lake',
      'Forest'
    ];
    return streets[index % streets.length];
  }

  // 辅助函数：生成酒店图片
  List<String> _generateHotelImages(String category, int index) {
    // 使用Unsplash作为示例图片源
    final luxuryImages = [
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    ];

    final midRangeImages = [
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    ];

    final budgetImages = [
      'https://images.unsplash.com/photo-1455587734955-081b22074882?w=800',
      'https://images.unsplash.com/photo-1534612899740-55c821a90129?w=800',
      'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800',
    ];

    final hostelImages = [
      'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800',
      'https://images.unsplash.com/photo-1506059612708-99d6c258160e?w=800',
      'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800',
    ];

    switch (category) {
      case 'Luxury':
        return luxuryImages;
      case 'Mid-range':
        return midRangeImages;
      case 'Budget':
        return budgetImages;
      case 'Hostel':
        return hostelImages;
      default:
        return midRangeImages;
    }
  }

  // 辅助函数：生成描述
  String _generateDescription(String category, String cityName) {
    switch (category) {
      case 'Luxury':
        return 'Experience ultimate luxury in the heart of $cityName. Our 5-star hotel offers world-class amenities, exceptional service, and breathtaking views. Perfect for discerning travelers seeking the finest accommodation.';
      case 'Mid-range':
        return 'Comfortable and convenient accommodation in $cityName. Our hotel offers modern facilities, friendly service, and great value for money. Ideal for both business and leisure travelers.';
      case 'Budget':
        return 'Affordable and clean accommodation in $cityName. Basic amenities with a focus on comfort and convenience. Perfect for budget-conscious travelers who value simplicity and efficiency.';
      case 'Hostel':
        return 'Social and vibrant hostel in $cityName. Meet fellow travelers, share experiences, and explore the city together. Great for backpackers and solo travelers looking for authentic experiences.';
      default:
        return 'Welcome to our hotel in $cityName. We look forward to hosting you.';
    }
  }
}
