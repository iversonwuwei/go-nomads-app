import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'database/token_dao.dart';
import 'http_service.dart';

/// Events API 服务
/// 专门处理与后端 Events 服务的 API 交互
class EventsApiService {
  static final EventsApiService _instance = EventsApiService._internal();
  factory EventsApiService() => _instance;

  final HttpService _httpService = HttpService();
  final TokenDao _tokenDao = TokenDao();

  EventsApiService._internal();

  /// 确保认证头已设置
  /// 注意: AuthStateController 已在登录时自动设置 HttpService.authToken
  /// 此方法主要用于检查认证状态
  Future<void> _ensureAuthentication() async {
    try {
      // 检查 HttpService 是否有 token
      if (_httpService.authToken == null || _httpService.authToken!.isEmpty) {
        throw Exception('用户未登录，请先登录');
      }
    } catch (e) {
      print('❌ 认证检查失败: $e');
      rethrow;
    }
  }

  /// 获取当前用户ID
  /// 从数据库中的token数据获取用户ID，用于设置X-User-Id头
  Future<String?> _getCurrentUserId() async {
    try {
      final tokenData = await _tokenDao.getLatestToken();
      return tokenData?['user_id'] as String?;
    } catch (e) {
      print('❌ 获取用户ID失败: $e');
      return null;
    }
  }

  /// 获取认证头
  /// 返回包含Authorization和X-User-Id的头部信息
  Future<Map<String, String>> _getAuthHeaders() async {
    await _ensureAuthentication();

    final headers = <String, String>{};

    // 添加Authorization头
    if (_httpService.authToken != null && _httpService.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_httpService.authToken}';
    }

    // 添加X-User-Id头 (EventService需要这个来识别用户)
    final userId = await _getCurrentUserId();
    if (userId != null && userId.isNotEmpty) {
      headers['X-User-Id'] = userId;
    }

    return headers;
  }

  /// 尝试获取认证头(不强制要求登录)
  /// 如果用户已登录则返回认证头,未登录则返回 null
  Future<Map<String, String>?> _tryGetAuthHeaders() async {
    try {
      // 检查 HttpService 是否有 token
      if (_httpService.authToken == null || _httpService.authToken!.isEmpty) {
        return null;
      }

      final headers = <String, String>{};

      // 添加Authorization头
      headers['Authorization'] = 'Bearer ${_httpService.authToken}';

      // 添加X-User-Id头
      final userId = await _getCurrentUserId();
      if (userId != null && userId.isNotEmpty) {
        headers['X-User-Id'] = userId;
      }

      return headers.isNotEmpty ? headers : null;
    } catch (e) {
      print('ℹ️ 获取认证头失败,以访客身份继续: $e');
      return null;
    }
  }

  /// 创建活动/聚会
  ///
  /// [eventData] 活动数据，包含以下字段：
  /// - title: 标题
  /// - description: 描述 (可选)
  /// - cityId: 城市ID (可选)
  /// - location: 地点 (可选)
  /// - address: 地址 (可选)
  /// - imageUrl: 图片URL (可选)
  /// - images: 图片数组 (可选)
  /// - category: 分类 (可选)
  /// - startTime: 开始时间
  /// - endTime: 结束时间 (可选)
  /// - maxParticipants: 最大参与人数 (可选)
  /// - locationType: 地点类型
  /// - meetingLink: 会议链接 (可选)
  /// - latitude: 纬度 (可选)
  /// - longitude: 经度 (可选)
  /// - tags: 标签数组 (可选)
  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final response = await _httpService.post<Map<String, dynamic>>(
        ApiConfig.eventsEndpoint,
        data: eventData,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to create event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  /// 获取活动详情
  Future<Map<String, dynamic>> getEvent(String eventId) async {
    try {
      // 获取认证头(可选,但用于判断参与状态)
      final authHeaders = await _tryGetAuthHeaders();

      final endpoint =
          ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId);
      final response = await _httpService.get<Map<String, dynamic>>(
        endpoint,
        options: authHeaders != null ? Options(headers: authHeaders) : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        // HttpService 拦截器已经自动解包了 ApiResponse
        // response.data 现在直接是事件数据,而不是 {success, message, data} 包装
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get event: ${e.toString()}');
    }
  }

  /// 获取活动列表
  ///
  /// [requireAuth] 是否需要认证,默认 false,允许未登录用户查看活动列表
  Future<Map<String, dynamic>> getEvents({
    String? cityId,
    String? category,
    String? status = 'upcoming',
    int page = 1,
    int pageSize = 20,
    bool requireAuth = false,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (cityId != null) queryParameters['cityId'] = cityId;
      if (category != null) queryParameters['category'] = category;
      if (status != null) queryParameters['status'] = status;

      // 如果需要认证,获取认证头
      Options? requestOptions;
      if (requireAuth) {
        // 强制要求认证
        final authHeaders = await _getAuthHeaders();
        requestOptions = Options(headers: authHeaders);
      } else {
        // 可选认证:如果已登录则添加认证头,未登录则以访客身份访问
        final authHeaders = await _tryGetAuthHeaders();
        if (authHeaders != null) {
          requestOptions = Options(headers: authHeaders);
          print('✅ 已登录,使用认证头获取活动列表');
        } else {
          print('ℹ️ 未登录,以访客身份获取活动列表');
        }
      }

      final response = await _httpService.get<Map<String, dynamic>>(
        ApiConfig.eventsEndpoint,
        queryParameters: queryParameters,
        options: requestOptions,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to get events: Invalid response');
      }
    } catch (e) {
      print('❌ 获取活动列表失败: $e');
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get events: ${e.toString()}');
    }
  }

  /// 更新活动
  Future<Map<String, dynamic>> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint =
          ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId);
      final response = await _httpService.put<Map<String, dynamic>>(
        endpoint,
        data: eventData,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to update event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }

  /// 参加活动
  Future<bool> joinEvent(String eventId) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint = ApiConfig.eventJoinEndpoint.replaceAll('{id}', eventId);
      final response = await _httpService.post<dynamic>(
        endpoint,
        data: {}, // 发送空的 JSON 对象作为 request body
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200) {
        // 响应拦截器已经提取了 data 字段,所以 response.data 就是 data 的值
        // 后端返回的 data 字段是 ParticipantResponse 对象
        return true;
      } else {
        throw Exception('Failed to join event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to join event: ${e.toString()}');
    }
  }

  /// 取消参加活动
  Future<bool> leaveEvent(String eventId) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint = ApiConfig.eventJoinEndpoint.replaceAll('{id}', eventId);
      final response = await _httpService.delete<dynamic>(
        endpoint,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200) {
        // 响应拦截器已经提取了 data 字段,所以 response.data 就是 data 的值
        // 后端返回的 data 字段是 bool 类型
        return response.data == true || response.data is bool;
      } else {
        throw Exception('Failed to leave event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to leave event: ${e.toString()}');
    }
  }

  /// 获取参与者列表
  Future<List<Map<String, dynamic>>> getEventParticipants(
      String eventId) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint =
          '${ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId)}/participants';
      final response = await _httpService.get<Map<String, dynamic>>(
        endpoint,
        options: Options(headers: authHeaders),
      );

      print(
          '🔍 getEventParticipants response.data 类型: ${response.data.runtimeType}');

      // HttpService 自动解包 ApiResponse,response.data 已经是 data 数组
      // 后端返回: {success: true, data: [...]}
      // 拦截器解包后: response.data = [...] (直接是数组)
      if (response.statusCode == 200 && response.data is List) {
        final participants =
            List<Map<String, dynamic>>.from(response.data as List);
        print('✅ 成功解析参与者列表 (List 类型): ${participants.length} 个');
        return participants;
      }

      // 如果 response.data 是 Map (没有被解包的情况)
      if (response.data is Map<String, dynamic>) {
        print('⚠️ response.data 是 Map 类型,尝试提取 data 字段');
        final mapData = response.data as Map<String, dynamic>;
        final data = mapData['data'];
        if (data is List) {
          final participants = List<Map<String, dynamic>>.from(data);
          print('✅ 成功解析参与者列表 (Map.data 类型): ${participants.length} 个');
          return participants;
        }
      }

      print('❌ 无法解析参与者列表,response.data 类型不匹配');
      return [];
    } catch (e) {
      print('❌ 获取参与者列表失败: $e');
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get event participants: ${e.toString()}');
    }
  }

  /// 关注活动
  Future<Map<String, dynamic>> followEvent(String eventId) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint =
          '${ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId)}/follow';
      final response = await _httpService.post<Map<String, dynamic>>(
        endpoint,
        data: {'notificationEnabled': true}, // 默认开启通知
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to follow event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to follow event: ${e.toString()}');
    }
  }

  /// 取消关注活动
  Future<Map<String, dynamic>> unfollowEvent(String eventId) async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final endpoint =
          '${ApiConfig.eventDetailEndpoint.replaceAll('{id}', eventId)}/follow';
      final response = await _httpService.delete<Map<String, dynamic>>(
        endpoint,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to unfollow event: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to unfollow event: ${e.toString()}');
    }
  }

  /// 获取用户创建的活动
  Future<List<Map<String, dynamic>>> getUserCreatedEvents() async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final response = await _httpService.get<List<dynamic>>(
        '${ApiConfig.eventsEndpoint}/me/created',
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!);
      } else {
        throw Exception('Failed to get user created events: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get user created events: ${e.toString()}');
    }
  }

  /// 获取用户参加的活动
  Future<List<Map<String, dynamic>>> getUserJoinedEvents() async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final response = await _httpService.get<List<dynamic>>(
        '${ApiConfig.eventsEndpoint}/me/joined',
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!);
      } else {
        throw Exception('Failed to get user joined events: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get user joined events: ${e.toString()}');
    }
  }

  /// 获取用户关注的活动
  Future<List<Map<String, dynamic>>> getUserFollowingEvents() async {
    try {
      // 获取认证头
      final authHeaders = await _getAuthHeaders();

      final response = await _httpService.get<List<dynamic>>(
        '${ApiConfig.eventsEndpoint}/me/following',
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data!);
      } else {
        throw Exception(
            'Failed to get user following events: Invalid response');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to get user following events: ${e.toString()}');
    }
  }

  /// 将 CreateMeetupPage 的数据转换为 Events API 格式
  static Map<String, dynamic> convertToEventData({
    required String title,
    required String type,
    required String city,
    required String country,
    required String venue,
    required DateTime date,
    required String time,
    required int maxAttendees,
    required String description,
    String? imageUrl,
    List<String>? images,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tags,
  }) {
    // 组合日期和时间为完整的 DateTime
    final timeParts = time.split(':');
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    return {
      'title': title,
      'description': description.isNotEmpty ? description : null,
      'cityId': null, // TODO: 需要根据城市名称获取ID或者后端支持城市名称
      'location': venue,
      'address': address,
      'imageUrl': imageUrl,
      'images': images ?? [],
      'category': _mapTypeToCategory(type),
      'startTime': startDateTime.toIso8601String(),
      'endTime': null, // 可以根据需要添加结束时间
      'maxParticipants': maxAttendees,
      'locationType': 'physical', // 默认为实体活动
      'meetingLink': null, // 如果是线上活动可以添加
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags ?? [],
    };
  }

  /// 将前端的 type 映射到后端的 category
  static String _mapTypeToCategory(String type) {
    switch (type.toLowerCase()) {
      case 'drinks':
        return 'social';
      case 'coworking':
        return 'business';
      case 'dinner':
        return 'social';
      case 'activity':
        return 'other';
      case 'workshop':
        return 'tech';
      case 'networking':
        return 'business';
      default:
        return 'other';
    }
  }
}
