import 'package:get/get.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';

/// 登录页面绑定
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
