import '../database/coworking_dao.dart';

/// 共享办公空间数据服务
/// 提供共享办公空间数据的统一访问接口,从 SQLite 数据库读取和存储
class CoworkingDataService {
  final CoworkingDao _coworkingDao = CoworkingDao();

  /// 获取所有共享办公空间
  Future<List<Map<String, dynamic>>> getAllCoworkings() async {
    return await _coworkingDao.getAllCoworkings();
  }

  /// 根据ID获取共享办公空间
  Future<Map<String, dynamic>?> getCoworkingById(int id) async {
    return await _coworkingDao.getCoworkingById(id);
  }

  /// 按城市获取共享办公空间
  Future<List<Map<String, dynamic>>> getCoworkingsByCity(int cityId) async {
    return await _coworkingDao.getCoworkingsByCity(cityId);
  }

  /// 搜索共享办公空间
  Future<List<Map<String, dynamic>>> searchCoworkings(String keyword) async {
    return await _coworkingDao.searchCoworkings(keyword);
  }

  /// 添加新的共享办公空间
  Future<int> addCoworking(Map<String, dynamic> coworkingData) async {
    return await _coworkingDao.insertCoworking(coworkingData);
  }

  /// 更新共享办公空间
  Future<int> updateCoworking(
      int id, Map<String, dynamic> coworkingData) async {
    return await _coworkingDao.updateCoworking(id, coworkingData);
  }

  /// 删除共享办公空间
  Future<int> deleteCoworking(int id) async {
    return await _coworkingDao.deleteCoworking(id);
  }

  /// 筛选共享办公空间
  Future<List<Map<String, dynamic>>> filterCoworkings({
    int? cityId,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    List<Map<String, dynamic>> coworkings = await getAllCoworkings();

    // 按城市筛选
    if (cityId != null) {
      coworkings = coworkings.where((coworking) {
        return coworking['city_id'] == cityId;
      }).toList();
    }

    // 按价格范围筛选
    if (minPrice != null) {
      coworkings = coworkings.where((coworking) {
        final price = coworking['price_per_day'] as num?;
        return price != null && price >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      coworkings = coworkings.where((coworking) {
        final price = coworking['price_per_day'] as num?;
        return price != null && price <= maxPrice;
      }).toList();
    }

    // 按设施筛选
    if (amenities != null && amenities.isNotEmpty) {
      coworkings = coworkings.where((coworking) {
        final coworkingAmenities = coworking['amenities'] as String?;
        if (coworkingAmenities == null) return false;

        // 假设amenities以逗号分隔
        final amenitiesList =
            coworkingAmenities.split(',').map((e) => e.trim()).toList();

        // 检查是否包含所有必需的设施
        return amenities.every((required) => amenitiesList.any((available) =>
            available.toLowerCase().contains(required.toLowerCase())));
      }).toList();
    }

    return coworkings;
  }

  /// 排序共享办公空间
  List<Map<String, dynamic>> sortCoworkings(
    List<Map<String, dynamic>> coworkings,
    String sortBy,
  ) {
    final List<Map<String, dynamic>> sortedCoworkings = List.from(coworkings);

    switch (sortBy) {
      case 'price_asc':
        sortedCoworkings.sort((a, b) {
          final priceA = (a['price_per_day'] as num?)?.toDouble() ?? 0;
          final priceB = (b['price_per_day'] as num?)?.toDouble() ?? 0;
          return priceA.compareTo(priceB);
        });
        break;

      case 'price_desc':
        sortedCoworkings.sort((a, b) {
          final priceA = (a['price_per_day'] as num?)?.toDouble() ?? 0;
          final priceB = (b['price_per_day'] as num?)?.toDouble() ?? 0;
          return priceB.compareTo(priceA);
        });
        break;

      case 'rating':
        sortedCoworkings.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;

      case 'name':
        sortedCoworkings.sort((a, b) {
          final nameA = a['name'] as String? ?? '';
          final nameB = b['name'] as String? ?? '';
          return nameA.compareTo(nameB);
        });
        break;

      default:
        // 默认按评分排序
        sortedCoworkings.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0;
          return ratingB.compareTo(ratingA);
        });
    }

    return sortedCoworkings;
  }

  /// 获取所有可用的设施列表
  Future<List<String>> getAllAmenities() async {
    final coworkings = await getAllCoworkings();
    final Set<String> allAmenities = {};

    for (var coworking in coworkings) {
      final amenities = coworking['amenities'] as String?;
      if (amenities != null) {
        final amenitiesList =
            amenities.split(',').map((e) => e.trim()).toList();
        allAmenities.addAll(amenitiesList);
      }
    }

    final list = allAmenities.toList();
    list.sort();
    return list;
  }
}
