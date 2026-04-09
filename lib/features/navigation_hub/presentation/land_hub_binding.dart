import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_land_hub_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/infrastructure/repositories/land_hub_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/presentation/controllers/land_hub_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';

class LandHubBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ILandHubRepository>()) {
      Get.lazyPut<ILandHubRepository>(
        () => LandHubRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    BindingHelper.putFresh<LandHubController>(
      () => LandHubController(
        Get.find<ILandHubRepository>(),
      ),
    );
  }
}
