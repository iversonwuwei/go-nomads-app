import 'package:df_admin_mobile/features/city/domain/entities/city_rating_category.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_rating_statistics.dart';
import 'package:df_admin_mobile/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 城市评分控制器
class CityRatingController extends GetxController {
  final CityRatingUseCases _useCases;

  CityRatingController(this._useCases);

  // 状态
  final isLoading = false.obs;
  final categories = <CityRatingCategory>[].obs;
  final statistics = <CityRatingStatistics>[].obs;
  final overallScore = 0.0.obs;
  final error = Rx<String?>(null);

  // 评分提交状态跟踪
  final submittingCategoryId = Rx<String?>(null);
  final completedCategoryId = Rx<String?>(null);

  // 当前城市ID
  String? _currentCityId;

  // 是否显示添加评分项对话框
  final showAddCategoryDialog = false.obs;

  // 是否显示管理评分项对话框
  final showManageCategoryDialog = false.obs;

  /// 加载城市评分信息
  Future<void> loadCityRatings(String cityId) async {
    print('🔍 [CityRatingController] 开始加载评分数据: cityId=$cityId');
    
    // 如果切换到不同城市，先清空旧数据
    if (_currentCityId != null && _currentCityId != cityId) {
      print('🔄 [CityRatingController] 城市切换: $_currentCityId -> $cityId, 清空旧数据');
      statistics.clear();
      categories.clear();
      overallScore.value = 0.0;
    }

    // 如果已经加载过相同城市的数据，不重复加载
    if (_currentCityId == cityId && statistics.isNotEmpty) {
      print('✅ [CityRatingController] 数据已缓存，跳过加载');
      return;
    }

    _currentCityId = cityId;
    isLoading.value = true;
    error.value = null;

    try {
      print('📡 [CityRatingController] 调用 API 获取评分信息...');
      final info = await _useCases.getCityRatings(cityId);
      
      print('📊 [CityRatingController] API 返回数据:');
      print('  - categories: ${info.categories.length} 项');
      print('  - statistics: ${info.statistics.length} 项');
      print('  - overallScore: ${info.overallScore}');

      if (info.categories.isNotEmpty) {
        print('  - 评分项列表:');
        for (var cat in info.categories) {
          print('    * ${cat.name} (${cat.nameEn}) - ${cat.icon}');
        }
      }
      
      categories.value = info.categories;
      statistics.value = info.statistics;
      overallScore.value = info.overallScore;
      
      print('✅ [CityRatingController] 评分数据加载完成');
    } catch (e) {
      print('❌ [CityRatingController] 加载评分信息失败: $e');
      error.value = e.toString();
      AppToast.error('加载评分信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新评分数据（用于添加评分项后）
  Future<void> refreshRatings() async {
    if (_currentCityId == null) return;

    // 清空当前数据，强制重新加载
    statistics.clear();
    categories.clear();

    await loadCityRatings(_currentCityId!);
  }

  /// 提交评分
  Future<void> submitRating(String categoryId, int rating) async {
    if (_currentCityId == null) return;

    // 如果正在提交，忽略
    if (submittingCategoryId.value != null) return;

    try {
      // 设置提交中状态
      submittingCategoryId.value = categoryId;
      completedCategoryId.value = null;

      await _useCases.submitRating(_currentCityId!, categoryId, rating);

      // 更新本地统计数据，无需重新加载
      final index = statistics.indexWhere((s) => s.categoryId == categoryId);
      if (index != -1) {
        final oldStat = statistics[index];
        final isNewRating = oldStat.userRating == null;

        // 重新计算平均分
        final oldTotal = oldStat.averageRating * oldStat.ratingCount;
        final newCount =
            isNewRating ? oldStat.ratingCount + 1 : oldStat.ratingCount;
        final newTotal = isNewRating
            ? oldTotal + rating
            : oldTotal - (oldStat.userRating ?? 0) + rating;
        final newAverage = newCount > 0 ? newTotal / newCount : 0.0;

        statistics[index] = CityRatingStatistics(
          categoryId: oldStat.categoryId,
          categoryName: oldStat.categoryName,
          categoryNameEn: oldStat.categoryNameEn,
          icon: oldStat.icon,
          displayOrder: oldStat.displayOrder,
          ratingCount: newCount,
          averageRating: double.parse(newAverage.toStringAsFixed(1)),
          userRating: rating,
        );
      }

      // 设置完成状态
      submittingCategoryId.value = null;
      completedCategoryId.value = categoryId;

      // 显示成功提示
      AppToast.success('评分提交成功');

      // 500ms 后清除完成状态
      Future.delayed(const Duration(milliseconds: 500), () {
        if (completedCategoryId.value == categoryId) {
          completedCategoryId.value = null;
        }
      });
    } catch (e) {
      submittingCategoryId.value = null;
      completedCategoryId.value = null;

      // 显示错误提示
      AppToast.error('提交评分失败');
    }
  }

  /// 创建自定义评分项
  Future<void> createCategory({
    required String name,
    String? nameEn,
    String? description,
    String? icon,
  }) async {
    try {
      final newCategory = await _useCases.createCategory(
        name: name,
        nameEn: nameEn,
        description: description,
        icon: icon,
        displayOrder: categories.length,
      );

      categories.add(newCategory);

      // 添加到统计列表
      statistics.add(CityRatingStatistics(
        categoryId: newCategory.id,
        categoryName: newCategory.name,
        categoryNameEn: newCategory.nameEn,
        icon: newCategory.icon,
        displayOrder: newCategory.displayOrder,
        ratingCount: 0,
        averageRating: 0.0,
      ));

      showAddCategoryDialog.value = false;

      AppToast.success('评分项创建成功');

      // 创建成功后刷新数据
      await refreshRatings();
    } catch (e) {
      AppToast.error('创建评分项失败: $e');
    }
  }

  /// 删除评分项
  Future<void> deleteCategory(String categoryId) async {
    if (_currentCityId == null) return;

    try {
      await _useCases.deleteCategory(_currentCityId!, categoryId);

      categories.removeWhere((c) => c.id == categoryId);
      statistics.removeWhere((s) => s.categoryId == categoryId);

      AppToast.success('评分项删除成功');

      // 删除成功后刷新数据
      await refreshRatings();
    } catch (e) {
      AppToast.error('删除评分项失败: $e');
    }
  }

  /// 获取评分项的用户评分
  int? getUserRating(String categoryId) {
    final stat = statistics.firstWhereOrNull((s) => s.categoryId == categoryId);
    return stat?.userRating;
  }

  /// 获取评分项的平均评分
  double getAverageRating(String categoryId) {
    final stat = statistics.firstWhereOrNull((s) => s.categoryId == categoryId);
    return stat?.averageRating ?? 0.0;
  }

  @override
  void onClose() {
    categories.clear();
    statistics.clear();
    _currentCityId = null;
    error.value = null;
    super.onClose();
  }
}
