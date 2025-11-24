import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:get/get.dart';

/// 底部导航控制器
/// 管理底部导航栏的状态和页面切换
class BottomNavController extends GetxController {
  // 当前选中的标签索引
  final RxInt currentIndex = 0.obs;

  // 导航栏可见性
  final RxBool isBottomNavVisible = true.obs;

  // 未读消息数量
  final RxInt unreadCount = 5.obs; // 测试数据：5条未读消息

  /// 切换标签页
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// 显示底部导航栏
  void showBottomNav() {
    isBottomNavVisible.value = true;
  }

  /// 隐藏底部导航栏
  void hideBottomNav() {
    isBottomNavVisible.value = false;
  }

  /// 重置到首页
  void resetToHome() {
    currentIndex.value = 0;
  }

  /// 根据当前路由更新选中的标签索引
  void updateIndexByRoute() {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.home) {
      currentIndex.value = 0;
    } else if (currentRoute == AppRoutes.profile) {
      currentIndex.value = 1; // Profile 是索引 1
    } else if (currentRoute == AppRoutes.aiChat) {
      currentIndex.value = 2; // AI助手是索引 2
    } else if (currentRoute == AppRoutes.languageSettings) {
      currentIndex.value = 3; // 设置是索引 3
    }
  }
}
