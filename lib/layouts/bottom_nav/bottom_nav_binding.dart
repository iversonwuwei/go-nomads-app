import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav_controller.dart';
import 'package:get/get.dart';

/// 底部导航 Binding - GetX 依赖注入
class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    // BottomNavController 需要全局唯一且持久化
    Get.put<BottomNavController>(
      BottomNavController(),
      permanent: true,
    );
  }
}
