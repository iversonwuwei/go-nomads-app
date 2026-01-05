import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';

/// 活动邀请实体
class MeetupInvitation {
  final String id;
  final String eventId;
  final String inviterId;
  final String inviteeId;
  final String status; // pending, accepted, rejected, expired
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;
  final Meetup? event;
  final InviterInfo? inviter;
  final InviteeInfo? invitee;

  MeetupInvitation({
    required this.id,
    required this.eventId,
    required this.inviterId,
    required this.inviteeId,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
    this.event,
    this.inviter,
    this.invitee,
  });

  factory MeetupInvitation.fromJson(Map<String, dynamic> json) {
    return MeetupInvitation(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      inviterId: json['inviterId'] as String,
      inviteeId: json['inviteeId'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt'] as String) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      // event 可以单独解析，但这里简化处理
      inviter: json['inviter'] != null ? InviterInfo.fromJson(json['inviter']) : null,
      invitee: json['invitee'] != null ? InviteeInfo.fromJson(json['invitee']) : null,
    );
  }
}

/// 邀请人信息
class InviterInfo {
  final String id;
  final String? name;
  final String? email;
  final String? avatar;

  InviterInfo({
    required this.id,
    this.name,
    this.email,
    this.avatar,
  });

  factory InviterInfo.fromJson(Map<String, dynamic> json) {
    return InviterInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

/// 被邀请人信息
class InviteeInfo {
  final String id;
  final String? name;
  final String? email;
  final String? avatar;

  InviteeInfo({
    required this.id,
    this.name,
    this.email,
    this.avatar,
  });

  factory InviteeInfo.fromJson(Map<String, dynamic> json) {
    return InviteeInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

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
    String? eventTypeId, // EventType UUID
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

  /// 获取用户已加入的活动列表(分页)
  ///
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<List<Meetup>> getJoinedMeetups({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取当前用户取消的活动列表(分页)
  ///
  /// [userId] 用户ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<List<Meetup>> getCancelledMeetupsByUser(
    String userId, {
    int page = 1,
    int pageSize = 20,
  });

  /// 更新活动信息
  ///
  /// [meetupId] 活动ID
  /// [updates] 要更新的字段 (支持部分更新)
  Future<Meetup> updateMeetup(String meetupId, Map<String, dynamic> updates);

  /// 取消活动
  ///
  /// [meetupId] 活动ID
  Future<bool> cancelMeetup(String meetupId);

  /// 删除活动（仅管理员）
  ///
  /// [meetupId] 活动ID
  Future<bool> deleteMeetup(String meetupId);

  /// 获取当前用户创建的活动列表
  ///
  /// 返回用户作为组织者创建的所有活动
  Future<List<Meetup>> getMyCreatedMeetups();

  // ========== 邀请相关方法 ==========

  /// 邀请用户参加活动
  ///
  /// [meetupId] 活动ID
  /// [inviteeId] 被邀请人ID
  /// [message] 邀请留言（可选）
  Future<MeetupInvitation> inviteToMeetup({
    required String meetupId,
    required String inviteeId,
    String? message,
  });

  /// 响应邀请
  ///
  /// [invitationId] 邀请ID
  /// [accept] true 表示接受，false 表示拒绝
  Future<MeetupInvitation> respondToInvitation({
    required String invitationId,
    required bool accept,
  });

  /// 获取收到的邀请列表
  ///
  /// [status] 状态筛选（pending, accepted, rejected, expired）
  Future<List<MeetupInvitation>> getReceivedInvitations({String? status});

  /// 获取发出的邀请列表
  ///
  /// [status] 状态筛选
  Future<List<MeetupInvitation>> getSentInvitations({String? status});
}
