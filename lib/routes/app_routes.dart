import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/change_password_page_controller.dart';
import 'package:go_nomads_app/controllers/forgot_password_page_controller.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/core/lifecycle/page_lifecycle_middleware.dart';
import 'package:go_nomads_app/features/city_list/city_list.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail.dart';
import 'package:go_nomads_app/features/membership/presentation/pages/membership_plan_page.dart';
import 'package:go_nomads_app/features/membership/presentation/widgets/ai_planner_membership_guard.dart';
import 'package:go_nomads_app/features/moderator/presentation/pages/moderator_application_detail_page.dart';
import 'package:go_nomads_app/features/travel_history/travel_history.dart';
import 'package:go_nomads_app/layouts/bottom_nav/bottom_nav.dart';
import 'package:go_nomads_app/middlewares/auth_middleware.dart';
import 'package:go_nomads_app/pages/add_cost/add_cost_page.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_page.dart';
import 'package:go_nomads_app/pages/add_hotel_page.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_page.dart';
import 'package:go_nomads_app/pages/add_review_page.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_binding.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_page.dart';
import 'package:go_nomads_app/pages/change_password/change_password_page.dart';
import 'package:go_nomads_app/pages/city_chat_page.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:go_nomads_app/pages/city_search_page.dart';
import 'package:go_nomads_app/pages/community_page.dart';
import 'package:go_nomads_app/pages/conversations/conversation_list_page.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_page.dart';
import 'package:go_nomads_app/pages/coworking_home_page.dart';
import 'package:go_nomads_app/pages/coworking_list_page.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/create_travel_plan/create_travel_plan_binding.dart';
import 'package:go_nomads_app/pages/create_travel_plan/create_travel_plan_page.dart';
import 'package:go_nomads_app/pages/edit_basic_info_page.dart';
import 'package:go_nomads_app/pages/edit_interests_page.dart';
import 'package:go_nomads_app/pages/edit_skills_page.dart';
import 'package:go_nomads_app/pages/edit_social_links_page.dart';
import 'package:go_nomads_app/pages/favorites_page.dart';
import 'package:go_nomads_app/pages/forgot_password/forgot_password_page.dart';
import 'package:go_nomads_app/pages/global_map_page.dart';
import 'package:go_nomads_app/pages/home/home.dart';
import 'package:go_nomads_app/pages/hotel_detail_page.dart';
import 'package:go_nomads_app/pages/hotel_list/hotel_list_page.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_page.dart';
import 'package:go_nomads_app/pages/innovation_list/innovation_list_page.dart';
import 'package:go_nomads_app/pages/invite_to_meetup_page.dart';
import 'package:go_nomads_app/pages/legal/community_guidelines_page.dart';
import 'package:go_nomads_app/pages/legal/privacy_policy_page.dart';
import 'package:go_nomads_app/pages/legal/terms_of_service_page.dart';
import 'package:go_nomads_app/pages/login/login.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list.dart';
import 'package:go_nomads_app/pages/member_detail_page.dart';
import 'package:go_nomads_app/pages/my_meetups_page.dart';
import 'package:go_nomads_app/pages/notifications_page.dart';
import 'package:go_nomads_app/pages/profile_edit_page.dart';
import 'package:go_nomads_app/pages/profile_page.dart';
import 'package:go_nomads_app/pages/pros_and_cons_add_page.dart';
import 'package:go_nomads_app/pages/register/register.dart';
import 'package:go_nomads_app/pages/skills_interests_page.dart';
import 'package:go_nomads_app/pages/tencent_im_direct_chat_page.dart';
import 'package:go_nomads_app/pages/travel_plan/travel_plan_page.dart';
import 'package:go_nomads_app/pages/user_profile_page.dart';

class AppRoutes {
  // ============================================================================
  // 启动页路由（内部使用）
  // ============================================================================
  static const String splash = '/';

  // ============================================================================
  // 白名单路由 - 不需要认证
  // ============================================================================
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String termsOfService = '/terms-of-service';
  static const String communityGuidelinesPage = '/community-guidelines';
  static const String privacyPolicy = '/privacy-policy';

  // ============================================================================
  // 城市相关路由
  // ============================================================================
  static const String cityList = '/city-list';
  static const String cityDetail = '/city-detail';
  static const String citySearch = '/city-search';
  static const String cityChat = '/city-chat';
  static const String favorites = '/favorites';
  static const String globalMap = '/global-map';
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
  static const String myMeetups = '/my-meetups';

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
  static const String addHotel = '/add-hotel';

  // ============================================================================
  // 旅行计划相关路由
  // ============================================================================
  static const String travelPlan = '/travel-plan';
  static const String createTravelPlan = '/create-travel-plan';
  static const String aiPlannerTab = '/ai-planner-tab';
  static const String travelHistory = '/travel-history';

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
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';

  // ============================================================================
  // 会员相关路由
  // ============================================================================
  static const String membershipPlan = '/membership-plan';

  // ============================================================================
  // AI 和聊天相关路由
  // ============================================================================
  static const String aiChat = '/ai-chat';
  static const String aiAssistantTab = '/ai-assistant-tab';
  static const String directChat = '/direct-chat';
  static const String conversations = '/conversations';
  static const String notifications = '/notifications';

  // ============================================================================
  // 社区相关路由
  // ============================================================================
  static const String community = '/community';

  // ============================================================================
  // 管理员路由
  // ============================================================================
  static const String moderatorApplicationDetail = '/admin/moderator-application-detail';

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
      page: () => const LoginPage(),
      binding: LoginBinding(),
      // 🚫 无 middleware - 登录页
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      // 🚫 无 middleware - 注册页
    ),
    GetPage(
      name: termsOfService,
      page: () => const TermsOfServicePage(),
      // 🚫 无 middleware - 服务条款
    ),
    GetPage(
      name: communityGuidelinesPage,
      page: () => const CommunityGuidelinesPage(),
      // 🚫 无 middleware - 社区准则
    ),
    GetPage(
      name: privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      // 🚫 无 middleware - 隐私政策
    ),

    // ============================================================================
    // 🔒 首页 - 需要认证
    // ============================================================================
    GetPage(
      name: home,
      page: () => const BottomNavLayout(child: HomePage()),
      binding: HomePageBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 城市相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: cityList,
      page: () => const CityListPage(),
      binding: CityListBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: cityDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return CityDetailPage(
          cityId: args['cityId'] ?? '',
          cityName: args['cityName'] ?? '',
          cityImages: (args['imageUrls'] as List?)?.whereType<String>().toList() ?? [],
          cityImage: args['cityImage'] ?? '',
          overallScore: args['overallScore'] ?? 0.0,
          reviewCount: args['reviewCount'] ?? 0,
        );
      },
      binding: CityDetailBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: citySearch,
      page: () => const CitySearchPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: cityChat,
      page: () => const CityChatPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: globalMap,
      page: () => const GlobalMapPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 活动相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: meetupsList,
      page: () => const MeetupListPage(),
      binding: MeetupListBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
      preventDuplicates: false,
    ),
    GetPage(
      name: meetupDetail,
      page: () {
        final args = Get.arguments;

        if (args is Meetup) {
          return MeetupDetailPage(meetup: args);
        }

        if (args is Map<String, dynamic>) {
          return MeetupDetailPage(meetupId: args['meetupId']?.toString());
        }

        return MeetupDetailPage(meetupId: args?.toString());
      },
      binding: MeetupDetailBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: createMeetup,
      page: () => const CreateMeetupPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: inviteToMeetup,
      page: () => InviteToMeetupPage(user: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: myMeetups,
      page: () => const MyMeetupsPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 共享办公相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: coworking,
      page: () => const CoworkingHomePage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
      preventDuplicates: false,
    ),
    GetPage(
      name: coworkingDetail,
      page: () => CoworkingDetailPage(space: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
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
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: hotelDetail,
      page: () => HotelDetailPage(hotelId: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: addHotel,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return AddHotelPage(
          cityId: args?['cityId'],
          cityName: args?['cityName'],
          countryName: args?['countryName'],
        );
      },
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 旅行计划相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: travelPlan,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return TravelPlanPage(
          planId: args['planId'], // 从数据库加载时传入
          cityId: args['cityId'],
          cityName: args['cityName'],
        );
      },
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: createTravelPlan,
      page: () => const AiPlannerMembershipGuard(child: CreateTravelPlanPage()),
      binding: CreateTravelPlanBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: aiPlannerTab,
      page: () => const AiPlannerMembershipGuard(
        child: BottomNavLayout(child: CreateTravelPlanPage(embeddedInBottomNav: true)),
      ),
      binding: CreateTravelPlanBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: travelHistory,
      page: () => const TravelHistoryPage(),
      binding: TravelHistoryBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    // 访问地点路由
    GetPage(
      name: TravelHistoryRoutes.visitedPlaces,
      page: () => const VisitedPlacesPage(),
      binding: VisitedPlacesBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 创新项目相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: innovation,
      page: () => const InnovationListPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: innovationDetail,
      page: () => InnovationDetailPage(project: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: addInnovation,
      page: () => const AddInnovationPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 用户相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: profile,
      page: () => const BottomNavLayout(child: ProfilePage()),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: profileEdit,
      page: () => const BottomNavLayout(child: ProfileEditPage()),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordPage(),
      binding: BindingsBuilder(() {
        BindingHelper.putFresh(() => ChangePasswordController());
      }),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: BindingsBuilder(() {
        BindingHelper.putFresh(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: userProfile,
      page: () => UserProfilePage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: memberDetail,
      page: () => MemberDetailPage(user: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: skillsInterests,
      page: () => const SkillsInterestsPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: editBasicInfo,
      page: () => EditBasicInfoPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: editSkills,
      page: () => EditSkillsPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: editInterests,
      page: () => EditInterestsPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: editSocialLinks,
      page: () => EditSocialLinksPage(accountId: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 会员相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: membershipPlan,
      page: () => const MembershipPlanPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 AI 和聊天相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: aiChat,
      page: () => const AiChatPage(),
      binding: AiChatBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: aiAssistantTab,
      page: () => const BottomNavLayout(child: AiChatPage(embeddedInBottomNav: true)),
      binding: AiChatBinding(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: directChat,
      page: () => TencentIMDirectChatPage(user: Get.arguments),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: conversations,
      page: () => const BottomNavLayout(child: ConversationListPage()),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
    GetPage(
      name: notifications,
      page: () => const BottomNavLayout(child: NotificationsPage()),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 社区相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: community,
      page: () => const CommunityPage(),
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),

    // ============================================================================
    // 🔒 管理员相关路由 - 需要认证
    // ============================================================================
    GetPage(
      name: moderatorApplicationDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ModeratorApplicationDetailPage(
          applicationId: args['applicationId'] ?? '',
        );
      },
      middlewares: [AuthMiddleware(), PageLifecycleMiddleware()],
    ),
  ];
}
