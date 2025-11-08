import '../../../../services/events_api_service.dart';
import '../../domain/entities/meetup.dart';
import '../../domain/repositories/i_meetup_repository.dart';
import '../models/meetup_dto.dart';

/// Meetup Repository 实现
/// 使用 EventsApiService 进行数据访问
class MeetupRepository implements IMeetupRepository {
  final EventsApiService _apiService;

  MeetupRepository({EventsApiService? apiService})
      : _apiService = apiService ?? EventsApiService();

  @override
  Future<List<Meetup>> getMeetups({
    String? status,
    String? cityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('📡 调用 EventsApiService.getEvents...');
      print('   status: $status, cityId: $cityId, page: $page');

      // 调用 API 获取活动数据
      final response = await _apiService.getEvents(
        status: status ?? 'upcoming',
        cityId: cityId,
        page: page,
        pageSize: pageSize,
        requireAuth: false, // 允许未登录用户查看活动列表
      );

      // 提取活动列表
      final items = response['items'] as List<dynamic>? ?? [];
      print('✅ 获取到 ${items.length} 个活动');

      // 转换为领域实体
      final meetups = items
          .map((json) => MeetupDto.fromJson(json as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
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
      print('📡 调用 EventsApiService.getEvent: $meetupId');

      final response = await _apiService.getEvent(meetupId);
      final data = response['data'] as Map<String, dynamic>? ?? response;

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
        'category': _mapTypeToCategory(type),
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

      // 调用 API
      final response = await _apiService.createEvent(requestData);
      final data = response['data'] as Map<String, dynamic>? ?? response;

      print('✅ 活动创建成功, ID: ${data['id']}');

      // 转换为领域实体
      final dto = MeetupDto.fromJson(data);
      return dto.toDomain();
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

      final success = await _apiService.joinEvent(meetupId);
      if (success) {
        print('✅ RSVP 成功');
      }

      return success;
    } catch (e) {
      print('❌ MeetupRepository.rsvpToMeetup 失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelRsvp(String meetupId) async {
    try {
      print('📡 取消 RSVP: $meetupId');

      final success = await _apiService.leaveEvent(meetupId);
      if (success) {
        print('✅ 取消 RSVP 成功');
      }

      return success;
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

      // TODO: 需要 EventsApiService 支持 cancelEvent 方法
      throw UnimplementedError('cancelMeetup 尚未实现');
    } catch (e) {
      print('❌ MeetupRepository.cancelMeetup 失败: $e');
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
