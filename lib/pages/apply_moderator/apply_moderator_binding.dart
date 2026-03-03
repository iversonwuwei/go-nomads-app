import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:go_nomads_app/features/moderator/infrastructure/repositories/moderator_application_repository.dart';
import 'package:go_nomads_app/pages/apply_moderator/apply_moderator_controller.dart';

/// 申请成为版主页面 Binding
///
/// 每次进入页面时创建全新控制器。
class ApplyModeratorBinding extends Bindings {
  @override
  void dependencies() {
    // 注册 Repository（共享层，不需要每次重建）
    if (!Get.isRegistered<IModeratorApplicationRepository>()) {
      Get.lazyPut<IModeratorApplicationRepository>(
        () => ModeratorApplicationRepository(),
      );
    }

    // 注册 Controller（每次全新创建）
    BindingHelper.putFresh<ApplyModeratorController>(
      () => ApplyModeratorController(Get.find<IModeratorApplicationRepository>()),
    );
  }
}
