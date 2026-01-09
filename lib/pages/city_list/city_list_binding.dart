import 'package:get/get.dart';

import 'city_list_controller.dart';

/// CityList 页面绑定
class CityListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CityListController>(() => CityListController());
  }
}
