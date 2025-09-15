import 'package:get/get.dart';

import '../pages/ai_chat_page.dart';
import '../pages/api_marketplace_page.dart';
import '../pages/login_page.dart';
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
      page: () => const LoginPage(),
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
  ];
}
