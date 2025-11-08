import '../entities/meetup.dart';

/// Meetup Repository 接口
/// 定义活动数据访问的抽象契约
abstract class IMeetupRepository {
  /// 获取活动列表
  ///
  /// [status] 活动状态筛选 ('upcoming', 'ongoing', 'completed', 'cancelled')
  /// [cityId] 城市ID筛选
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<List<Meetup>> getMeetups({
    String? status,
    String? cityId,
    int page = 1,
    int pageSize = 20,
  });

  /// 根据ID获取单个活动
  Future<Meetup?> getMeetupById(String meetupId);

  /// 创建活动
  ///
  /// 返回创建后的完整 Meetup 实体
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
  });

  /// RSVP 参加活动
  ///
  /// [meetupId] 活动ID
  /// 返回 true 表示成功
  Future<bool> rsvpToMeetup(String meetupId);

  /// 取消 RSVP
  ///
  /// [meetupId] 活动ID
  /// 返回 true 表示成功
  Future<bool> cancelRsvp(String meetupId);

  /// 获取用户参与的活动列表
  ///
  /// [userId] 用户ID
  Future<List<Meetup>> getUserMeetups(String userId);

  /// 更新活动信息
  ///
  /// [meetupId] 活动ID
  /// [updates] 要更新的字段 (支持部分更新)
  Future<Meetup> updateMeetup(String meetupId, Map<String, dynamic> updates);

  /// 取消活动
  ///
  /// [meetupId] 活动ID
  Future<bool> cancelMeetup(String meetupId);
}
