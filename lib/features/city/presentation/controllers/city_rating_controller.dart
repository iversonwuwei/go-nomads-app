import 'dart:developer';

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
    log('🔍 [CityRatingController] 开始加载评分数据: cityId=$cityId');
    
    // 如果切换到不同城市，先清空旧数据
    if (_currentCityId != null && _currentCityId != cityId) {
      log('🔄 [CityRatingController] 城市切换: $_currentCityId -> $cityId, 清空旧数据');
      statistics.clear();
      categories.clear();
      overallScore.value = 0.0;
    }

    // 如果已经加载过相同城市的数据，不重复加载
    if (_currentCityId == cityId && statistics.isNotEmpty) {
      log('✅ [CityRatingController] 数据已缓存，跳过加载');
      return;
    }

    _currentCityId = cityId;
    isLoading.value = true;
    error.value = null;

    try {
      log('📡 [CityRatingController] 调用 API 获取评分信息...');
      final info = await _useCases.getCityRatings(cityId);
      
      log('📊 [CityRatingController] API 返回数据:');
      log('  - categories: ${info.categories.length} 项');
      log('  - statistics: ${info.statistics.length} 项');
      log('  - overallScore: ${info.overallScore}');

      // 如果没有评分项，尝试初始化默认评分项
      if (info.categories.isEmpty) {
        log('⚠️ [CityRatingController] 没有评分项，开始初始化默认评分项...');
        try {
          await _useCases.initializeDefaultCategories();
          log('✅ [CityRatingController] 默认评分项初始化成功，重新加载数据...');

          // 重新加载数据
          final updatedInfo = await _useCases.getCityRatings(cityId);
          categories.value = updatedInfo.categories;
          statistics.value = updatedInfo.statistics;
          overallScore.value = updatedInfo.overallScore;

          log('📊 [CityRatingController] 重新加载后的数据:');
          log('  - categories: ${updatedInfo.categories.length} 项');
          log('  - statistics: ${updatedInfo.statistics.length} 项');
        } catch (e) {
          log('❌ [CityRatingController] 初始化默认评分项失败: $e');
          // 初始化失败也不影响，继续显示空列表
          categories.value = info.categories;
          statistics.value = info.statistics;
          overallScore.value = info.overallScore;
        }
      } else {
        if (info.categories.isNotEmpty) {
          log('  - 评分项列表:');
          for (var cat in info.categories) {
            log('    * ${cat.name} (${cat.nameEn}) - ${cat.icon}');
          }
        }
        
        categories.value = info.categories;
        statistics.value = info.statistics;
        overallScore.value = info.overallScore;
      }
      
      log('✅ [CityRatingController] 评分数据加载完成');
    } catch (e) {
      log('❌ [CityRatingController] 加载评分信息失败: $e');
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
      // 找到当前评分项
      final index = statistics.indexWhere((s) => s.categoryId == categoryId);
      if (index == -1) return;

      // 保存原始数据用于回滚
      final originalStat = statistics[index];
      final isNewRating = originalStat.userRating == null;

      // 立即更新本地UI，不等待服务器响应
      final oldTotal = originalStat.averageRating * originalStat.ratingCount;
      final newCount =
          isNewRating ? originalStat.ratingCount + 1 : originalStat.ratingCount;
      final newTotal = isNewRating ? oldTotal + rating : oldTotal - (originalStat.userRating ?? 0) + rating;
      final newAverage = newCount > 0 ? newTotal / newCount : 0.0;

      // 立即更新UI
      statistics[index] = CityRatingStatistics(
        categoryId: originalStat.categoryId,
        categoryName: originalStat.categoryName,
        categoryNameEn: originalStat.categoryNameEn,
        icon: originalStat.icon,
        displayOrder: originalStat.displayOrder,
        ratingCount: newCount,
        averageRating: double.parse(newAverage.toStringAsFixed(1)),
        userRating: rating,
      );

      // 设置提交中状态（短暂显示）
      submittingCategoryId.value = categoryId;
      completedCategoryId.value = null;

      // 异步提交到服务器（不阻塞UI）
      _useCases.submitRating(_currentCityId!, categoryId, rating).then((_) {
        // 提交成功，显示完成状态
        submittingCategoryId.value = null;
        completedCategoryId.value = categoryId;

        // 500ms 后清除完成状态
        Future.delayed(const Duration(milliseconds: 500), () {
          if (completedCategoryId.value == categoryId) {
            completedCategoryId.value = null;
          }
        });
      }).catchError((e) {
        // 提交失败，回滚本地状态
        submittingCategoryId.value = null;
        completedCategoryId.value = null;

        // 恢复之前的评分
        final currentIndex = statistics.indexWhere((s) => s.categoryId == categoryId);
        if (currentIndex != -1) {
          statistics[currentIndex] = originalStat;
        }

        AppToast.error('提交评分失败');
      });

      // 100ms 后清除提交中状态（让用户看到反馈）
      Future.delayed(const Duration(milliseconds: 100), () {
        if (submittingCategoryId.value == categoryId) {
          submittingCategoryId.value = null;
        }
      });
      
    } catch (e) {
      submittingCategoryId.value = null;
      completedCategoryId.value = null;
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
