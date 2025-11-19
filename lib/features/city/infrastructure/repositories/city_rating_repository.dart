import 'package:get/get.dart';

import '../../../../services/http_service.dart';
import '../../domain/entities/city_rating_category.dart';
import '../../domain/entities/city_rating_info.dart';
import '../../domain/repositories/icity_rating_repository.dart';
import '../models/city_rating_category_dto.dart';
import '../models/city_rating_info_dto.dart';

/// 城市评分仓储实现
class CityRatingRepository implements ICityRatingRepository {
  final HttpService _httpService = Get.find();

  @override
  Future<CityRatingInfo> getCityRatings(String cityId) async {
    try {
      final response = await _httpService.get(
        '/cities/$cityId/ratings',
      );

      final data = response.data as Map<String, dynamic>;
      final dto = CityRatingInfoDto.fromJson(data);
      return dto.toEntity();
    } catch (e) {
      throw Exception('获取城市评分信息失败: ${e.toString()}');
    }
  }

  @override
  Future<void> submitRating(String cityId, String categoryId, int rating) async {
    try {
      await _httpService.post(
        '/cities/$cityId/ratings',
        data: {
          'categoryId': categoryId,
          'rating': rating,
        },
      );
    } catch (e) {
      throw Exception('提交评分失败: ${e.toString()}');
    }
  }

  @override
  Future<List<CityRatingCategory>> getCategories() async {
    try {
      // 使用任意 cityId 获取所有评分项（评分项是全局的）
      final response = await _httpService.get(
        '/cities/00000000-0000-0000-0000-000000000000/ratings/categories',
      );

      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              CityRatingCategoryDto.fromJson(item as Map<String, dynamic>))
          .map((dto) => dto.toEntity())
          .toList();
    } catch (e) {
      throw Exception('获取评分项列表失败: ${e.toString()}');
    }
  }

  @override
  Future<CityRatingCategory> createCategory({
    required String name,
    String? nameEn,
    String? description,
    String? icon,
    int displayOrder = 0,
  }) async {
    try {
      final response = await _httpService.post(
        '/cities/00000000-0000-0000-0000-000000000000/ratings/categories',
        data: {
          'name': name,
          if (nameEn != null) 'nameEn': nameEn,
          if (description != null) 'description': description,
          if (icon != null) 'icon': icon,
          'displayOrder': displayOrder,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final dto = CityRatingCategoryDto.fromJson(data);
      return dto.toEntity();
    } catch (e) {
      throw Exception('创建评分项失败: ${e.toString()}');
    }
  }

  @override
  Future<CityRatingCategory> updateCategory({
    required String cityId,
    required String categoryId,
    required String name,
    String? nameEn,
    String? description,
    String? icon,
  }) async {
    try {
      final response = await _httpService.put(
        '/cities/$cityId/ratings/categories/$categoryId',
        data: {
          'name': name,
          if (nameEn != null) 'nameEn': nameEn,
          if (description != null) 'description': description,
          if (icon != null) 'icon': icon,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final dto = CityRatingCategoryDto.fromJson(data);
      return dto.toEntity();
    } catch (e) {
      throw Exception('更新评分项失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String cityId, String categoryId) async {
    try {
      await _httpService.delete(
        '/cities/$cityId/ratings/categories/$categoryId',
      );
    } catch (e) {
      throw Exception('删除评分项失败: ${e.toString()}');
    }
  }
}
