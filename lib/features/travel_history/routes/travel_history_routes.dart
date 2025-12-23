import 'package:get/get.dart';

import '../presentation/controllers/travel_history_controller.dart';
import '../presentation/pages/travel_history_page.dart';

/// 旅行历史模块路由
class TravelHistoryRoutes {
  static const String travelHistory = '/travel-history';

  static List<GetPage> routes = [
    GetPage(
      name: travelHistory,
      page: () => const TravelHistoryPage(),
      binding: TravelHistoryBinding(),
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
