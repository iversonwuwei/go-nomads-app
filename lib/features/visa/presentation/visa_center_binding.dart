import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/visa/domain/repositories/i_visa_center_repository.dart';
import 'package:go_nomads_app/features/visa/infrastructure/repositories/visa_center_repository.dart';
import 'package:go_nomads_app/features/visa/presentation/controllers/visa_center_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/openclaw_automation_service.dart';

class VisaCenterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IVisaCenterRepository>()) {
      Get.lazyPut<IVisaCenterRepository>(
        () => VisaCenterRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<OpenClawAutomationService>()) {
      Get.lazyPut<OpenClawAutomationService>(() => OpenClawAutomationService(), fenix: true);
    }

    BindingHelper.putFresh<VisaCenterController>(
      () => VisaCenterController(
        Get.find<IVisaCenterRepository>(),
        Get.find<OpenClawAutomationService>(),
      ),
    );
  }
}
