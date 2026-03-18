import 'package:get/get.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';

/// 首页 Binding - GetX 依赖注入
///
/// 首页是 BottomNavLayout 的根页面，控制器应保持永久存活。
/// 数据刷新由 HomePageController.onRouteResume() 处理，
/// 而非销毁重建控制器。
class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomePageController>()) {
      Get.put<HomePageController>(HomePageController(), permanent: true);
    }
  }
}
