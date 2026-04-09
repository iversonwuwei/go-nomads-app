import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/budget/domain/repositories/i_budget_center_repository.dart';
import 'package:go_nomads_app/features/budget/infrastructure/repositories/budget_center_repository.dart';
import 'package:go_nomads_app/features/budget/presentation/controllers/budget_center_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';

class BudgetCenterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IBudgetCenterRepository>()) {
      Get.lazyPut<IBudgetCenterRepository>(
        () => BudgetCenterRepository(Get.find<HttpService>()),
        fenix: true,
      );
    }

    BindingHelper.putFresh<BudgetCenterController>(
      () => BudgetCenterController(Get.find<IBudgetCenterRepository>()),
    );
  }
}
