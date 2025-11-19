import '../entities/city_rating_category.dart';
import '../entities/city_rating_info.dart';

/// 城市评分仓储接口
abstract class ICityRatingRepository {
  /// 获取城市评分信息
  Future<CityRatingInfo> getCityRatings(String cityId);

  /// 提交评分
  Future<void> submitRating(String cityId, String categoryId, int rating);

  /// 获取所有评分项
  Future<List<CityRatingCategory>> getCategories();

  /// 创建自定义评分项
  Future<CityRatingCategory> createCategory({
    required String name,
    String? nameEn,
    String? description,
    String? icon,
    int displayOrder = 0,
  });

  /// 更新评分项
  Future<CityRatingCategory> updateCategory({
    required String cityId,
    required String categoryId,
    required String name,
    String? nameEn,
    String? description,
    String? icon,
  });

  /// 删除评分项
  Future<void> deleteCategory(String cityId, String categoryId);
}
