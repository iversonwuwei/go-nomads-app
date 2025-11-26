import 'package:df_admin_mobile/layouts/bottom_nav_layout.dart';
import 'package:df_admin_mobile/middlewares/auth_middleware.dart';
import 'package:df_admin_mobile/pages/add_cost_page.dart';
import 'package:df_admin_mobile/pages/add_coworking_page.dart';
import 'package:df_admin_mobile/pages/add_innovation_page.dart';
import 'package:df_admin_mobile/pages/add_review_page.dart';
import 'package:df_admin_mobile/pages/ai_chat_page.dart';
import 'package:df_admin_mobile/pages/amap_global_page.dart';
import 'package:df_admin_mobile/pages/city_chat_page.dart';
import 'package:df_admin_mobile/pages/city_detail_page.dart';
import 'package:df_admin_mobile/pages/city_list_page.dart';
import 'package:df_admin_mobile/pages/city_search_page.dart';
import 'package:df_admin_mobile/pages/community_page.dart';
import 'package:df_admin_mobile/pages/coworking_detail_page.dart';
import 'package:df_admin_mobile/pages/coworking_home_page.dart';
import 'package:df_admin_mobile/pages/coworking_list_page.dart';
import 'package:df_admin_mobile/pages/create_meetup_page.dart';
import 'package:df_admin_mobile/pages/create_travel_plan_page.dart';
import 'package:df_admin_mobile/pages/data_service_page.dart';
import 'package:df_admin_mobile/pages/direct_chat_page.dart';
import 'package:df_admin_mobile/pages/edit_basic_info_page.dart';
import 'package:df_admin_mobile/pages/edit_interests_page.dart';
import 'package:df_admin_mobile/pages/edit_skills_page.dart';
import 'package:df_admin_mobile/pages/edit_social_links_page.dart';
import 'package:df_admin_mobile/pages/favorites_page.dart';
import 'package:df_admin_mobile/pages/global_map_page.dart';
import 'package:df_admin_mobile/pages/hotel_detail_page.dart';
import 'package:df_admin_mobile/pages/hotel_list_page.dart';
import 'package:df_admin_mobile/pages/innovation_detail_page.dart';
import 'package:df_admin_mobile/pages/innovation_list_page.dart';
import 'package:df_admin_mobile/pages/invite_to_meetup_page.dart';
import 'package:df_admin_mobile/pages/meetup_detail_page.dart';
import 'package:df_admin_mobile/pages/meetups_list_page.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/pages/nomads_login_page.dart';
import 'package:df_admin_mobile/pages/notifications_page.dart';
import 'package:df_admin_mobile/pages/profile_edit_page.dart';
import 'package:df_admin_mobile/pages/profile_page.dart';
import 'package:df_admin_mobile/pages/pros_and_cons_add_page.dart';
import 'package:df_admin_mobile/pages/register_page.dart';
import 'package:df_admin_mobile/pages/skills_interests_page.dart';
import 'package:df_admin_mobile/pages/travel_plan_page.dart';
import 'package:df_admin_mobile/pages/user_profile_page.dart';
import 'package:get/get.dart';

class AppRoutes {
  // ============================================================================
  // 白名单路由 - 不需要认证
  // ============================================================================
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ============================================================================
  // 城市相关路由
  // ============================================================================
  static const String cityList = '/city-list';
  static const String cityDetail = '/city-detail';
  static const String citySearch = '/city-search';
  static const String cityChat = '/city-chat';
  static const String favorites = '/favorites';
  static const String globalMap = '/global-map';
  static const String amapGlobal = '/amap-global';
  static const String addReview = '/add-review';
  static const String addCost = '/add-cost';
  static const String prosConsAdd = '/pros-cons-add';

  // ============================================================================
  // 活动相关路由
  // ============================================================================
  static const String meetupsList = '/meetups-list';
  static const String meetupDetail = '/meetup-detail';
  static const String createMeetup = '/create-meetup';
  static const String inviteToMeetup = '/invite-to-meetup';

  // ============================================================================
  // 共享办公相关路由
  // ============================================================================
  static const String coworking = '/coworking';
  static const String coworkingList = '/coworking-list';
  static const String coworkingDetail = '/coworking-detail';
  static const String addCoworking = '/add-coworking';

  // ============================================================================
  // 酒店相关路由
  // ============================================================================
  static const String hotelList = '/hotel-list';
  static const String hotelDetail = '/hotel-detail';

  // ============================================================================
  // 旅行计划相关路由
  // ============================================================================
  static const String travelPlan = '/travel-plan';
  static const String createTravelPlan = '/create-travel-plan';

  // ============================================================================
  // 创新项目相关路由
  // ============================================================================
  static const String innovation = '/innovation';
  static const String innovationDetail = '/innovation-detail';
  static const String addInnovation = '/add-innovation';

  // ============================================================================
  // 用户相关路由
  // ============================================================================
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String userProfile = '/user-profile';
  static const String memberDetail = '/member-detail';
  static const String skillsInterests = '/skills-interests';
  static const String editBasicInfo = '/edit-basic-info';
  static const String editSkills = '/edit-skills';
  static const String editInterests = '/edit-interests';
  static const String editSocialLinks = '/edit-social-links';

  // ============================================================================
  // AI 和聊天相关路由
  // ============================================================================
  static const String aiChat = '/ai-chat';
  static const String directChat = '/direct-chat';
  static const String notifications = '/notifications';

  // ============================================================================
  // 社区相关路由
  // ============================================================================
  static const String community = '/community';

  // ============================================================================
  // 其他路由
  // ============================================================================
  static const String dataService = '/data-service';
  static const String locationDemo = '/location-demo';
  static const String languageSettings = '/language-settings';
  static const String second = '/second';

  static List<GetPage> getPages = [
    // ============================================================================
    // ✅ 白名单路由：不需要认证（仅登录和注册）
    // ============================================================================
    GetPage(
      name: login,
      page: () => const NomadsLoginPage(),
      // 🚫 无 middleware - 登录页
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      // 🚫 无 middleware - 注册页
    ),

    // ============================================================================
    // 🔒 首页 - 需要认证
    // ============================================================================
    GetPage(
      name: home,
      page: () => const BottomNavLayout(child: DataServicePage()),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 城市相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: cityList,
      page: () => const CityListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: cityDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return CityDetailPage(
          cityId: args['cityId'] ?? '',
          cityName: args['cityName'] ?? '',
          cityImage: args['cityImage'] ?? '',
          overallScore: args['overallScore'] ?? 0.0,
          reviewCount: args['reviewCount'] ?? 0,
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: citySearch,
      page: () => const CitySearchPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: cityChat,
      page: () => const BottomNavLayout(child: CityChatPage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: globalMap,
      page: () => const GlobalMapPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: amapGlobal,
      page: () => const AmapGlobalPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addReview,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return AddReviewPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addCost,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return AddCostPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: prosConsAdd,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ProsAndConsAddPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
          initialTab: args['initialTab'] ?? 0,
        );
      },
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 活动相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: meetupsList,
      page: () => const MeetupsListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: meetupDetail,
      page: () => MeetupDetailPage(meetup: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: createMeetup,
      page: () => const CreateMeetupPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: inviteToMeetup,
      page: () => InviteToMeetupPage(user: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 共享办公相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: coworking,
      page: () => const CoworkingHomePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: coworkingList,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return CoworkingListPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
          countryName: args['countryName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: coworkingDetail,
      page: () => CoworkingDetailPage(space: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addCoworking,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return AddCoworkingPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
          countryName: args['countryName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 酒店相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: hotelList,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return HotelListPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: hotelDetail,
      page: () => HotelDetailPage(hotelId: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 旅行计划相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: travelPlan,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return TravelPlanPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: createTravelPlan,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return CreateTravelPlanPage(
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 创新项目相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: innovation,
      page: () => const InnovationListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: innovationDetail,
      page: () => InnovationDetailPage(project: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addInnovation,
      page: () => const AddInnovationPage(),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 用户相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: profile,
      page: () => const BottomNavLayout(child: ProfilePage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: profileEdit,
      page: () => const BottomNavLayout(child: ProfileEditPage()),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: userProfile,
      page: () => const UserProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberDetail,
      page: () => MemberDetailPage(user: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: skillsInterests,
      page: () => const SkillsInterestsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editBasicInfo,
      page: () => EditBasicInfoPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editSkills,
      page: () => EditSkillsPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editInterests,
      page: () => EditInterestsPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editSocialLinks,
      page: () => EditSocialLinksPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 AI 和聊天相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: aiChat,
      page: () => const AiChatPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: directChat,
      page: () => DirectChatPage(user: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => const BottomNavLayout(child: NotificationsPage()),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================================
    // 🔒 社区相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: community,
      page: () => const CommunityPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
