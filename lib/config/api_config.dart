import 'dart:io';

import 'package:flutter/foundation.dart';

/// API 配置
class ApiConfig {
  // 环境配置
  static const bool kIsProduction = false;

  // 生产环境地址
  static const String productionUrl = 'https://api.yourapp.com';

  // 开发环境地址 - 根据平台自动选择
  static String get developmentUrl {
    if (kIsWeb) {
      // Web 环境使用 localhost
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Android 模拟器使用特殊地址 10.0.2.2
      // 雷电/Android 模拟器应该通过 10.0.2.2 访问宿主机映射端口
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS 模拟器可以使用 localhost
      return 'http://127.0.0.1:5000';
    } else {
      // 其他平台（Desktop等）使用 localhost
      return 'http://localhost:5000';
    }
  }

  // 真机测试地址 - 使用电脑局域网 IP
  // 通过 ipconfig (Windows) 或 ifconfig (Mac/Linux) 查看
  // ⚠️ 雷电模拟器也需要使用这个地址(雷电使用 VirtualBox 网络,10.0.2.2 无效)
  static const String physicalDeviceUrl = 'http://192.168.110.54:5000';

  // 是否使用真机测试地址(手动切换)
  // ⚠️ 雷电模拟器用户请设置为 true
  static const bool usePhysicalDevice = false;

  // 基础 URL - 智能选择
  static String get baseUrl {
    if (kIsProduction) {
      return productionUrl;
    }

    // 开发模式
    if (usePhysicalDevice) {
      return physicalDeviceUrl;
    }

    return developmentUrl;
  }

  // API 版本
  static const String apiVersion = '/api/v1';

  // 完整的 API 基础路径
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // 超时配置 (毫秒)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

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
  static const String userUpdateEndpoint = '/users/{id}';
  static const String userUpdateMeEndpoint = '/users/me';
  static const String userDeleteEndpoint = '/users/{id}';
  static const String userBatchEndpoint = '/users/batch';
  static String get userProfileEndpoint => userMeEndpoint;

  // 首页相关
  static const String homeDataEndpoint = '/home/data';
  static const String homeBannersEndpoint = '/home/banners';
  static const String homeFeedEndpoint = '/home/feed';

  // ============================================================
  // City Endpoints - /api/v1/cities
  // ============================================================
  static const String citiesEndpoint = '/cities';
  static const String cityDetailEndpoint = '/cities/{id}';
  static const String cityRecommendedEndpoint = '/cities/recommended';
  static const String citySearchEndpoint = '/cities/search';
  static const String cityByCountryEndpoint = '/cities/by-country/{id}';
  static const String cityGroupedByCountryEndpoint =
      '/cities/grouped-by-country';
  static const String cityCountriesEndpoint = '/cities/countries';
  static const String cityStatisticsEndpoint = '/cities/{id}/statistics';
  static const String cityCreateEndpoint = '/cities';
  static const String cityUpdateEndpoint = '/cities/{id}';
  static const String cityDeleteEndpoint = '/cities/{id}';

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
  static String buildUrlWithQuery(
      String endpoint, Map<String, String> queryParams) {
    final uri = Uri.parse('$currentApiBaseUrl$endpoint');
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }

  /// 获取当前配置信息（用于调试）
  static String getConfigInfo() {
    return '''
配置信息:
- 环境: ${kIsProduction ? '生产' : '开发'}
- 平台: ${kIsWeb ? 'Web' : Platform.operatingSystem}
- 基础地址: $currentBaseUrl
- API地址: $currentApiBaseUrl
- API版本: $apiVersion
- 真机模式: ${usePhysicalDevice ? '是' : '否'}
- 自定义地址: ${_customBaseUrl ?? '未设置'}
''';
  }
}
