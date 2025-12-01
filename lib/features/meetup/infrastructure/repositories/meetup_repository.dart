import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// Meetup Repository 实现
/// 使用 HttpService 进行数据访问
class MeetupRepository implements IMeetupRepository {
  final HttpService _httpService = Get.find();

  @override
  Future<List<Meetup>> getMeetups({
    String? status,
    String? cityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('📡 调用 HttpService GET /events...');
      print('   status: $status, cityId: $cityId, page: $page');

      final queryParams = <String, dynamic>{
        'status': status ?? 'upcoming',
        'page': page,
        'pageSize': pageSize,
      };
      if (cityId != null) {
        queryParams['cityId'] = cityId;
      }

      // 调用 HttpService 获取活动数据
      final response = await _httpService.get(
        '/events',
        queryParameters: queryParams,
      );

      // 提取活动列表 (HttpService 已自动解包 data 字段)
      final data = response.data as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];
      print('✅ 获取到 ${items.length} 个活动');

      // 转换为领域实体
      final meetups = items
          .map((json) {
            try {
              final dto = MeetupDto.fromJson(json as Map<String, dynamic>);
              final meetup = dto.toDomain();
              // 打印每个活动的 isParticipant 状态
              print('   活动: ${meetup.title} - isParticipant: ${json['isParticipant']} -> isJoined: ${meetup.isJoined}');
              return meetup;
            } catch (e) {
              print('❌ 解析 meetup 失败: $e');
              print('   JSON: $json');
              return null;
            }
          })
          .whereType<Meetup>()
          .toList();

      return meetups;
    } catch (e, stackTrace) {
      print('❌ MeetupRepository.getMeetups 失败: $e');
      print('   堆栈: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Meetup?> getMeetupById(String meetupId) async {
    try {
      print('📡 调用 HttpService GET /events/$meetupId');

      final response = await _httpService.get('/events/$meetupId');
      final data = response.data as Map<String, dynamic>;

      final dto = MeetupDto.fromJson(data);
      return dto.toDomain();
    } catch (e) {
      print('❌ MeetupRepository.getMeetupById 失败: $e');
      return null;
    }
  }

  @override
  Future<Meetup> createMeetup({
    required String title,
    required String description,
    required String cityId,
    required String venue,
    required String venueAddress,
    required MeetupType type,
    String? eventTypeId, // 新增
    required DateTime startTime,
    DateTime? endTime,
    required int maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      print('📡 创建活动: $title');

      // 构建 API 请求数据
      final requestData = {
        'title': title,
        'description': description.isNotEmpty ? description : null,
        'location': venue,
        'address': venueAddress,
        'category': eventTypeId ?? _mapTypeToCategory(type), // 优先使用 eventTypeId
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'maxParticipants': maxAttendees,
        'locationType': 'physical',
        'meetingLink': null,
      };

      // 添加可选字段
      if (cityId.isNotEmpty && cityId.contains('-')) {
        requestData['cityId'] = cityId;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestData['imageUrl'] = imageUrl;
      }
      if (images != null && images.isNotEmpty) {
        requestData['images'] = images;
      }
      if (tags != null && tags.isNotEmpty) {
        requestData['tags'] = tags;
      }

      print('📤 请求数据: $requestData');

      // 调用 HttpService POST
      final response = await _httpService.post('/events', data: requestData);
      final data = response.data as Map<String, dynamic>;

      print('✅ 活动创建成功, ID: ${data['id']}');
      print('📦 后端返回的数据: $data');
      print('🔍 organizer 信息: ${data['organizer']}');
      print('🔍 organizerId: ${data['organizerId']}');

      // 转换为领域实体
      final dto = MeetupDto.fromJson(data);
      final meetup = dto.toDomain();

      print('✅ 转换后的 Meetup:');
      print('   - ID: ${meetup.id}');
      print('   - Title: ${meetup.title}');
      print('   - Organizer ID: ${meetup.organizer.id}');
      print('   - Organizer Name: ${meetup.organizer.name}');

      return meetup;
    } catch (e, stackTrace) {
      print('❌ MeetupRepository.createMeetup 失败: $e');
      print('   堆栈: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> rsvpToMeetup(String meetupId) async {
    try {
      print('📡 RSVP 活动: $meetupId');

      // 后端需要一个非空的请求体
      await _httpService.post(
        '/events/$meetupId/join',
        data: {}, // 发送空的 JSON 对象
      );
      print('✅ RSVP 成功');
      return true;
    } catch (e) {
      print('❌ MeetupRepository.rsvpToMeetup 失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelRsvp(String meetupId) async {
    try {
      print('📡 取消 RSVP: $meetupId');

      // 使用 DELETE 方法取消参加
      await _httpService.delete('/events/$meetupId/join');
      print('✅ 取消 RSVP 成功');
      return true;
    } catch (e) {
      print('❌ MeetupRepository.cancelRsvp 失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<Meetup>> getUserMeetups(String userId) async {
    try {
      print('📡 获取用户活动: $userId');

      // TODO: 需要 API 支持按用户ID查询
      // 暂时返回空列表
      print('⚠️ getUserMeetups 尚未实现 API 支持');
      return [];
    } catch (e) {
      print('❌ MeetupRepository.getUserMeetups 失败: $e');
      return [];
    }
  }

  @override
  Future<List<Meetup>> getJoinedMeetups({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('📡 调用 HttpService GET /events/joined...');
      print('   page: $page, pageSize: $pageSize');

      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      // 调用 HttpService 获取已加入的活动数据
      final response = await _httpService.get(
        '/events/joined',
        queryParameters: queryParams,
      );

      // 提取活动列表 (HttpService 已自动解包 data 字段)
      final data = response.data as Map<String, dynamic>;
      final eventsJson = (data['items'] as List?) ?? [];

      // 将 JSON 转换为 DTO 再转换为领域实体
      final meetups = eventsJson
          .map((json) {
            try {
              return MeetupDto.fromJson(json as Map<String, dynamic>).toDomain();
            } catch (e) {
              print('❌ 解析 meetup 失败: $e');
              print('   JSON: $json');
              return null;
            }
          })
          .whereType<Meetup>()
          .toList();

      print('✅ 获取到 ${meetups.length} 个已加入的活动');
      return meetups;
    } catch (e) {
      print('❌ MeetupRepository.getJoinedMeetups 失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<Meetup>> getCancelledMeetupsByUser(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('📡 调用 HttpService GET /events/cancelled...');
      print('   userId: $userId');
      print('   page: $page, pageSize: $pageSize');

      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      // 调用 HttpService 获取用户取消的活动数据(userId 从后端 UserContext 获取)
      final response = await _httpService.get(
        '/events/cancelled',
        queryParameters: queryParams,
      );

      print('📦 收到响应: ${response.data}');

      // 提取活动列表 (HttpService 已自动解包 data 字段)
      final data = response.data as Map<String, dynamic>;
      final eventsJson = (data['items'] as List?) ?? [];

      print('📝 解析到 ${eventsJson.length} 个活动记录');

      // 将 JSON 转换为 DTO 再转换为领域实体
      final meetups = eventsJson
          .map((json) {
            try {
              return MeetupDto.fromJson(json as Map<String, dynamic>).toDomain();
            } catch (e) {
              print('❌ 解析 meetup 失败: $e');
              print('   JSON: $json');
              return null;
            }
          })
          .whereType<Meetup>()
          .toList();

      print('✅ 获取到 ${meetups.length} 个已取消的活动');
      return meetups;
    } catch (e, stackTrace) {
      print('❌ MeetupRepository.getCancelledMeetupsByUser 失败: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Meetup> updateMeetup(
    String meetupId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('📡 更新活动: $meetupId');
      print('   更新内容: $updates');

      // TODO: 需要 EventsApiService 支持 updateEvent 方法
      throw UnimplementedError('updateMeetup 尚未实现');
    } catch (e) {
      print('❌ MeetupRepository.updateMeetup 失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelMeetup(String meetupId) async {
    try {
      print('📡 取消活动: $meetupId');

      // 调用后端 API 取消活动 - 使用专用的 cancel 端点
      await _httpService.post('/events/$meetupId/cancel');

      print('✅ 活动已取消');
      return true;
    } catch (e) {
      print('❌ MeetupRepository.cancelMeetup 失败: $e');
      rethrow;
    }
  }

  @override
  Future<List<Meetup>> getMyCreatedMeetups() async {
    try {
      print('📡 调用 HttpService GET /events/me/created...');

      final response = await _httpService.get('/events/me/created');

      // 后端返回格式: { success: true, data: [...] }
      final data = response.data;
      List items;

      if (data is Map<String, dynamic>) {
        items = (data['data'] as List?) ?? (data['items'] as List?) ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      print('✅ 获取到 ${items.length} 个我创建的活动');

      final meetups = items
          .map((json) {
            try {
              final dto = MeetupDto.fromJson(json as Map<String, dynamic>);
              return dto.toDomain();
            } catch (e) {
              print('❌ 解析 meetup 失败: $e');
              return null;
            }
          })
          .whereType<Meetup>()
          .toList();

      return meetups;
    } catch (e, stackTrace) {
      print('❌ MeetupRepository.getMyCreatedMeetups 失败: $e');
      print('   堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 将 MeetupType 映射到 API 的 category
  String _mapTypeToCategory(MeetupType type) {
    switch (type.value) {
      case 'networking':
        return 'business';
      case 'workshop':
        return 'tech';
      case 'social':
        return 'social';
      case 'coworking':
        return 'business';
      case 'sports':
        return 'other';
      case 'culture':
        return 'other';
      default:
        return 'other';
    }
  }
}
