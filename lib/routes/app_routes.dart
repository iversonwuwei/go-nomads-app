import 'package:get/get.dart';

import '../pages/ai_chat_page.dart';
import '../pages/analytics_tool_page.dart';
import '../pages/api_marketplace_page.dart';
import '../pages/city_chat_page.dart';
import '../pages/city_detail_page.dart';
import '../pages/data_service_page.dart';
import '../pages/location_demo_page.dart';
import '../pages/login_page_optimized.dart';
import '../pages/main_page.dart';
import '../pages/second_page.dart';
import '../pages/snake_game_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String second = '/second';
  static const String login = '/login';
  static const String aiChat = '/ai-chat';
  static const String snakeGame = '/snake-game';
  static const String apiMarketplace = '/api-marketplace';
  static const String dataService = '/data-service';
  static const String analyticsTool = '/analytics-tool';
  static const String cityDetail = '/city-detail';
  static const String cityChat = '/city-chat';
  static const String locationDemo = '/location-demo';

  static List<GetPage> getPages = [
    GetPage(
      name: home,
      page: () => const MainPage(),
    ),
    GetPage(
      name: second,
      page: () => const SecondPage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPageOptimized(),
    ),
    GetPage(
      name: aiChat,
      page: () => const AiChatPage(),
    ),
    GetPage(
      name: snakeGame,
      page: () => const SnakeGamePage(),
    ),
    GetPage(
      name: apiMarketplace,
      page: () => const ApiMarketplacePage(),
    ),
    GetPage(
      name: analyticsTool,
      page: () => const AnalyticsToolPage(),
    ),
    GetPage(
      name: dataService,
      page: () => const DataServicePage(),
    ),
    GetPage(
      name: cityDetail,
      page: () => const CityDetailPage(
        cityId: '',
        cityName: '',
        cityImage: '',
        overallScore: 0,
        reviewCount: 0,
      ),
    ),
    GetPage(
      name: cityChat,
      page: () => const CityChatPage(),
    ),
    GetPage(
      name: locationDemo,
      page: () => const LocationDemoPage(),
    ),
  ];
}
