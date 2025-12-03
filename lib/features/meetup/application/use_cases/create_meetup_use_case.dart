import 'dart:developer';

import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 创建活动 Use Case
class CreateMeetupUseCase {
  final IMeetupRepository _repository;

  CreateMeetupUseCase(this._repository);

  /// 执行创建活动
  Future<Meetup> execute({
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
      log('🎯 执行 CreateMeetupUseCase...');
      log('   活动标题: $title');
      log('   城市ID: $cityId');
      log('   开始时间: $startTime');

      // 验证输入
      _validateInput(
        title: title,
        description: description,
        cityId: cityId,
        venue: venue,
        maxAttendees: maxAttendees,
        startTime: startTime,
      );

      // 调用 Repository 创建活动
      final meetup = await _repository.createMeetup(
        title: title,
        description: description,
        cityId: cityId,
        venue: venue,
        venueAddress: venueAddress,
        type: type,
        eventTypeId: eventTypeId,
        startTime: startTime,
        endTime: endTime,
        maxAttendees: maxAttendees,
        imageUrl: imageUrl,
        images: images,
        tags: tags,
      );

      log('✅ 活动创建成功: ${meetup.id}');
      return meetup;
    } catch (e) {
      log('❌ CreateMeetupUseCase 执行失败: $e');
      rethrow;
    }
  }

  /// 验证输入参数
  void _validateInput({
    required String title,
    required String description,
    required String cityId,
    required String venue,
    required int maxAttendees,
    required DateTime startTime,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('活动标题不能为空');
    }

    if (title.trim().length < 3) {
      throw ArgumentError('活动标题至少需要3个字符');
    }

    if (description.trim().isEmpty) {
      throw ArgumentError('活动描述不能为空');
    }

    if (cityId.trim().isEmpty) {
      throw ArgumentError('城市ID不能为空');
    }

    if (venue.trim().isEmpty) {
      throw ArgumentError('活动地点不能为空');
    }

    if (maxAttendees < 1) {
      throw ArgumentError('最大参与人数必须大于0');
    }

    if (maxAttendees > 10000) {
      throw ArgumentError('最大参与人数不能超过10000');
    }

    // 验证时间不能是过去
    if (startTime.isBefore(DateTime.now())) {
      throw ArgumentError('活动开始时间不能早于当前时间');
    }

    log('✅ 输入验证通过');
  }
}
