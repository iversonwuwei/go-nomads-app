// AI Domain
import 'dart:developer';

import 'package:df_admin_mobile/features/ai/application/use_cases/ai_use_cases.dart';
import 'package:df_admin_mobile/features/ai/domain/repositories/iai_repository.dart';
import 'package:df_admin_mobile/features/ai/infrastructure/repositories/ai_repository.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/auth/application/use_cases/auth_database_use_cases.dart' as auth_db_use_cases;
import 'package:df_admin_mobile/features/auth/application/use_cases/auth_use_cases.dart' as auth_use_cases;
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_database_repository.dart';
// Auth Domain
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_repository.dart';
import 'package:df_admin_mobile/features/auth/infrastructure/repositories/auth_database_repository.dart';
import 'package:df_admin_mobile/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:df_admin_mobile/features/auth/infrastructure/repositories/user_local_repository.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
// Chat Domain
import 'package:df_admin_mobile/features/chat/application/use_cases/chat_use_cases.dart';
import 'package:df_admin_mobile/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:df_admin_mobile/features/chat/infrastructure/repositories/chat_repository.dart';
import 'package:df_admin_mobile/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:df_admin_mobile/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
// City Domain
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/icity_rating_repository.dart';
import 'package:df_admin_mobile/features/city/domain/usecases/city_rating_usecases.dart';
import 'package:df_admin_mobile/features/city/infrastructure/repositories/city_rating_repository.dart';
import 'package:df_admin_mobile/features/city/infrastructure/repositories/city_repository.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
// Community Domain
import 'package:df_admin_mobile/features/community/domain/repositories/i_community_repository.dart';
import 'package:df_admin_mobile/features/community/infrastructure/repositories/community_repository.dart';
import 'package:df_admin_mobile/features/community/presentation/controllers/community_state_controller.dart';
import 'package:df_admin_mobile/features/coworking/application/use_cases/coworking_comment_use_cases.dart';
// Coworking Domain
import 'package:df_admin_mobile/features/coworking/application/use_cases/coworking_use_cases.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_comment_repository.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_repository.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/features/coworking/infrastructure/repositories/coworking_comment_repository.dart';
import 'package:df_admin_mobile/features/coworking/infrastructure/repositories/coworking_repository.dart';
import 'package:df_admin_mobile/features/coworking/infrastructure/repositories/coworking_review_repository.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
// Hotel Domain
import 'package:df_admin_mobile/features/hotel/application/use_cases/hotel_use_cases.dart';
import 'package:df_admin_mobile/features/hotel/domain/repositories/i_hotel_repository.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/features/hotel/presentation/controllers/hotel_state_controller.dart';
// InnovationProject Domain
import 'package:df_admin_mobile/features/innovation_project/application/use_cases/innovation_project_use_cases.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/repositories/i_innovation_project_repository.dart';
import 'package:df_admin_mobile/features/innovation_project/infrastructure/repositories/innovation_project_repository.dart';
import 'package:df_admin_mobile/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
// Interest Domain
import 'package:df_admin_mobile/features/interest/application/use_cases/interest_use_cases.dart';
import 'package:df_admin_mobile/features/interest/domain/repositories/i_interest_repository.dart';
import 'package:df_admin_mobile/features/interest/infrastructure/repositories/interest_repository.dart';
import 'package:df_admin_mobile/features/interest/presentation/controllers/interest_state_controller.dart';
// Location Domain
import 'package:df_admin_mobile/features/location/application/use_cases/get_cities_by_country_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_city_by_id_use_case.dart'
    as location_use_cases;
import 'package:df_admin_mobile/features/location/application/use_cases/get_countries_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/search_cities_use_case.dart'
    as location_search_use_cases;
import 'package:df_admin_mobile/features/location/domain/repositories/ilocation_repository.dart';
import 'package:df_admin_mobile/features/location/infrastructure/repositories/location_repository.dart';
import 'package:df_admin_mobile/features/location/presentation/controllers/location_state_controller.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/cancel_meetup_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/cancel_rsvp_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/create_meetup_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/get_meetups_by_city_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/get_meetups_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/rsvp_to_meetup_use_case.dart';
import 'package:df_admin_mobile/features/meetup/application/use_cases/update_meetup_use_case.dart';
// Meetup Domain
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/repositories/meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
// Moderator Domain
import 'package:df_admin_mobile/features/moderator/domain/repositories/i_moderator_application_repository.dart';
import 'package:df_admin_mobile/features/moderator/infrastructure/repositories/moderator_application_repository.dart';
import 'package:df_admin_mobile/features/moderator/presentation/controllers/moderator_application_controller.dart';
// Notification Domain
import 'package:df_admin_mobile/features/notification/domain/repositories/i_notification_repository.dart';
import 'package:df_admin_mobile/features/notification/infrastructure/repositories/notification_repository.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
// Skill Domain
import 'package:df_admin_mobile/features/skill/application/use_cases/skill_use_cases.dart';
import 'package:df_admin_mobile/features/skill/domain/repositories/i_skill_repository.dart';
import 'package:df_admin_mobile/features/skill/infrastructure/repositories/skill_repository.dart';
import 'package:df_admin_mobile/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:df_admin_mobile/features/user/application/use_cases/favorite_city_use_cases.dart';
import 'package:df_admin_mobile/features/user/application/use_cases/user_use_cases.dart' as user_use_cases;
// User Domain
import 'package:df_admin_mobile/features/user/domain/repositories/iuser_repository.dart';
import 'package:df_admin_mobile/features/user/infrastructure/repositories/user_repository.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
// User City Content Domain
import 'package:df_admin_mobile/features/user_city_content/application/use_cases/user_city_content_use_cases.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/features/user_city_content/infrastructure/repositories/user_city_content_repository.dart';
import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
// User Management Domain
import 'package:df_admin_mobile/features/user_management/domain/repositories/iuser_management_repository.dart';
import 'package:df_admin_mobile/features/user_management/infrastructure/repositories/user_management_repository.dart';
import 'package:df_admin_mobile/features/user_management/presentation/controllers/user_management_state_controller.dart';
import 'package:df_admin_mobile/features/weather/application/use_cases/get_city_weather_use_case.dart';
// Weather Domain
import 'package:df_admin_mobile/features/weather/domain/repositories/iweather_repository.dart';
import 'package:df_admin_mobile/features/weather/infrastructure/repositories/weather_repository.dart';
import 'package:df_admin_mobile/features/weather/presentation/controllers/weather_state_controller.dart';
// Services
import 'package:df_admin_mobile/services/database_service.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// DDD依赖注入配置
///
/// 使用GetX进行依赖管理
class DependencyInjection {
  /// 初始化所有依赖
  static Future<void> init() async {
    // 基础设施服务
    _registerInfrastructure();

    // 认证领域 (优先注册,其他领域可能依赖)
    _registerAuthDomain();

    // 用户领域
    _registerUserDomain();

    // 位置领域 (国家/城市数据)
    _registerLocationDomain();

    // 城市领域
    _registerCityDomain();

    // 天气领域
    _registerWeatherDomain();

    // 共享办公领域
    _registerCoworkingDomain();

    // 用户城市内容领域
    _registerUserCityContentDomain();

    // AI领域
    _registerAiDomain();

    // 社区领域
    _registerCommunityDomain();

    // 活动领域
    _registerMeetupDomain();

    // Chat 领域
    _registerChatDomain();

    // Notification 领域
    _registerNotificationDomain();

    // Interest 领域
    _registerInterestDomain();

    // Skill 领域
    _registerSkillDomain();

    // InnovationProject 领域
    _registerInnovationProjectDomain();

    // Hotel 领域
    _registerHotelDomain();

    // UserManagement 领域
    _registerUserManagementDomain();

    // Moderator 领域
    _registerModeratorDomain();

    // 其他领域...

    // ⚠️ 强制初始化全局 Controllers，防止路由切换时被删除
    _initializeGlobalControllers();
  }

  /// 强制初始化全局 Controllers
  /// 必须在所有依赖注册完成后调用
  static void _initializeGlobalControllers() {
    // 确保关键依赖已创建
    Get.find<HttpService>();
    Get.find<ICityRepository>();

    // 立即创建 Controller 实例，确保它们在整个应用生命周期中存活
    Get.find<CityStateController>();
    Get.find<MeetupStateController>();
    Get.find<UserStateController>();
    Get.find<SkillStateController>();
    Get.find<InterestStateController>();
    Get.find<ChatStateController>();
    Get.find<LocationStateController>(); // 添加 LocationStateController 初始化

    log('🚀 开始强制初始化 NotificationStateController');
    try {
      final notificationController = Get.find<NotificationStateController>();
      log('✅ NotificationStateController 初始化成功: $notificationController');
    } catch (e) {
      log('❌ NotificationStateController 初始化失败: $e');
      log('❌ 异常堆栈: ${StackTrace.current}');
    }

    // 确保常用的 UseCase 也被初始化（防止 lazyPut 延迟导致找不到）
    Get.find<GetCitiesWithCoworkingCountUseCase>();

    log('✅ 全局 Controllers 已强制初始化');
  }

  /// 注册基础设施服务
  static void _registerInfrastructure() {
    // Dio实例
    Get.lazyPut<Dio>(() => Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )));

    // TokenStorageService (如果还没注册)
    if (!Get.isRegistered<TokenStorageService>()) {
      Get.lazyPut<TokenStorageService>(() => TokenStorageService());
    }

    // HttpService (单例)
    if (!Get.isRegistered<HttpService>()) {
      Get.lazyPut<HttpService>(() => HttpService());
    }
  }

  /// 注册用户领域依赖
  static void _registerUserDomain() {
    // Repository
    Get.lazyPut<IUserRepository>(
      () => UserRepository(
        dio: Get.find<Dio>(),
        tokenService: Get.find<TokenStorageService>(),
      ),
    );

    // Use Cases - 基础用户操作
    Get.lazyPut<user_use_cases.BatchGetUsersUseCase>(
        () => user_use_cases.BatchGetUsersUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.GetUserUseCase>(() => user_use_cases.GetUserUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.GetUserProfileUseCase>(
        () => user_use_cases.GetUserProfileUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.UpdateUserUseCase>(() => user_use_cases.UpdateUserUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.SearchUsersUseCase>(
        () => user_use_cases.SearchUsersUseCase(Get.find<IUserRepository>()));

    // Use Cases - 收藏城市
    Get.lazyPut(() => AddFavoriteCityUseCase(Get.find<IUserRepository>()));
    Get.lazyPut(() => RemoveFavoriteCityUseCase(Get.find<IUserRepository>()));
    Get.lazyPut(() => IsCityFavoritedUseCase(Get.find<IUserRepository>()));
    Get.lazyPut(() => GetFavoriteCityIdsUseCase(Get.find<IUserRepository>()));
    Get.lazyPut(() => ToggleFavoriteCityUseCase(Get.find<IUserRepository>()));

    // Use Cases - 用户统计数据
    Get.lazyPut<user_use_cases.GetCurrentUserStatsUseCase>(
        () => user_use_cases.GetCurrentUserStatsUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.GetUserStatsUseCase>(
        () => user_use_cases.GetUserStatsUseCase(Get.find<IUserRepository>()));
    Get.lazyPut<user_use_cases.UpdateCurrentUserStatsUseCase>(
        () => user_use_cases.UpdateCurrentUserStatsUseCase(Get.find<IUserRepository>()));

    // Controller（fenix: true 允许删除后重新创建）
    Get.lazyPut(
      () => UserStateController(
        getCurrentUserUseCase: Get.find<user_use_cases.GetUserProfileUseCase>(),
        getUserUseCase: Get.find<user_use_cases.GetUserUseCase>(),
        updateUserUseCase: Get.find<user_use_cases.UpdateUserUseCase>(),
        addFavoriteCityUseCase: Get.find<AddFavoriteCityUseCase>(),
        removeFavoriteCityUseCase: Get.find<RemoveFavoriteCityUseCase>(),
        isCityFavoritedUseCase: Get.find<IsCityFavoritedUseCase>(),
        getFavoriteCityIdsUseCase: Get.find<GetFavoriteCityIdsUseCase>(),
        toggleFavoriteCityUseCase: Get.find<ToggleFavoriteCityUseCase>(),
        getCurrentUserStatsUseCase: Get.find<user_use_cases.GetCurrentUserStatsUseCase>(),
      ),
      fenix: true,
    );
  }

  /// 注册认证领域依赖
  static void _registerAuthDomain() {
    // DatabaseService (如果还没注册)
    if (!Get.isRegistered<DatabaseService>()) {
      Get.lazyPut<DatabaseService>(() => DatabaseService());
    }

    // UserLocalRepository - 协调 SharedPreferences 和 SQLite
    Get.lazyPut<UserLocalRepository>(
      () => UserLocalRepository(
        db: Get.find<DatabaseService>(),
        tokenStorage: Get.find<TokenStorageService>(),
      ),
    );

    // Repository - 基础认证
    Get.lazyPut<IAuthRepository>(
      () => AuthRepository(
        httpService: Get.find<HttpService>(),
        tokenStorage: Get.find<TokenStorageService>(),
        userLocalRepo: Get.find<UserLocalRepository>(),
      ),
    );

    // Repository - 数据库认证
    Get.lazyPut<IAuthDatabaseRepository>(
      () => AuthDatabaseRepository(),
    );

    // Use Cases - 基础认证
    Get.lazyPut(() => auth_use_cases.LoginUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => auth_use_cases.RegisterUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => auth_use_cases.LogoutUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => auth_use_cases.GetCurrentUserUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => auth_use_cases.UpdateUserProfileUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => auth_use_cases.AutoRefreshTokenUseCase(Get.find<IAuthRepository>()));

    // Use Cases - 数据库认证
    Get.lazyPut(() => auth_db_use_cases.SaveTokenToDatabaseUseCase(
          Get.find<IAuthDatabaseRepository>(),
        ));
    Get.lazyPut(() => auth_db_use_cases.CheckLoginStatusWithDatabaseUseCase(
          Get.find<IAuthDatabaseRepository>(),
          Get.find<IAuthRepository>(),
        ));

    // Controller
    Get.lazyPut(
      () => AuthStateController(
        loginUseCase: Get.find<auth_use_cases.LoginUseCase>(),
        registerUseCase: Get.find<auth_use_cases.RegisterUseCase>(),
        logoutUseCase: Get.find<auth_use_cases.LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<auth_use_cases.GetCurrentUserUseCase>(),
        updateUserProfileUseCase: Get.find<auth_use_cases.UpdateUserProfileUseCase>(),
        autoRefreshTokenUseCase: Get.find<auth_use_cases.AutoRefreshTokenUseCase>(),
        saveTokenToDatabaseUseCase: Get.find<auth_db_use_cases.SaveTokenToDatabaseUseCase>(),
        checkLoginStatusWithDatabaseUseCase: Get.find<auth_db_use_cases.CheckLoginStatusWithDatabaseUseCase>(),
      ),
    );
  }

  /// 注册位置领域依赖 (国家和城市数据)
  static void _registerLocationDomain() {
    // Repository
    Get.lazyPut<ILocationRepository>(
      () => LocationRepository(),
    );

    // Use Cases
    Get.lazyPut(() => GetCountriesUseCase(Get.find<ILocationRepository>()));
    Get.lazyPut(() => GetCitiesByCountryUseCase(Get.find<ILocationRepository>()));
    Get.lazyPut(() => location_use_cases.GetCityByIdUseCase(Get.find<ILocationRepository>()));
    Get.lazyPut(() => location_search_use_cases.SearchCitiesUseCase(Get.find<ILocationRepository>()));

    // Controller
    Get.lazyPut(
      () => LocationStateController(
        getCountriesUseCase: Get.find<GetCountriesUseCase>(),
        getCitiesByCountryUseCase: Get.find<GetCitiesByCountryUseCase>(),
        getCityByIdUseCase: Get.find<location_use_cases.GetCityByIdUseCase>(),
        searchCitiesUseCase: Get.find<location_search_use_cases.SearchCitiesUseCase>(),
      ),
    );
  }

  /// 注册城市领域依赖
  static void _registerCityDomain() {
    // Repository
    Get.lazyPut<ICityRepository>(
      () => CityRepository(Get.find<HttpService>()),
    );
    Get.lazyPut<ICityRatingRepository>(
      () => CityRatingRepository(),
    );

    // Use Cases
    Get.lazyPut(() => GetCitiesUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetCityByIdUseCase(Get.find<ICityRepository>()), tag: 'city_domain'); // 添加tag区分City domain
    Get.lazyPut(() => SearchCityListUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetRecommendedCitiesUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetPopularCitiesUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => FavoriteCityUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => UnfavoriteCityUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => ToggleCityFavoriteUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetFavoriteCitiesUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetUserFavoriteCityIdsUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetCityProsConsUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => GetCitiesWithCoworkingCountUseCase(Get.find<ICityRepository>()));
    Get.lazyPut(() => CityRatingUseCases(Get.find<ICityRatingRepository>()));

    // Controller（permanent: true 防止路由切换时被销毁）
    Get.lazyPut(
      () => CityStateController(
        getCitiesUseCase: Get.find<GetCitiesUseCase>(),
        searchCitiesUseCase: Get.find<SearchCityListUseCase>(),
        getRecommendedCitiesUseCase: Get.find<GetRecommendedCitiesUseCase>(),
        getPopularCitiesUseCase: Get.find<GetPopularCitiesUseCase>(),
        toggleCityFavoriteUseCase: Get.find<ToggleCityFavoriteUseCase>(),
        getFavoriteCitiesUseCase: Get.find<GetFavoriteCitiesUseCase>(),
        getUserFavoriteCityIdsUseCase: Get.find<GetUserFavoriteCityIdsUseCase>(),
        cityRepository: Get.find<ICityRepository>(),
      ),
      fenix: true, // 允许在删除后重新创建
    );

    // Detail Controller
    Get.lazyPut(
      () => CityDetailStateController(
        getCityByIdUseCase: Get.find<GetCityByIdUseCase>(tag: 'city_domain'), // 使用tag获取City domain的UseCase
        toggleCityFavoriteUseCase: Get.find<ToggleCityFavoriteUseCase>(),
      ),
    );

    // ProsCons Controller
    Get.lazyPut(
      () => ProsConsStateController(
        Get.find<ICityRepository>(),
      ),
    );

    // City Rating Controller
    Get.lazyPut(
      () => CityRatingController(Get.find<CityRatingUseCases>()),
    );
  }

  /// 注册天气领域依赖
  static void _registerWeatherDomain() {
    // Repository
    Get.lazyPut<IWeatherRepository>(
      () => WeatherRepository(Get.find<ICityRepository>()),
    );

    // Use Cases
    Get.lazyPut(() => GetCityWeatherUseCase(Get.find<IWeatherRepository>()));

    // Controller
    Get.lazyPut(
      () => WeatherStateController(
        getCityWeatherUseCase: Get.find<GetCityWeatherUseCase>(),
      ),
    );
  }

  /// 注册共享办公领域依赖
  static void _registerCoworkingDomain() {
    // Repository
    Get.lazyPut<ICoworkingRepository>(
      () => CoworkingRepository(),
    );

    Get.lazyPut<ICoworkingCommentRepository>(
      () => CoworkingCommentRepository(),
    );

    Get.lazyPut<ICoworkingReviewRepository>(
      () => CoworkingReviewRepository(),
    );

    // Use Cases - 查询类
    Get.lazyPut(() => GetCoworkingSpacesByCityUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => GetCoworkingByIdUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => GetCityCoworkingCountUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => GetCoworkingSpacesUseCase(
          Get.find<ICoworkingRepository>(),
        ));

    // Use Cases - 命令类
    Get.lazyPut(() => CreateCoworkingUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => UpdateCoworkingUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => DeleteCoworkingUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => SubmitCoworkingVerificationUseCase(
          Get.find<ICoworkingRepository>(),
        ));
    Get.lazyPut(() => CheckVerificationEligibilityUseCase(
          Get.find<ICoworkingRepository>(),
        ));

    // Use Cases - 评论
    Get.lazyPut(() => CoworkingCommentUseCases(
          Get.find<ICoworkingCommentRepository>(),
        ));

    // Controller
    Get.lazyPut(
      () => CoworkingStateController(
        getCoworkingSpacesByCityUseCase: Get.find<GetCoworkingSpacesByCityUseCase>(),
        getCoworkingByIdUseCase: Get.find<GetCoworkingByIdUseCase>(),
        getCityCoworkingCountUseCase: Get.find<GetCityCoworkingCountUseCase>(),
        submitCoworkingVerificationUseCase: Get.find<SubmitCoworkingVerificationUseCase>(),
        checkVerificationEligibilityUseCase: Get.find<CheckVerificationEligibilityUseCase>(),
      ),
      fenix: true, // 允许在删除后重新创建,防止路由切换导致的状态丢失
    );
  }

  /// 注册用户城市内容领域依赖
  static void _registerUserCityContentDomain() {
    // Repository
    Get.lazyPut<IUserCityContentRepository>(
      () => UserCityContentRepository(),
    );

    // Use Cases - Photo
    Get.lazyPut(() => AddCityPhotoUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => SubmitCityPhotosUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetCityPhotosUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => DeleteCityPhotoUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetMyPhotosUseCase(
          Get.find<IUserCityContentRepository>(),
        ));

    // Use Cases - Expense
    Get.lazyPut(() => AddCityExpenseUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetCityExpensesUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => DeleteCityExpenseUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetMyExpensesUseCase(
          Get.find<IUserCityContentRepository>(),
        ));

    // Use Cases - Review
    Get.lazyPut(() => UpsertCityReviewUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetCityReviewsUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetMyCityReviewUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => DeleteMyCityReviewUseCase(
          Get.find<IUserCityContentRepository>(),
        ));

    // Use Cases - Statistics
    Get.lazyPut(() => GetCityStatsUseCase(
          Get.find<IUserCityContentRepository>(),
        ));
    Get.lazyPut(() => GetCityCostSummaryUseCase(
          Get.find<IUserCityContentRepository>(),
        ));

    // Controller
    Get.lazyPut(
      () => UserCityContentStateController(
        addCityPhotoUseCase: Get.find<AddCityPhotoUseCase>(),
        submitCityPhotosUseCase: Get.find<SubmitCityPhotosUseCase>(),
        getCityPhotosUseCase: Get.find<GetCityPhotosUseCase>(),
        deleteCityPhotoUseCase: Get.find<DeleteCityPhotoUseCase>(),
        getMyPhotosUseCase: Get.find<GetMyPhotosUseCase>(),
        batchGetUsersUseCase: Get.find<user_use_cases.BatchGetUsersUseCase>(),
        addCityExpenseUseCase: Get.find<AddCityExpenseUseCase>(),
        getCityExpensesUseCase: Get.find<GetCityExpensesUseCase>(),
        deleteCityExpenseUseCase: Get.find<DeleteCityExpenseUseCase>(),
        getMyExpensesUseCase: Get.find<GetMyExpensesUseCase>(),
        upsertCityReviewUseCase: Get.find<UpsertCityReviewUseCase>(),
        getCityReviewsUseCase: Get.find<GetCityReviewsUseCase>(),
        getMyCityReviewUseCase: Get.find<GetMyCityReviewUseCase>(),
        deleteMyCityReviewUseCase: Get.find<DeleteMyCityReviewUseCase>(),
        getCityStatsUseCase: Get.find<GetCityStatsUseCase>(),
        getCityCostSummaryUseCase: Get.find<GetCityCostSummaryUseCase>(),
      ),
    );
  }

  /// 注册AI领域依赖
  static void _registerAiDomain() {
    // Repository
    Get.lazyPut<IAiRepository>(
      () => AiRepository(),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GenerateTravelPlanUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GenerateTravelPlanStreamUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GetTravelPlanByIdUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GetDigitalNomadGuideUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GenerateDigitalNomadGuideStreamUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GetUserTravelPlansUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => GetTravelPlanDetailUseCase(
        Get.find<IAiRepository>(),
      ),
      fenix: true,
    );

    // Controller
    Get.lazyPut(
      () => AiStateController(
        Get.find<GenerateTravelPlanUseCase>(),
        Get.find<GenerateTravelPlanStreamUseCase>(),
        Get.find<GetTravelPlanByIdUseCase>(),
        Get.find<GenerateDigitalNomadGuideStreamUseCase>(),
        Get.find<GetDigitalNomadGuideUseCase>(),
        Get.find<GetUserTravelPlansUseCase>(),
        Get.find<GetTravelPlanDetailUseCase>(),
      ),
      fenix: true, // 确保控制器在被销毁后可以重新创建
    );
  }

  /// 注册社区领域依赖
  static void _registerCommunityDomain() {
    // Repository
    Get.lazyPut<ICommunityRepository>(
      () => CommunityRepository(),
    );

    // Controller
    Get.lazyPut(
      () => CommunityStateController(
        repository: Get.find<ICommunityRepository>(),
      ),
    );
  }

  /// 注册活动领域依赖
  static void _registerMeetupDomain() {
    // Repository
    Get.lazyPut<IMeetupRepository>(
      () => MeetupRepository(),
    );

    // Use Cases
    Get.lazyPut(() => GetMeetupsUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => GetMeetupsByCityUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => CreateMeetupUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => RsvpToMeetupUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => CancelRsvpUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => CancelMeetupUseCase(Get.find<IMeetupRepository>()));
    Get.lazyPut(() => UpdateMeetupUseCase(Get.find<IMeetupRepository>()));

    // Controller（fenix: true 允许删除后重新创建）
    Get.lazyPut(
      () => MeetupStateController(
        getMeetupsUseCase: Get.find<GetMeetupsUseCase>(),
        getMeetupsByCityUseCase: Get.find<GetMeetupsByCityUseCase>(),
        createMeetupUseCase: Get.find<CreateMeetupUseCase>(),
        updateMeetupUseCase: Get.find<UpdateMeetupUseCase>(),
        rsvpToMeetupUseCase: Get.find<RsvpToMeetupUseCase>(),
        cancelRsvpUseCase: Get.find<CancelRsvpUseCase>(),
        cancelMeetupUseCase: Get.find<CancelMeetupUseCase>(),
      ),
      fenix: true,
    );
  }

  /// 注册Chat领域依赖
  static void _registerChatDomain() {
    // Repository
    Get.lazyPut<IChatRepository>(
      () => ChatRepository(Get.find<HttpService>()),
    );

    // Use Cases - 聊天室管理
    Get.lazyPut(() => GetChatRoomsUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => GetChatRoomByIdUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => JoinChatRoomUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => LeaveChatRoomUseCase(Get.find<IChatRepository>()));

    // Use Cases - 消息管理
    Get.lazyPut(() => GetMessagesUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => SendMessageUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => DeleteMessageUseCase(Get.find<IChatRepository>()));

    // Use Cases - 用户管理
    Get.lazyPut(() => GetOnlineUsersUseCase(Get.find<IChatRepository>()));
    Get.lazyPut(() => GetRoomMembersUseCase(Get.find<IChatRepository>()));

    // Controller
    Get.lazyPut(
      () => ChatStateController(
        Get.find<GetChatRoomsUseCase>(),
        Get.find<GetChatRoomByIdUseCase>(),
        Get.find<JoinChatRoomUseCase>(),
        Get.find<LeaveChatRoomUseCase>(),
        Get.find<GetMessagesUseCase>(),
        Get.find<SendMessageUseCase>(),
        Get.find<DeleteMessageUseCase>(),
        Get.find<GetOnlineUsersUseCase>(),
        Get.find<GetRoomMembersUseCase>(),
      ),
    );
  }

  /// 注册Notification领域依赖
  static void _registerNotificationDomain() {
    log('📦 开始注册 Notification 领域依赖');

    // Repository
    Get.lazyPut<INotificationRepository>(
      () {
        log('📦 创建 NotificationRepository 实例');
        return NotificationRepository(Get.find<HttpService>());
      },
    );

    // Controller（fenix: true 允许删除后重新创建）
    Get.lazyPut(
      () {
        log('📦 创建 NotificationStateController 实例');
        return NotificationStateController(Get.find<INotificationRepository>());
      },
      fenix: true,
    );

    log('✅ Notification 领域依赖注册完成');
  }

  /// 注册Interest领域依赖
  static void _registerInterestDomain() {
    // Repository
    Get.lazyPut<IInterestRepository>(
      () => InterestRepository(Get.find<HttpService>()),
    );

    // Use Cases
    Get.lazyPut(() => GetInterestsUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => GetInterestsByCategoryUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => GetUserInterestsUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => AddUserInterestUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => UpdateUserInterestIntensityUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => RemoveUserInterestUseCase(Get.find<IInterestRepository>()));
    Get.lazyPut(() => SearchInterestsUseCase(Get.find<IInterestRepository>()));

    // Controller
    Get.lazyPut(
      () => InterestStateController(
        getInterestsUseCase: Get.find<GetInterestsUseCase>(),
        getInterestsByCategoryUseCase: Get.find<GetInterestsByCategoryUseCase>(),
        getUserInterestsUseCase: Get.find<GetUserInterestsUseCase>(),
        addUserInterestUseCase: Get.find<AddUserInterestUseCase>(),
        updateUserInterestIntensityUseCase: Get.find<UpdateUserInterestIntensityUseCase>(),
        removeUserInterestUseCase: Get.find<RemoveUserInterestUseCase>(),
        searchInterestsUseCase: Get.find<SearchInterestsUseCase>(),
      ),
    );
  }

  /// 注册Skill领域依赖
  static void _registerSkillDomain() {
    // Repository
    Get.lazyPut<ISkillRepository>(
      () => SkillRepository(Get.find<HttpService>()),
    );

    // Use Cases
    Get.lazyPut(() => GetSkillsUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => GetSkillsByCategoryUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => GetUserSkillsUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => AddUserSkillUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => UpdateUserSkillProficiencyUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => RemoveUserSkillUseCase(Get.find<ISkillRepository>()));
    Get.lazyPut(() => SearchSkillsUseCase(Get.find<ISkillRepository>()));

    // Controller
    Get.lazyPut(
      () => SkillStateController(
        getSkillsUseCase: Get.find<GetSkillsUseCase>(),
        getSkillsByCategoryUseCase: Get.find<GetSkillsByCategoryUseCase>(),
        getUserSkillsUseCase: Get.find<GetUserSkillsUseCase>(),
        addUserSkillUseCase: Get.find<AddUserSkillUseCase>(),
        updateUserSkillProficiencyUseCase: Get.find<UpdateUserSkillProficiencyUseCase>(),
        removeUserSkillUseCase: Get.find<RemoveUserSkillUseCase>(),
        searchSkillsUseCase: Get.find<SearchSkillsUseCase>(),
      ),
    );
  }

  /// 注册InnovationProject领域依赖
  static void _registerInnovationProjectDomain() {
    // Repository
    Get.lazyPut<IInnovationProjectRepository>(
      () => InnovationProjectRepository(Get.find<HttpService>()),
    );

    // Use Cases
    Get.lazyPut(() => GetProjectsUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => GetProjectByIdUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => CreateProjectUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => UpdateProjectUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => DeleteProjectUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => GetProjectsByUserUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => SearchProjectsUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => GetTeamMembersUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => AddTeamMemberUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => RemoveTeamMemberUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => ToggleLikeUseCase(Get.find<IInnovationProjectRepository>()));
    Get.lazyPut(() => GetPopularProjectsUseCase(Get.find<IInnovationProjectRepository>()));

    // Controller
    Get.lazyPut(
      () => InnovationProjectStateController(
        getProjectsUseCase: Get.find<GetProjectsUseCase>(),
        getProjectByIdUseCase: Get.find<GetProjectByIdUseCase>(),
        createProjectUseCase: Get.find<CreateProjectUseCase>(),
        updateProjectUseCase: Get.find<UpdateProjectUseCase>(),
        deleteProjectUseCase: Get.find<DeleteProjectUseCase>(),
        getProjectsByUserUseCase: Get.find<GetProjectsByUserUseCase>(),
        searchProjectsUseCase: Get.find<SearchProjectsUseCase>(),
        getTeamMembersUseCase: Get.find<GetTeamMembersUseCase>(),
        addTeamMemberUseCase: Get.find<AddTeamMemberUseCase>(),
        removeTeamMemberUseCase: Get.find<RemoveTeamMemberUseCase>(),
        toggleLikeUseCase: Get.find<ToggleLikeUseCase>(),
        getPopularProjectsUseCase: Get.find<GetPopularProjectsUseCase>(),
      ),
    );
  }

  static void _registerHotelDomain() {
    // Repository
    Get.lazyPut<IHotelRepository>(
      () => HotelRepository(Get.find<HttpService>()),
    );

    // Use Cases
    Get.lazyPut(() => GetHotelsUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetHotelByIdUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetHotelsByCityUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => SearchHotelsUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => CreateHotelUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => UpdateHotelUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => DeleteHotelUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetFeaturedHotelsUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetHotelsByCategoryUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetRoomTypesUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => CreateBookingUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => GetUserBookingsUseCase(Get.find<IHotelRepository>()));
    Get.lazyPut(() => CancelBookingUseCase(Get.find<IHotelRepository>()));

    // Controller
    Get.lazyPut(
      () => HotelStateController(
        getHotelsUseCase: Get.find<GetHotelsUseCase>(),
        getHotelByIdUseCase: Get.find<GetHotelByIdUseCase>(),
        getHotelsByCityUseCase: Get.find<GetHotelsByCityUseCase>(),
        searchHotelsUseCase: Get.find<SearchHotelsUseCase>(),
        createHotelUseCase: Get.find<CreateHotelUseCase>(),
        updateHotelUseCase: Get.find<UpdateHotelUseCase>(),
        deleteHotelUseCase: Get.find<DeleteHotelUseCase>(),
        getFeaturedHotelsUseCase: Get.find<GetFeaturedHotelsUseCase>(),
        getHotelsByCategoryUseCase: Get.find<GetHotelsByCategoryUseCase>(),
        getRoomTypesUseCase: Get.find<GetRoomTypesUseCase>(),
        createBookingUseCase: Get.find<CreateBookingUseCase>(),
        getUserBookingsUseCase: Get.find<GetUserBookingsUseCase>(),
        cancelBookingUseCase: Get.find<CancelBookingUseCase>(),
      ),
    );
  }

  /// 注册用户管理领域依赖
  static void _registerUserManagementDomain() {
    // Repository - 使用 put 立即初始化,避免在页面中找不到
    Get.put<IUserManagementRepository>(
      UserManagementRepository(Get.find<HttpService>()),
      permanent: true,
    );

    // Controller
    Get.lazyPut(
      () => UserManagementStateController(Get.find<IUserManagementRepository>()),
    );
  }

  /// 注册版主申请领域依赖
  static void _registerModeratorDomain() {
    // Repository
    Get.lazyPut<IModeratorApplicationRepository>(
      () => ModeratorApplicationRepository(),
    );

    // Controller
    Get.lazyPut(
      () => ModeratorApplicationController(Get.find<IModeratorApplicationRepository>()),
    );
  }
}
