import 'package:get/get.dart';

import '../../features/city/application/state_controllers/pros_cons_state_controller.dart';
import '../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../features/city/presentation/controllers/city_rating_controller.dart';
import '../../features/coworking/presentation/controllers/coworking_state_controller_v2.dart';
import '../../features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import '../../features/weather/presentation/controllers/weather_state_controller.dart';

/// CityDetailPage 的依赖绑定
///
/// 每次进入 cityDetail 路由时，GetX 会调用 dependencies() 方法
/// 由于所有依赖都在 DependencyInjection 中使用 fenix: true 注册，
/// 这里只需要触发 Get.find 来确保依赖被创建/重建
class CityDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 触发依赖创建/重建（fenix: true 会自动处理重建）
    // 这些 Get.find 会确保控制器存在，如果不存在会通过 fenix 重建
    Get.find<CityDetailStateController>();
    Get.find<WeatherStateController>();
    Get.find<UserCityContentStateController>();
    Get.find<ProsConsStateController>();
    Get.find<CityRatingController>();
    Get.find<CoworkingStateControllerV2>();
  }
}
