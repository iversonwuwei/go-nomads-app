import 'dart:developer';

import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';

/// RSVP 活动 Use Case
class RsvpToMeetupUseCase {
  final IMeetupRepository _repository;

  RsvpToMeetupUseCase(this._repository);

  /// 执行 RSVP
  Future<bool> execute(String meetupId) async {
    try {
      log('🎯 执行 RsvpToMeetupUseCase...');
      log('   活动ID: $meetupId');

      if (meetupId.trim().isEmpty) {
        throw ArgumentError('活动ID不能为空');
      }

      final success = await _repository.rsvpToMeetup(meetupId);

      if (success) {
        log('✅ RSVP 成功');
      } else {
        log('⚠️ RSVP 返回false');
      }

      return success;
    } catch (e) {
      log('❌ RsvpToMeetupUseCase 执行失败: $e');
      rethrow;
    }
  }
}
