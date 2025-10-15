import 'dart:math';

import 'database/city_dao.dart';
import 'database/coworking_dao.dart';

/// 中国城市测试数据生成器
/// 生成50个随机城市和对应的共享办公空间
class ChinaCitiesGenerator {
  final CityDao _cityDao = CityDao();
  final CoworkingDao _coworkingDao = CoworkingDao();
  final Random _random = Random();

  // 中国34个省级行政区
  final Map<String, List<String>> provinceCities = {
    '北京市': ['北京'],
    '天津市': ['天津'],
    '上海市': ['上海'],
    '重庆市': ['重庆'],
    '河北省': ['石家庄', '唐山', '保定', '邯郸', '秦皇岛'],
    '山西省': ['太原', '大同', '运城'],
    '辽宁省': ['沈阳', '大连', '鞍山'],
    '吉林省': ['长春', '吉林', '延边'],
    '黑龙江省': ['哈尔滨', '齐齐哈尔', '大庆'],
    '江苏省': ['南京', '苏州', '无锡', '常州', '南通', '扬州'],
    '浙江省': ['杭州', '宁波', '温州', '绍兴', '嘉兴'],
    '安徽省': ['合肥', '芜湖', '马鞍山'],
    '福建省': ['福州', '厦门', '泉州'],
    '江西省': ['南昌', '赣州', '九江'],
    '山东省': ['济南', '青岛', '烟台', '潍坊', '淄博'],
    '河南省': ['郑州', '洛阳', '开封', '新乡'],
    '湖北省': ['武汉', '宜昌', '襄阳'],
    '湖南省': ['长沙', '株洲', '湘潭'],
    '广东省': ['广州', '深圳', '珠海', '佛山', '东莞', '中山'],
    '广西壮族自治区': ['南宁', '桂林', '柳州'],
    '海南省': ['海口', '三亚'],
    '四川省': ['成都', '绵阳', '德阳'],
    '贵州省': ['贵阳', '遵义'],
    '云南省': ['昆明', '大理', '丽江'],
    '西藏自治区': ['拉萨'],
    '陕西省': ['西安', '宝鸡'],
    '甘肃省': ['兰州'],
    '青海省': ['西宁'],
    '宁夏回族自治区': ['银川'],
    '新疆维吾尔自治区': ['乌鲁木齐'],
    '内蒙古自治区': ['呼和浩特', '包头'],
    '香港特别行政区': ['香港'],
    '澳门特别行政区': ['澳门'],
    '台湾省': ['台北', '高雄'],
  };

  // 气候类型
  final List<String> climates = ['Hot', 'Warm', 'Mild', 'Cool', 'Cold'];

  // 城市图片URL模板
  final List<String> imageTemplates = [
    'https://images.unsplash.com/photo-1508804185872-d7badad00f7d',
    'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9',
    'https://images.unsplash.com/photo-1523217582562-09d0def993a6',
    'https://images.unsplash.com/photo-1548919973-5cef591cdbc9',
    'https://images.unsplash.com/photo-1512353087810-25dffd1e5080',
  ];

  // 共享办公空间名称模板
  final List<String> coworkingPrefixes = [
    'WeWork', 'SOHO 3Q', '优客工场', 'Distrii办伴', 'Spaces',
    '裸心社', 'P2', '梦想加', '方糖小镇', 'CreatorBase',
    'Garage Cafe', 'People Squared', 'Bee+', 'Binggo咖啡',
  ];

  final List<String> coworkingSuffixes = [
    '联合办公', '共享空间', 'Coworking', '创客中心', 'Hub',
    '创业社区', 'Innovation Space', '工作坊', 'Studio', 'Base',
  ];

  /// 生成50个随机城市
  Future<void> generateChineseCities() async {
    print('🏙️ 开始生成中国城市数据...');

    // 收集所有城市
    List<Map<String, String>> allCities = [];
    provinceCities.forEach((province, cities) {
      for (var city in cities) {
        allCities.add({'province': province, 'city': city});
      }
    });

    // 随机选择50个城市
    allCities.shuffle();
    final selectedCities = allCities.take(50).toList();

    final now = DateTime.now().toIso8601String();
    int insertedCount = 0;

    for (var cityData in selectedCities) {
      final province = cityData['province']!;
      final cityName = cityData['city']!;

      // 生成城市数据
      final city = _generateCityData(cityName, province, now);
      
      try {
        final cityId = await _cityDao.insertCity(city);
        print('✅ 插入城市: $cityName (${province}) - ID: $cityId');
        
        // 为每个城市生成4-5个共享办公空间
        await _generateCoworkingSpaces(cityId, cityName, now);
        
        insertedCount++;
      } catch (e) {
        print('❌ 插入城市失败: $cityName - $e');
      }
    }

    print('✅ 成功插入 $insertedCount 个城市及其共享办公空间');
  }

  /// 生成单个城市数据
  Map<String, dynamic> _generateCityData(
      String cityName, String province, String now) {
    // 根据省份确定区域
    String region = _getRegionByProvince(province);
    
    // 根据省份确定气候
    String climate = _getClimateByProvince(province);

    // 生成随机数据
    double costOfLiving = 800 + _random.nextDouble() * 3200; // 800-4000
    double internetSpeed = 30 + _random.nextDouble() * 170; // 30-200 Mbps
    double safetyScore = 7 + _random.nextDouble() * 3; // 7-10
    double overallScore = 6 + _random.nextDouble() * 4; // 6-10
    double funScore = 5 + _random.nextDouble() * 5; // 5-10
    double qualityOfLife = 6 + _random.nextDouble() * 4; // 6-10
    int aqi = 20 + _random.nextInt(180); // 20-200
    double temperature = 10 + _random.nextDouble() * 25; // 10-35°C
    int humidity = 40 + _random.nextInt(50); // 40-90%

    // 生成经纬度（中国范围：纬度18-54, 经度73-135）
    double latitude = 18 + _random.nextDouble() * 36;
    double longitude = 73 + _random.nextDouble() * 62;

    return {
      'name': cityName,
      'country': 'China',
      'region': region,
      'climate': climate,
      'description': '$cityName是${province}的重要城市，拥有丰富的文化底蕴和现代化设施。',
      'image_url': imageTemplates[_random.nextInt(imageTemplates.length)] +
          '?w=800&h=600&fit=crop&city=$cityName',
      'weather': _getWeatherByClimate(climate),
      'temperature': temperature,
      'cost_of_living': costOfLiving,
      'internet_speed': internetSpeed,
      'safety_score': safetyScore,
      'overall_score': overallScore,
      'fun_score': funScore,
      'quality_of_life': qualityOfLife,
      'aqi': aqi,
      'population': _getPopulationRange(),
      'timezone': 'Asia/Shanghai',
      'humidity': humidity,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': now,
      'updated_at': now,
    };
  }

  /// 为城市生成4-5个共享办公空间
  Future<void> _generateCoworkingSpaces(
      int cityId, String cityName, String now) async {
    final count = 4 + _random.nextInt(2); // 4-5个
    
    for (int i = 0; i < count; i++) {
      final coworking = _generateCoworkingData(cityId, cityName, now);
      
      try {
        final id = await _coworkingDao.insertCoworking(coworking);
        print('  ➕ 添加共享办公空间: ${coworking['name']} - ID: $id');
      } catch (e) {
        print('  ❌ 添加共享办公空间失败: ${coworking['name']} - $e');
      }
    }
  }

  /// 生成单个共享办公空间数据
  Map<String, dynamic> _generateCoworkingData(
      int cityId, String cityName, String now) {
    // 生成名称
    final prefix = coworkingPrefixes[_random.nextInt(coworkingPrefixes.length)];
    final suffix = coworkingSuffixes[_random.nextInt(coworkingSuffixes.length)];
    final name = '$prefix $cityName$suffix';

    // 生成价格
    double pricePerDay = 50 + _random.nextDouble() * 150; // 50-200元/天
    double pricePerMonth = 800 + _random.nextDouble() * 2200; // 800-3000元/月

    // 生成评分
    double rating = 3.5 + _random.nextDouble() * 1.5; // 3.5-5.0

    // 生成WiFi速度
    double wifiSpeed = 50 + _random.nextDouble() * 150; // 50-200 Mbps

    // 随机设施
    bool hasMeetingRoom = _random.nextBool();
    bool hasCoffee = _random.nextDouble() > 0.3; // 70%概率有咖啡

    // 生成地址
    final districts = ['中心区', '高新区', '商务区', '科技园区', 'CBD'];
    final district = districts[_random.nextInt(districts.length)];
    final address = '$cityName${district}创业大厦${_random.nextInt(50) + 1}号楼';

    // 生成经纬度（在城市附近）
    double latitude = 18 + _random.nextDouble() * 36;
    double longitude = 73 + _random.nextDouble() * 62;

    // 生成营业时间
    final openingHours = '周一至周五 8:00-22:00, 周末 9:00-20:00';

    return {
      'name': name,
      'city_id': cityId,
      'address': address,
      'description':
          '现代化的联合办公空间，提供舒适的工作环境、高速网络和完善的配套设施。${hasMeetingRoom ? "配备会议室。" : ""}${hasCoffee ? "提供免费咖啡。" : ""}',
      'image_url':
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&h=600&fit=crop&space=${_random.nextInt(100)}',
      'price_per_day': pricePerDay,
      'price_per_month': pricePerMonth,
      'rating': rating,
      'wifi_speed': wifiSpeed,
      'has_meeting_room': hasMeetingRoom ? 1 : 0,
      'has_coffee': hasCoffee ? 1 : 0,
      'latitude': latitude,
      'longitude': longitude,
      'phone': _generatePhoneNumber(),
      'email': '${_generateEmail(name)}',
      'website': 'https://www.${_generateDomain(prefix)}.com',
      'opening_hours': openingHours,
      'created_at': now,
      'updated_at': now,
    };
  }

  /// 根据省份确定区域
  String _getRegionByProvince(String province) {
    if (province.contains('北京') ||
        province.contains('天津') ||
        province.contains('河北') ||
        province.contains('山西') ||
        province.contains('内蒙古')) {
      return 'North China';
    } else if (province.contains('辽宁') ||
        province.contains('吉林') ||
        province.contains('黑龙江')) {
      return 'Northeast China';
    } else if (province.contains('上海') ||
        province.contains('江苏') ||
        province.contains('浙江') ||
        province.contains('安徽') ||
        province.contains('福建') ||
        province.contains('江西') ||
        province.contains('山东') ||
        province.contains('台湾')) {
      return 'East China';
    } else if (province.contains('河南') ||
        province.contains('湖北') ||
        province.contains('湖南')) {
      return 'Central China';
    } else if (province.contains('广东') ||
        province.contains('广西') ||
        province.contains('海南') ||
        province.contains('香港') ||
        province.contains('澳门')) {
      return 'South China';
    } else if (province.contains('重庆') ||
        province.contains('四川') ||
        province.contains('贵州') ||
        province.contains('云南') ||
        province.contains('西藏')) {
      return 'Southwest China';
    } else {
      return 'Northwest China';
    }
  }

  /// 根据省份确定气候
  String _getClimateByProvince(String province) {
    if (province.contains('黑龙江') || province.contains('吉林') || province.contains('内蒙古')) {
      return 'Cold';
    } else if (province.contains('北京') ||
        province.contains('天津') ||
        province.contains('河北') ||
        province.contains('山西') ||
        province.contains('辽宁') ||
        province.contains('山东') ||
        province.contains('陕西') ||
        province.contains('甘肃')) {
      return 'Cool';
    } else if (province.contains('上海') ||
        province.contains('江苏') ||
        province.contains('浙江') ||
        province.contains('安徽') ||
        province.contains('湖北') ||
        province.contains('湖南') ||
        province.contains('江西') ||
        province.contains('四川') ||
        province.contains('重庆')) {
      return 'Mild';
    } else if (province.contains('福建') ||
        province.contains('广东') ||
        province.contains('广西') ||
        province.contains('贵州') ||
        province.contains('云南')) {
      return 'Warm';
    } else {
      return 'Hot';
    }
  }

  /// 根据气候获取天气描述
  String _getWeatherByClimate(String climate) {
    switch (climate) {
      case 'Cold':
        return 'Snowy';
      case 'Cool':
        return 'Cloudy';
      case 'Mild':
        return 'Partly Cloudy';
      case 'Warm':
        return 'Sunny';
      case 'Hot':
        return 'Clear';
      default:
        return 'Sunny';
    }
  }

  /// 获取人口范围
  String _getPopulationRange() {
    final ranges = ['500K', '1M', '2M', '5M', '10M', '15M'];
    return ranges[_random.nextInt(ranges.length)];
  }

  /// 生成电话号码
  String _generatePhoneNumber() {
    final prefixes = ['010', '021', '020', '0755', '0571', '028', '023'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final number = 10000000 + _random.nextInt(90000000);
    return '$prefix-$number';
  }

  /// 生成邮箱
  String _generateEmail(String name) {
    final cleanName = name.replaceAll(' ', '').replaceAll('联合办公', '').replaceAll('共享空间', '').toLowerCase();
    return 'info@${cleanName}.com';
  }

  /// 生成域名
  String _generateDomain(String prefix) {
    return prefix.replaceAll(' ', '').toLowerCase();
  }
}
