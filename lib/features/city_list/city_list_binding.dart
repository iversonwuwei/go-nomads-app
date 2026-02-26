import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';
import 'package:go_nomads_app/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/services/search_service.dart';

/// 城市列表页面依赖绑定
///
/// 每次进入页面时删除旧控制器，创建全新实例，
/// 确保数据从服务端全新加载。
class CityListBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<CityListController>(
      () => CityListController(
        cityRepository: Get.find<ICityRepository>(),
        cityRatingUseCases: Get.find<CityRatingUseCases>(),
        searchService: Get.find<SearchService>(),
        cityStateController: Get.find<CityStateController>(),
      ),
    );
  }
}
