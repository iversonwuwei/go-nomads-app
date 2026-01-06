import 'package:df_admin_mobile/controllers/nomads_login_page_controller.dart';
import 'package:df_admin_mobile/pages/nomads_login/nomads_login_page.dart';
import 'package:get/get.dart';

/// NomadsLoginPage 的 Binding
/// 负责在路由进入时注册 Controller，路由离开时自动销毁
class NomadsLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NomadsLoginPageController>(
      () => NomadsLoginPageController(),
      tag: NomadsLoginPage.controllerTag,
    );
  }
}
