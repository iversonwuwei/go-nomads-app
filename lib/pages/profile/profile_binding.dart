import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/pages/profile/domain/repositories/i_profile_snapshot_repository.dart';
import 'package:go_nomads_app/pages/profile/infrastructure/repositories/profile_snapshot_repository.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IProfileSnapshotRepository>()) {
      Get.lazyPut<IProfileSnapshotRepository>(
        () => ProfileSnapshotRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    BindingHelper.putFresh<ProfileController>(
      () => ProfileController(Get.find<IProfileSnapshotRepository>()),
    );
  }
}
