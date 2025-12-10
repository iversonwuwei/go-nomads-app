import 'dart:io';

import 'package:flutter/foundation.dart';

/// API 配置
class ApiConfig {
  // ============================================================
  // 环境配置
  // ============================================================
  static const bool kIsProduction = false;

  // ============================================================
  // 端口配置
  // ============================================================
  /// Gateway 端口 (所有服务统一通过 Gateway 访问)
  static const int gatewayPort = 5000;

  /// Message Service 端口 (SignalR Hub 需要直连)
  static const int messageServicePort = 5005;

  /// Coworking Service 端口 (SignalR Hub 需要直连)
  static const int coworkingServicePort = 5006;

  // ============================================================
  // 主机地址配置
  // ============================================================

  /// 生产环境主机
  static const String productionHost = 'api.yourapp.com';

  /// 真机测试主机 - 使用电脑局域网 IP
  /// 通过 ipconfig (Windows) 或 ifconfig (Mac/Linux) 查看
  /// ⚠️ 雷电模拟器也需要使用这个地址(雷电使用 VirtualBox 网络,10.0.2.2 无效)
  static const String physicalDeviceHost = '192.168.110.67';

  /// 开发环境主机 - 根据平台自动选择
  static String get developmentHost {
    if (kIsWeb) {
      return 'localhost';
    } else if (Platform.isAndroid) {
      // Android 模拟器使用特殊地址访问宿主机
      return '10.0.2.2';
    } else if (Platform.isIOS) {
      return '127.0.0.1';
    } else {
      // 其他平台（Desktop等）
      return 'localhost';
    }
  }

  // ============================================================
  // 模式切换
  // ============================================================

  /// 是否使用真机测试地址(手动切换)
  /// ⚠️ 雷电模拟器用户请设置为 true
  /// ⚠️ Android 官方模拟器用户请设置为 false
  static const bool usePhysicalDevice = true;

  // ============================================================
  // URL 组装
  // ============================================================

  /// 获取当前主机地址
  static String get currentHost {
    if (kIsProduction) {
      return productionHost;
    }
    if (usePhysicalDevice) {
      return physicalDeviceHost;
    }
    return developmentHost;
  }

  /// 生产环境基础 URL
  static String get productionUrl => 'https://$productionHost';

  /// 开发环境基础 URL
  static String get developmentUrl => 'http://$developmentHost:$gatewayPort';

  /// 真机测试基础 URL
  static String get physicalDeviceUrl => 'http://$physicalDeviceHost:$gatewayPort';

  /// 基础 URL - 智能选择
  static String get baseUrl {
    if (kIsProduction) {
      return productionUrl;
    }
    if (usePhysicalDevice) {
      return physicalDeviceUrl;
    }
    return developmentUrl;
  }

  /// Message Service 地址 (SignalR Hub 需要直连,不经过 Gateway)
  /// SignalR WebSocket 连接需要保持长连接,因此直连 MessageService
  static String get messageServiceBaseUrl {
    if (kIsProduction) {
      return productionUrl; // 生产环境通过专用域名
    }
    final host = usePhysicalDevice ? physicalDeviceHost : developmentHost;
    return 'http://$host:$messageServicePort';
  }

  /// Coworking Service 地址 (SignalR Hub 需要直连,不经过 Gateway)
  /// SignalR WebSocket 连接需要保持长连接,因此直连 CoworkingService
  static String get coworkingServiceBaseUrl {
    if (kIsProduction) {
      return productionUrl; // 生产环境通过专用域名
    }
    final host = usePhysicalDevice ? physicalDeviceHost : developmentHost;
    return 'http://$host:$coworkingServicePort';
  }

  // API 版本
  static const String apiVersion = '/api/v1';

  // 完整的 API 基础路径
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // 超时配置 (毫秒)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000; // 增加到60秒,因为城市列表需要获取天气数据
  static const int sendTimeout = 30000;

  // 认证相关
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // ============================================================
  // Authentication Endpoints - /api/v1/auth
  // ============================================================
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String changePasswordEndpoint = '/auth/change-password';

  // ============================================================
  // User Endpoints - /api/v1/users
  // ============================================================
  static const String usersEndpoint = '/users';
  static const String userDetailEndpoint = '/users/{id}';
  static const String userMeEndpoint = '/users/me';
  static const String userMeStatsEndpoint = '/users/me/stats';
  static const String userUpdateEndpoint = '/users/{id}';
  static const String userUpdateMeEndpoint = '/users/me';
  static const String userDeleteEndpoint = '/users/{id}';
  static const String userBatchEndpoint = '/users/batch';
  static String get userProfileEndpoint => userMeEndpoint;

  // 首页相关
  static const String homeDataEndpoint = '/home/data';
  static const String homeBannersEndpoint = '/home/banners';

  // ============================================================
  // City Endpoints - /api/v1/cities
  // ============================================================
  static const String citiesEndpoint = '/cities';
  static const String cityDetailEndpoint = '/cities/{id}';
  static const String cityRecommendedEndpoint = '/cities/recommended';
  static const String citySearchEndpoint = '/cities/search';
  static const String cityByCountryEndpoint = '/cities/by-country/{id}';
  static const String cityGroupedByCountryEndpoint = '/cities/grouped-by-country';
  static const String cityCountriesEndpoint = '/cities/countries';
  static const String cityStatisticsEndpoint = '/cities/{id}/statistics';
  static const String cityCreateEndpoint = '/cities';
  static const String cityUpdateEndpoint = '/cities/{id}';
  static const String cityDeleteEndpoint = '/cities/{id}';

  // ============================================================
  // City User Content Endpoints - /api/v1/cities/{id}/user-content/*
  // ============================================================

  // 照片相关
  static const String cityPhotosEndpoint = '/cities/{cityId}/user-content/photos';
  static const String cityPhotoBatchEndpoint = '/cities/{cityId}/user-content/photos/batch';
  static const String cityPhotoDetailEndpoint = '/cities/{cityId}/user-content/photos/{photoId}';
  static const String myPhotosEndpoint = '/user/city-content/photos';

  // 费用相关
  static const String cityExpensesEndpoint = '/cities/{cityId}/user-content/expenses';
  static const String cityExpenseDetailEndpoint = '/cities/{cityId}/user-content/expenses/{expenseId}';
  static const String myExpensesEndpoint = '/user/city-content/expenses';

  // 评论相关
  static const String cityReviewsEndpoint = '/cities/{cityId}/user-content/reviews';
  static const String myCityReviewEndpoint = '/cities/{cityId}/user-content/reviews/mine';

  // 统计相关
  static const String cityUserContentStatsEndpoint = '/cities/{cityId}/user-content/stats';

  // ============================================================
  // Cache Service Endpoints - /api/v1/cache (通过 Gateway 访问)
  // 注意: 这些端点通过 Gateway 转发到 CacheService
  // ============================================================

  // 评分缓存
  static const String cityScoreEndpoint = '/cache/scores/city/{cityId}';
  static const String cityScoreBatchEndpoint = '/cache/scores/city/batch';
  static const String coworkingScoreEndpoint = '/cache/scores/coworking/{coworkingId}';
  static const String coworkingScoreBatchEndpoint = '/cache/scores/coworking/batch';
  static const String invalidateCityScoreEndpoint = '/cache/scores/city/{cityId}';
  static const String invalidateCoworkingScoreEndpoint = '/cache/scores/coworking/{coworkingId}';

  // 费用缓存
  static const String cityCostEndpoint = '/cache/costs/city/{cityId}';
  static const String cityCostBatchEndpoint = '/cache/costs/city/batch';
  static const String invalidateCityCostEndpoint = '/cache/costs/city/{cityId}';

  // ============================================================
  // Product Endpoints - /api/v1/products
  // ============================================================
  static const String productsEndpoint = '/products';
  static const String productDetailEndpoint = '/products/{id}';
  static const String productCreateEndpoint = '/products';
  static const String productUpdateEndpoint = '/products/{id}';
  static const String productDeleteEndpoint = '/products/{id}';

  // ============================================================
  // Coworking Space Endpoints - /api/v1/coworking-spaces (待后端实现)
  // ============================================================
  static const String coworkingSpacesEndpoint = '/coworking-spaces';
  static const String coworkingDetailEndpoint = '/coworking-spaces/{id}';

  // ============================================================
  // Innovation Project Endpoints - /api/v1/innovation-projects (待后端实现)
  // ============================================================
  static const String innovationProjectsEndpoint = '/innovation-projects';
  static const String innovationDetailEndpoint = '/innovation-projects/{id}';

  // ============================================================
  // Event Endpoints - /api/v1/events
  // ============================================================
  static const String eventsEndpoint = '/events';
  static const String eventDetailEndpoint = '/events/{id}';
  static const String eventCreateEndpoint = '/events';
  static const String eventUpdateEndpoint = '/events/{id}';
  static const String eventDeleteEndpoint = '/events/{id}';
  static const String eventJoinEndpoint = '/events/{id}/join';
  static const String eventLeaveEndpoint = '/events/{id}/leave';
  static const String eventParticipantsEndpoint = '/events/{id}/participants';
  static const String eventFollowersEndpoint = '/events/{id}/followers';

  // ============================================================
  // Meetup Endpoints - /api/v1/meetups (待后端实现)
  // ============================================================
  static const String meetupsEndpoint = '/meetups';
  static const String meetupDetailEndpoint = '/meetups/{id}';
  static const String meetupJoinEndpoint = '/meetups/{id}/join';

  // ============================================================
  // Chat Endpoints - /api/v1/chats (待后端实现)
  // ============================================================
  static const String chatsEndpoint = '/chats';
  static const String chatDetailEndpoint = '/chats/{id}';
  static const String chatMessagesEndpoint = '/chats/{id}/messages';
  static const String chatSendMessageEndpoint = '/chats/{id}/messages';
  static const String chatParticipantsEndpoint = '/chats/{id}/participants';
  static const String chatMeetupEndpoint = '/chats/meetup';

  // ============================================================
  // Notification Endpoints - /api/v1/notifications
  // ============================================================
  static const String notificationsEndpoint = '/notifications';
  static const String notificationDetailEndpoint = '/notifications/{id}';
  static const String notificationUnreadCountEndpoint = '/notifications/unread/count';
  static const String notificationMarkReadEndpoint = '/notifications/{id}/read';
  static const String notificationMarkReadBatchEndpoint = '/notifications/read/batch';
  static const String notificationMarkAllReadEndpoint = '/notifications/read/all';
  static const String notificationDeleteEndpoint = '/notifications/{id}';
  static const String notificationSendEndpoint = '/notifications';
  static const String notificationSendToAdminsEndpoint = '/notifications/admins';

  // 环境判断
  static bool get isDevelopment => !kIsProduction;
  static bool get isProduction => kIsProduction;

  /// 运行时自定义基础 URL（用于特殊场景）
  ///
  /// 使用方式:
  /// ```dart
  /// ApiConfig.setCustomBaseUrl('http://192.168.1.200:5000');
  /// ```
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static void clearCustomBaseUrl() {
    _customBaseUrl = null;
  }

  static String get currentBaseUrl => _customBaseUrl ?? baseUrl;

  static String get currentApiBaseUrl => '$currentBaseUrl$apiVersion';

  // ============================================================
  // Helper Methods
  // ============================================================

  /// 构建完整的端点 URL
  ///
  /// 示例:
  /// ```dart
  /// final url = ApiConfig.buildUrl(ApiConfig.cityDetailEndpoint, {'id': '123'});
  /// // 结果: http://10.0.2.2:5000/api/v1/cities/123
  /// ```
  static String buildUrl(String endpoint, [Map<String, String>? params]) {
    var url = endpoint;

    // 替换路径参数 {id}, {chatId} 等
    if (params != null) {
      params.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }

    return '$currentApiBaseUrl$url';
  }

  /// 构建带查询参数的 URL
  ///
  /// 示例:
  /// ```dart
  /// final url = ApiConfig.buildUrlWithQuery(
  ///   ApiConfig.citiesEndpoint,
  ///   {'page': '1', 'pageSize': '10'}
  /// );
  /// // 结果: http://10.0.2.2:5000/api/v1/cities?page=1&pageSize=10
  /// ```
  static String buildUrlWithQuery(String endpoint, Map<String, String> queryParams) {
    final uri = Uri.parse('$currentApiBaseUrl$endpoint');
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }

  /// 获取当前配置信息（用于调试）
  static String getConfigInfo() {
    return '''
📡 API 配置信息:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌍 环境: ${kIsProduction ? '生产环境 🚀' : '开发环境 🔧'}
💻 平台: ${kIsWeb ? 'Web 🌐' : Platform.operatingSystem}
🏠 当前主机: $currentHost
🔌 Gateway 端口: $gatewayPort
📍 基础地址: $currentBaseUrl
🔗 API地址: $currentApiBaseUrl
📌 API版本: $apiVersion
📱 真机模式: ${usePhysicalDevice ? '✅ 是' : '❌ 否'}
🎯 自定义地址: ${_customBaseUrl ?? '未设置'}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}
