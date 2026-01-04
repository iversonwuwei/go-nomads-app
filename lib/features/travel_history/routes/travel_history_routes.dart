import 'package:get/get.dart';

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
class TravelHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TravelHistoryController>(() => TravelHistoryController());
  }
}

/// 访问地点控制器绑定
class VisitedPlacesBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    // 使用 Get.put 并设置 tag 确保每次进入页面都有正确的 Controller 实例
    // 先删除旧实例（如果存在）
    if (Get.isRegistered<VisitedPlacesController>()) {
      Get.delete<VisitedPlacesController>();
    }
    Get.put<VisitedPlacesController>(VisitedPlacesController(
      travelHistoryId: args?['travelHistoryId'] ?? '',
      cityName: args?['cityName'],
      countryName: args?['countryName'],
    ));
  }
}

