import 'package:get/get.dart';

import '../layouts/bottom_nav_layout.dart';
import '../middlewares/auth_middleware.dart';
import '../pages/ai_chat_page.dart';
import '../pages/city_chat_page.dart';
import '../pages/city_list_page.dart';
import '../pages/coworking_home_page.dart';
import '../pages/data_service_page.dart';
import '../pages/innovation_list_page.dart';
import '../pages/meetups_list_page.dart';
import '../pages/nomads_login_page.dart';
import '../pages/profile_edit_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String second = '/second';
  static const String login = '/login';
  static const String register = '/register';
  static const String aiChat = '/ai-chat';
  static const String dataService = '/data-service';
  static const String coworking = '/coworking';
  static const String cityChat = '/city-chat';
  static const String cityList = '/city-list';
  static const String meetupsList = '/meetups-list';
  static const String innovation = '/innovation';
  static const String locationDemo = '/location-demo';
  static const String languageSettings = '/language-settings';
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';

  static List<GetPage> getPages = [
    GetPage(
      name: home,
      page: () => const BottomNavLayout(child: DataServicePage()),
    ),
    GetPage(
      name: profile,
      page: () => const BottomNavLayout(child: ProfilePage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: login,
      page: () => const NomadsLoginPage(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: aiChat,
      page: () => const AiChatPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: dataService,
      page: () => const BottomNavLayout(child: DataServicePage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: coworking,
      page: () => const CoworkingHomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: cityChat,
      page: () => const BottomNavLayout(child: CityChatPage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: cityList,
      page: () => const CityListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: meetupsList,
      page: () => const MeetupsListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: innovation,
      page: () => const InnovationListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profileEdit,
      page: () => const BottomNavLayout(child: ProfileEditPage()),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
