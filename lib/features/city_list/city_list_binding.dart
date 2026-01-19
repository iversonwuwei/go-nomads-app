import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/services/search_service.dart';
import 'package:get/get.dart';

/// 城市列表页面依赖绑定
class CityListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CityListController>(
      () => CityListController(
        cityRepository: Get.find<ICityRepository>(),
        cityRatingUseCases: Get.find<CityRatingUseCases>(),
        searchService: Get.find<SearchService>(),
        cityStateController: Get.find<CityStateController>(),
      ),
    );
  }
}
