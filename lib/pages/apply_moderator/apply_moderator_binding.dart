import 'package:df_admin_mobile/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:df_admin_mobile/features/moderator/infrastructure/repositories/moderator_application_repository.dart';
import 'package:df_admin_mobile/pages/apply_moderator/apply_moderator_controller.dart';
import 'package:get/get.dart';

/// 申请成为版主页面 Binding
class ApplyModeratorBinding extends Bindings {
  @override
  void dependencies() {
    // 注册 Repository
    if (!Get.isRegistered<IModeratorApplicationRepository>()) {
      Get.lazyPut<IModeratorApplicationRepository>(
        () => ModeratorApplicationRepository(),
      );
    }

    // 注册 Controller
    Get.lazyPut<ApplyModeratorController>(
      () => ApplyModeratorController(Get.find<IModeratorApplicationRepository>()),
    );
  }
}
