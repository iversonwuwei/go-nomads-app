import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';

/// 登录页面绑定
///
/// 每次进入登录页时创建全新控制器，清除旧的登录状态。
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<LoginController>(() => LoginController());
  }
}
