import 'package:df_admin_mobile/models/coworking_space_model.dart';
import 'package:df_admin_mobile/services/data/coworking_data_service.dart';
import 'package:get/get.dart';

/// Coworking Controller
/// 管理共享办公空间的控制器
class CoworkingController extends GetxController {
  final CoworkingDataService _coworkingService = CoworkingDataService();

  // 观察变量
  var coworkingSpaces = <CoworkingSpace>[].obs;
  var filteredSpaces = <CoworkingSpace>[].obs;
  var isLoading = false.obs;
  var selectedCity = ''.obs;

  // 筛选条件
  var selectedFilters = <String>[].obs;
  var priceRange = RxList<double>([0, 1000]);
  var minRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCoworkingsFromDatabase();
  }

  /// 从数据库加载共享办公空间数据
  Future<void> loadCoworkingsFromDatabase() async {
    try {
      isLoading.value = true;
      final coworkings = await _coworkingService.getAllCoworkings();

      // 转换数据库数据为 CoworkingSpace 模型
      coworkingSpaces.value = coworkings.map((data) {
        return CoworkingSpace(
          id: data['id'].toString(),
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          city: _getCityNameById(data['city_id']),
          country: 'Thailand', // 默认国家
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['image_url'] ?? '',
          images: [data['image_url'] ?? ''],
          rating: (data['rating'] as num?)?.toDouble() ?? 4.0,
          reviewCount: 0, // 数据库暂无此字段
          description: data['description'] ?? '',
          pricing: CoworkingPricing(
            dailyRate: (data['price_per_day'] as num?)?.toDouble(),
            monthlyRate: (data['price_per_month'] as num?)?.toDouble(),
            currency: 'USD',
            hasFreeTrial: false,
          ),
          amenities: CoworkingAmenities(
            hasWifi: ((data['wifi_speed'] as num?)?.toDouble() ?? 0) > 0,
            hasCoffee: (data['has_coffee'] as int?) == 1,
            hasPrinter: true,
            hasMeetingRoom: (data['has_meeting_room'] as int?) == 1,
            hasAirConditioning: true,
          ),
          specs: CoworkingSpecs(
            wifiSpeed: (data['wifi_speed'] as num?)?.toDouble() ?? 0.0,
            numberOfDesks: 50, // 默认值
            numberOfMeetingRooms:
                (data['has_meeting_room'] as int?) == 1 ? 2 : 0,
            capacity: 50, // 默认值
            noiseLevel: 'moderate',
            hasNaturalLight: true,
            spaceType: 'mixed',
          ),
          openingHours: [
            data['opening_hours'] ?? 'Mon-Fri: 9:00 AM - 6:00 PM',
          ],
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          website: data['website'] ?? '',
          isVerified: true,
          lastUpdated: DateTime.now(),
        );
      }).toList();

      filteredSpaces.value = coworkingSpaces;
    } catch (e) {
      print('Error loading coworkings from database: $e');
      // 如果数据库加载失败,使用模拟数据
      loadMockData();
    } finally {
      isLoading.value = false;
    }
  }

  /// 根据城市ID获取城市名称
  String _getCityNameById(int? cityId) {
    // 映射必须与 database_initializer.dart 中的城市插入顺序一致
    const cityMap = {
      1: 'Bangkok', // 第1个插入的城市
      2: 'Chiang Mai', // 第2个插入的城市
      3: 'Canggu', // 第3个插入的城市
      4: 'Tokyo', // 第4个插入的城市
      5: 'Seoul', // 第5个插入的城市
      6: 'Lisbon', // 第6个插入的城市
      7: 'Mexico City', // 第7个插入的城市
      8: 'Singapore', // 第8个插入的城市
    };
    return cityMap[cityId] ?? 'Unknown';
  }

  /// 加载模拟数据(作为备用)
  void loadMockData() {
    coworkingSpaces.value = [
      CoworkingSpace(
        id: '1',
        name: 'Hubba Coworking',
        address: '20 Ekamai Rd, Khlong Tan Nuea',
        city: 'Bangkok',
        country: 'Thailand',
        latitude: 13.7297,
        longitude: 100.5850,
        imageUrl:
            'https://images.unsplash.com/photo-1497366216548-37526070297c',
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c',
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
          'https://images.unsplash.com/photo-1497215728101-856f4ea42174',
        ],
        rating: 4.8,
        reviewCount: 245,
        description:
            'One of Bangkok\'s most popular coworking spaces with modern facilities, great community, and excellent location.',
        pricing: CoworkingPricing(
          hourlyRate: 5.0,
          dailyRate: 15.0,
          weeklyRate: 75.0,
          monthlyRate: 250.0,
          currency: 'USD',
          hasFreeTrial: true,
          trialDuration: '1 day',
        ),
        amenities: CoworkingAmenities(
          hasWifi: true,
          hasCoffee: true,
          hasPrinter: true,
          hasMeetingRoom: true,
          hasPhoneBooth: true,
          hasKitchen: true,
          hasParking: true,
          hasLocker: true,
          has24HourAccess: true,
          hasAirConditioning: true,
          hasStandingDesk: true,
          additionalAmenities: ['Rooftop Terrace', 'Podcast Studio'],
        ),
        specs: CoworkingSpecs(
          wifiSpeed: 100.0,
          numberOfDesks: 150,
          numberOfMeetingRooms: 8,
          capacity: 200,
          noiseLevel: 'moderate',
          hasNaturalLight: true,
          spaceType: 'mixed',
        ),
        openingHours: [
          'Mon-Fri: 8:00 AM - 10:00 PM',
          'Sat-Sun: 9:00 AM - 8:00 PM',
        ],
        phone: '+66 2 XXX XXXX',
        email: 'hello@hubba.com',
        website: 'https://hubbathailand.com',
        isVerified: true,
        lastUpdated: DateTime.now(),
      ),
      CoworkingSpace(
        id: '2',
        name: 'TCDC (Thailand Creative & Design Center)',
        address: 'Grand Postal Building, Charoenkrung Rd',
        city: 'Bangkok',
        country: 'Thailand',
        latitude: 13.7240,
        longitude: 100.5078,
        imageUrl:
            'https://images.unsplash.com/photo-1524758631624-e2822e304c36',
        images: [
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36',
          'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
        ],
        rating: 4.6,
        reviewCount: 189,
        description:
            'Creative workspace with design library, exhibitions, and inspiring environment for creative professionals.',
        pricing: CoworkingPricing(
          dailyRate: 10.0,
          monthlyRate: 200.0,
          currency: 'USD',
          hasFreeTrial: false,
        ),
        amenities: CoworkingAmenities(
          hasWifi: true,
          hasCoffee: true,
          hasPrinter: true,
          hasMeetingRoom: true,
          hasKitchen: false,
          hasParking: false,
          hasAirConditioning: true,
          additionalAmenities: ['Design Library', 'Exhibition Space'],
        ),
        specs: CoworkingSpecs(
          wifiSpeed: 80.0,
          numberOfDesks: 80,
          numberOfMeetingRooms: 4,
          capacity: 100,
          noiseLevel: 'quiet',
          hasNaturalLight: true,
          spaceType: 'open',
        ),
        openingHours: [
          'Tue-Sun: 10:00 AM - 9:00 PM',
          'Mon: Closed',
        ],
        isVerified: true,
      ),
      CoworkingSpace(
        id: '3',
        name: 'The Hive Thonglor',
        address: '101 True Digital Park, Sukhumvit Rd',
        city: 'Bangkok',
        country: 'Thailand',
        latitude: 13.7278,
        longitude: 100.5859,
        imageUrl: 'https://images.unsplash.com/photo-1556761175-4b46a572b786',
        images: [
          'https://images.unsplash.com/photo-1556761175-4b46a572b786',
          'https://images.unsplash.com/photo-1497366412874-3415097a27e7',
        ],
        rating: 4.7,
        reviewCount: 312,
        description:
            'Modern coworking space in True Digital Park with tech-focused community and excellent amenities.',
        pricing: CoworkingPricing(
          hourlyRate: 6.0,
          dailyRate: 18.0,
          weeklyRate: 85.0,
          monthlyRate: 280.0,
          currency: 'USD',
          hasFreeTrial: true,
          trialDuration: '3 hours',
        ),
        amenities: CoworkingAmenities(
          hasWifi: true,
          hasCoffee: true,
          hasPrinter: true,
          hasMeetingRoom: true,
          hasPhoneBooth: true,
          hasKitchen: true,
          hasParking: true,
          hasLocker: true,
          has24HourAccess: true,
          hasAirConditioning: true,
          hasStandingDesk: true,
          hasShower: true,
          hasEventSpace: true,
        ),
        specs: CoworkingSpecs(
          wifiSpeed: 150.0,
          numberOfDesks: 200,
          numberOfMeetingRooms: 12,
          capacity: 300,
          noiseLevel: 'moderate',
          hasNaturalLight: true,
          spaceType: 'mixed',
        ),
        openingHours: [
          'Mon-Sun: 24/7',
        ],
        phone: '+66 2 XXX XXXX',
        website: 'https://thehive.co.th',
        isVerified: true,
      ),
      CoworkingSpace(
        id: '4',
        name: 'Launchpad',
        address: '46/1 Sukhumvit Soi 26',
        city: 'Bangkok',
        country: 'Thailand',
        latitude: 13.7292,
        longitude: 100.5669,
        imageUrl:
            'https://images.unsplash.com/photo-1497215842964-222b430dc094',
        images: [
          'https://images.unsplash.com/photo-1497215842964-222b430dc094',
        ],
        rating: 4.5,
        reviewCount: 156,
        description:
            'Boutique coworking space with a focus on startups and entrepreneurs.',
        pricing: CoworkingPricing(
          dailyRate: 12.0,
          monthlyRate: 220.0,
          currency: 'USD',
        ),
        amenities: CoworkingAmenities(
          hasWifi: true,
          hasCoffee: true,
          hasPrinter: true,
          hasMeetingRoom: true,
          hasAirConditioning: true,
          additionalAmenities: ['Mentorship Programs', 'Networking Events'],
        ),
        specs: CoworkingSpecs(
          wifiSpeed: 90.0,
          numberOfDesks: 50,
          numberOfMeetingRooms: 3,
          capacity: 60,
          noiseLevel: 'moderate',
          hasNaturalLight: false,
          spaceType: 'open',
        ),
        openingHours: [
          'Mon-Fri: 9:00 AM - 6:00 PM',
        ],
        isVerified: false,
      ),
      CoworkingSpace(
        id: '5',
        name: 'KoHub',
        address: 'Phrom Phong',
        city: 'Bangkok',
        country: 'Thailand',
        latitude: 13.7294,
        longitude: 100.5698,
        imageUrl:
            'https://images.unsplash.com/photo-1497366858526-0766cadbe8fa',
        images: [
          'https://images.unsplash.com/photo-1497366858526-0766cadbe8fa',
        ],
        rating: 4.4,
        reviewCount: 98,
        description:
            'Cozy coworking cafe with a relaxed atmosphere perfect for freelancers.',
        pricing: CoworkingPricing(
          hourlyRate: 3.0,
          dailyRate: 10.0,
          monthlyRate: 150.0,
          currency: 'USD',
        ),
        amenities: CoworkingAmenities(
          hasWifi: true,
          hasCoffee: true,
          hasPrinter: false,
          hasMeetingRoom: false,
          hasAirConditioning: true,
        ),
        specs: CoworkingSpecs(
          wifiSpeed: 60.0,
          numberOfDesks: 30,
          capacity: 40,
          noiseLevel: 'quiet',
          hasNaturalLight: true,
          spaceType: 'open',
        ),
        openingHours: [
          'Mon-Sun: 8:00 AM - 10:00 PM',
        ],
        isVerified: true,
      ),
    ];
    filteredSpaces.value = coworkingSpaces;
  }

  /// 按城市筛选
  void filterByCity(String city) {
    selectedCity.value = city;
    applyFilters();
  }

  /// 应用筛选条件
  void applyFilters() {
    var filtered = coworkingSpaces.where((space) {
      // 城市筛选
      if (selectedCity.value.isNotEmpty && space.city != selectedCity.value) {
        return false;
      }

      // 价格筛选
      if (space.pricing.monthlyRate != null) {
        if (space.pricing.monthlyRate! < priceRange[0] ||
            space.pricing.monthlyRate! > priceRange[1]) {
          return false;
        }
      }

      // 评分筛选
      if (space.rating < minRating.value) {
        return false;
      }

      // 设施筛选
      if (selectedFilters.contains('WiFi') && !space.amenities.hasWifi) {
        return false;
      }
      if (selectedFilters.contains('24/7') &&
          !space.amenities.has24HourAccess) {
        return false;
      }
      if (selectedFilters.contains('Meeting Rooms') &&
          !space.amenities.hasMeetingRoom) {
        return false;
      }
      if (selectedFilters.contains('Coffee') && !space.amenities.hasCoffee) {
        return false;
      }

      return true;
    }).toList();

    filteredSpaces.value = filtered;
  }

  /// 切换筛选条件
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    applyFilters();
  }

  /// 更新价格范围
  void updatePriceRange(double min, double max) {
    priceRange.value = [min, max];
    applyFilters();
  }

  /// 更新最低评分
  void updateMinRating(double rating) {
    minRating.value = rating;
    applyFilters();
  }

  /// 清除所有筛选
  void clearFilters() {
    selectedFilters.clear();
    priceRange.value = [0, 1000];
    minRating.value = 0.0;
    applyFilters();
  }

  /// 按评分排序
  void sortByRating() {
    filteredSpaces.sort((a, b) => b.rating.compareTo(a.rating));
    filteredSpaces.refresh();
  }

  /// 按价格排序
  void sortByPrice() {
    filteredSpaces.sort((a, b) {
      var aPrice = a.pricing.monthlyRate ?? double.infinity;
      var bPrice = b.pricing.monthlyRate ?? double.infinity;
      return aPrice.compareTo(bPrice);
    });
    filteredSpaces.refresh();
  }

  /// 按距离排序（需要用户位置）
  void sortByDistance() {
    // TODO: 实现基于用户位置的距离排序
  }
}
