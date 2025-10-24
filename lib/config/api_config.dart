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
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS 模拟器可以使用 localhost
      return 'http://localhost:5000';
    } else {
      // 其他平台（Desktop等）使用 localhost
      return 'http://localhost:5000';
    }
  }

  // 真机测试地址 - 使用电脑局域网 IP
  // 通过 ipconfig (Windows) 或 ifconfig (Mac/Linux) 查看
  static const String physicalDeviceUrl = 'http://192.168.1.100:5000';

  // 是否使用真机测试地址（手动切换）
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
  static const String apiVersion = '/api';

  // 完整的 API 基础路径
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // 超时配置 (毫秒)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // 认证相关
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // API 端点
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // 首页相关
  static const String homeDataEndpoint = '/home/data';
  static const String homeBannersEndpoint = '/home/banners';

  // 用户相关
  static const String userProfileEndpoint = '/user/profile';
  static const String userUpdateEndpoint = '/user/update';

  // 城市相关
  static const String citiesEndpoint = '/cities';
  static const String cityDetailEndpoint = '/cities/{id}';

  // 共享空间相关
  static const String coworkingSpacesEndpoint = '/coworking-spaces';
  static const String coworkingDetailEndpoint = '/coworking-spaces/{id}';

  // 创意项目相关
  static const String innovationProjectsEndpoint = '/innovation-projects';
  static const String innovationDetailEndpoint = '/innovation-projects/{id}';

  // Meetup 相关
  static const String meetupsEndpoint = '/meetups';
  static const String meetupDetailEndpoint = '/meetups/{id}';
  static const String meetupJoinEndpoint = '/meetups/{id}/join';

  // Events 相关 (新的后端服务)
  static const String eventsEndpoint = '/api/v1/Events';
  static const String eventDetailEndpoint = '/api/v1/Events/{id}';
  static const String eventJoinEndpoint = '/api/v1/Events/{id}/join';

  // 聊天相关
  static const String chatsEndpoint = '/chats';
  static const String messagesEndpoint = '/chats/{chatId}/messages';
  static const String sendMessageEndpoint = '/chats/{chatId}/messages';

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

  /// 获取当前配置信息（用于调试）
  static String getConfigInfo() {
    return '''
配置信息:
- 环境: ${kIsProduction ? '生产' : '开发'}
- 平台: ${kIsWeb ? 'Web' : Platform.operatingSystem}
- 基础地址: $currentBaseUrl
- API地址: $currentApiBaseUrl
- 真机模式: ${usePhysicalDevice ? '是' : '否'}
- 自定义地址: ${_customBaseUrl ?? '未设置'}
''';
  }
}
