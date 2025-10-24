/// API 配置
class ApiConfig {
  // 基础 URL - 开发环境使用 localhost
  static const String baseUrl = 'http://localhost:5000';
  
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
  static bool get isDevelopment => baseUrl.contains('localhost');
  static bool get isProduction => !isDevelopment;
  
  /// 根据环境设置基础 URL
  /// 
  /// 使用方式:
  /// - 开发环境: ApiConfig.setBaseUrl('http://localhost:8080');
  /// - 生产环境: ApiConfig.setBaseUrl('https://api.yourdomain.com');
  static String _customBaseUrl = '';
  
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }
  
  static String get currentBaseUrl => 
      _customBaseUrl.isNotEmpty ? _customBaseUrl : baseUrl;
  
  static String get currentApiBaseUrl => 
      '${currentBaseUrl}$apiVersion';
}
