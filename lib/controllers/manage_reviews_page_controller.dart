import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// ManageReviewsPage 控制器
class ManageReviewsPageController extends GetxController {
  final String cityId;
  final String cityName;

  ManageReviewsPageController({
    required this.cityId,
    required this.cityName,
  });

  final RxBool canDelete = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    _loadData();
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  Future<void> loadData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final controller = Get.find<UserCityContentStateController>();
      await controller.loadCityReviews(cityId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final controller = Get.find<UserCityContentStateController>();
      // 注意: 当前API只能删除自己的review,需要后端添加admin删除接口
      final success = await controller.deleteMyReview(cityId);

      if (success) {
        AppToast.success('评论已删除');
        await _loadData();
      } else {
        AppToast.error('删除失败,请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
