import 'package:get/get.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';

/// 登录页面绑定
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // 使用 fenix: true 确保控制器被删除后能重新创建
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}
