import 'package:go_nomads_app/features/city/domain/entities/city_rating_category.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_rating_info.dart';
import 'package:go_nomads_app/features/city/domain/repositories/icity_rating_repository.dart';

/// 城市评分用例
class CityRatingUseCases {
  final ICityRatingRepository _repository;

  CityRatingUseCases(this._repository);

  /// 获取城市评分信息
  Future<CityRatingInfo> getCityRatings(String cityId) {
    return _repository.getCityRatings(cityId);
  }

  /// 提交评分
  Future<void> submitRating(String cityId, String categoryId, int rating) {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('评分必须在0-5之间');
    }
    return _repository.submitRating(cityId, categoryId, rating);
  }

  /// 获取所有评分项
  Future<List<CityRatingCategory>> getCategories() {
    return _repository.getCategories();
  }

  /// 创建自定义评分项
  Future<CityRatingCategory> createCategory({
    required String name,
    String? nameEn,
    String? description,
    String? icon,
    int displayOrder = 0,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError('评分项名称不能为空');
    }
    return _repository.createCategory(
      name: name.trim(),
      nameEn: nameEn?.trim(),
      description: description?.trim(),
      icon: icon?.trim(),
      displayOrder: displayOrder,
    );
  }

  /// 更新评分项
  Future<CityRatingCategory> updateCategory({
    required String cityId,
    required String categoryId,
    required String name,
    String? nameEn,
    String? description,
    String? icon,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError('评分项名称不能为空');
    }
    return _repository.updateCategory(
      cityId: cityId,
      categoryId: categoryId,
      name: name.trim(),
      nameEn: nameEn?.trim(),
      description: description?.trim(),
      icon: icon?.trim(),
    );
  }

  /// 删除评分项
  Future<void> deleteCategory(String cityId, String categoryId) {
    return _repository.deleteCategory(cityId, categoryId);
  }

  /// 初始化默认评分项
  Future<void> initializeDefaultCategories() {
    return _repository.initializeDefaultCategories();
  }
}
