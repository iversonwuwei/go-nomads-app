import 'package:df_admin_mobile/pages/home/home_page_controller.dart';
import 'package:get/get.dart';

/// 首页 Binding - GetX 依赖注入
class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    // 延迟初始化 HomePageController
    Get.lazyPut<HomePageController>(
      () => HomePageController(),
      fenix: true, // 允许重新创建
    );
  }
}
