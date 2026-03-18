import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';

/// 注册页面绑定
///
/// 每次进入注册页时创建全新控制器。
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<RegisterController>(() => RegisterController());
  }
}
