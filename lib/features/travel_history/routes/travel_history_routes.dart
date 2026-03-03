import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';

import '../presentation/controllers/travel_history_controller.dart';
import '../presentation/controllers/visited_places_controller.dart';
import '../presentation/pages/travel_history_page.dart';
import '../presentation/pages/visited_places_page.dart';

/// 旅行历史模块路由
class TravelHistoryRoutes {
  static const String travelHistory = '/travel-history';
  static const String visitedPlaces = '/visited-places';

  static List<GetPage> routes = [
    GetPage(
      name: travelHistory,
      page: () => const TravelHistoryPage(),
      binding: TravelHistoryBinding(),
    ),
    GetPage(
      name: visitedPlaces,
      page: () => const VisitedPlacesPage(),
      binding: VisitedPlacesBinding(),
    ),
  ];
}

/// 旅行历史控制器绑定
///
/// 每次进入页面时创建全新控制器。
class TravelHistoryBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<TravelHistoryController>(
      () => TravelHistoryController(),
    );
  }
}

/// 访问地点控制器绑定
///
/// 每次进入页面时创建全新控制器。
class VisitedPlacesBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    BindingHelper.putFresh<VisitedPlacesController>(
      () => VisitedPlacesController(
        travelHistoryId: args?['travelHistoryId'] ?? '',
        cityId: args?['cityId'],
        cityName: args?['cityName'],
        countryName: args?['countryName'],
      ),
    );
  }
}
