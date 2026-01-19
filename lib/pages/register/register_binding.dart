import 'package:get/get.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';

/// 注册页面绑定
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
