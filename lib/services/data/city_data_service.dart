import '../database/city_dao.dart';

/// 城市数据服务
/// 提供城市数据的统一访问接口,从 SQLite 数据库读取和存储
class CityDataService {
  final CityDao _cityDao = CityDao();

  /// 获取所有城市
  Future<List<Map<String, dynamic>>> getAllCities() async {
    return await _cityDao.getAllCities();
  }

  /// 根据ID获取城市
  Future<Map<String, dynamic>?> getCityById(int id) async {
    return await _cityDao.getCityById(id);
  }

  /// 根据名称获取城市
  Future<Map<String, dynamic>?> getCityByName(String name) async {
    return await _cityDao.getCityByName(name);
  }

  /// 按国家获取城市列表
  Future<List<Map<String, dynamic>>> getCitiesByCountry(String country) async {
    return await _cityDao.getCitiesByCountry(country);
  }

  /// 搜索城市
  Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    return await _cityDao.searchCities(keyword);
  }

  /// 添加新城市
  Future<int> addCity(Map<String, dynamic> cityData) async {
    return await _cityDao.insertCity(cityData);
  }

  /// 更新城市信息
  Future<int> updateCity(int id, Map<String, dynamic> cityData) async {
    return await _cityDao.updateCity(id, cityData);
  }

  /// 删除城市
  Future<int> deleteCity(int id) async {
    return await _cityDao.deleteCity(id);
  }

  /// 获取所有国家列表(去重)
  Future<List<String>> getAllCountries() async {
    final cities = await getAllCities();
    final countries = cities
        .map((city) => city['country'] as String?)
        .where((country) => country != null)
        .cast<String>()
        .toSet()
        .toList();
    countries.sort();
    return countries;
  }

  /// 获取所有地区列表(去重)
  Future<List<String>> getAllRegions() async {
    final cities = await getAllCities();
    final regions = cities
        .map((city) => city['region'] as String?)
        .where((region) => region != null)
        .cast<String>()
        .toSet()
        .toList();
    regions.sort();
    return regions;
  }

  /// 筛选城市
  /// 支持多条件筛选:地区、国家、价格范围、网速、评分、AQI等
  Future<List<Map<String, dynamic>>> filterCities({
    List<String>? regions,
    List<String>? countries,
    List<String>? climates,
    double? minPrice,
    double? maxPrice,
    double? minInternet,
    double? minRating,
    int? maxAqi,
  }) async {
    List<Map<String, dynamic>> cities = await getAllCities();

    // 按地区筛选
    if (regions != null && regions.isNotEmpty) {
      cities = cities.where((city) {
        final region = city['region'] as String?;
        return region != null && regions.contains(region);
      }).toList();
    }

    // 按国家筛选
    if (countries != null && countries.isNotEmpty) {
      cities = cities.where((city) {
        final country = city['country'] as String?;
        return country != null && countries.contains(country);
      }).toList();
    }

    // 按气候筛选
    if (climates != null && climates.isNotEmpty) {
      cities = cities.where((city) {
        final climate = city['climate'] as String?;
        return climate != null && climates.contains(climate);
      }).toList();
    }

    // 按价格范围筛选
    if (minPrice != null) {
      cities = cities.where((city) {
        final price = city['cost_of_living'] as num?;
        return price != null && price >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      cities = cities.where((city) {
        final price = city['cost_of_living'] as num?;
        return price != null && price <= maxPrice;
      }).toList();
    }

    // 按网速筛选
    if (minInternet != null) {
      cities = cities.where((city) {
        final internet = city['internet_speed'] as num?;
        return internet != null && internet >= minInternet;
      }).toList();
    }

    // 按评分筛选
    if (minRating != null) {
      cities = cities.where((city) {
        final rating = city['overall_score'] as num?;
        return rating != null && rating >= minRating;
      }).toList();
    }

    // 按AQI筛选
    if (maxAqi != null) {
      cities = cities.where((city) {
        final aqi = city['aqi'] as int?;
        return aqi == null || aqi <= maxAqi;
      }).toList();
    }

    return cities;
  }

  /// 排序城市
  Future<List<Map<String, dynamic>>> sortCities(
    List<Map<String, dynamic>> cities,
    String sortBy,
  ) async {
    final List<Map<String, dynamic>> sortedCities = List.from(cities);

    switch (sortBy) {
      case 'price_asc':
        sortedCities.sort((a, b) {
          final priceA = (a['cost_of_living'] as num?)?.toDouble() ?? 0;
          final priceB = (b['cost_of_living'] as num?)?.toDouble() ?? 0;
          return priceA.compareTo(priceB);
        });
        break;

      case 'price_desc':
        sortedCities.sort((a, b) {
          final priceA = (a['cost_of_living'] as num?)?.toDouble() ?? 0;
          final priceB = (b['cost_of_living'] as num?)?.toDouble() ?? 0;
          return priceB.compareTo(priceA);
        });
        break;

      case 'internet':
        sortedCities.sort((a, b) {
          final internetA = (a['internet_speed'] as num?)?.toDouble() ?? 0;
          final internetB = (b['internet_speed'] as num?)?.toDouble() ?? 0;
          return internetB.compareTo(internetA);
        });
        break;

      case 'rating':
        sortedCities.sort((a, b) {
          final ratingA = (a['overall_score'] as num?)?.toDouble() ?? 0;
          final ratingB = (b['overall_score'] as num?)?.toDouble() ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;

      case 'aqi':
        sortedCities.sort((a, b) {
          final aqiA = a['aqi'] as int? ?? 999;
          final aqiB = b['aqi'] as int? ?? 999;
          return aqiA.compareTo(aqiB);
        });
        break;

      case 'popular':
      default:
        // 按综合评分排序
        sortedCities.sort((a, b) {
          final scoreA = (a['overall_score'] as num?)?.toDouble() ?? 0;
          final scoreB = (b['overall_score'] as num?)?.toDouble() ?? 0;
          return scoreB.compareTo(scoreA);
        });
    }

    return sortedCities;
  }
}
