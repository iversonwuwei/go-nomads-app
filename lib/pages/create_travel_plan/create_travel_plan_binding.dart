import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';

class CreateTravelPlanBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;

    BindingHelper.putFresh<CreateTravelPlanPageController>(
      () => CreateTravelPlanPageController(
        cityId: args?['cityId'] as String? ?? '',
        cityName: args?['cityName'] as String? ?? '',
      ),
      tag: CreateTravelPlanPageController.controllerTag,
    );
  }
}
