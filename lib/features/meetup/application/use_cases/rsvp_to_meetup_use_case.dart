import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// RSVP 活动 Use Case
class RsvpToMeetupUseCase {
  final IMeetupRepository _repository;

  RsvpToMeetupUseCase(this._repository);

  /// 执行 RSVP
  Future<bool> execute(String meetupId) async {
    try {
      print('🎯 执行 RsvpToMeetupUseCase...');
      print('   活动ID: $meetupId');

      if (meetupId.trim().isEmpty) {
        throw ArgumentError('活动ID不能为空');
      }

      final success = await _repository.rsvpToMeetup(meetupId);

      if (success) {
        print('✅ RSVP 成功');
      } else {
        print('⚠️ RSVP 返回false');
      }

      return success;
    } catch (e) {
      print('❌ RsvpToMeetupUseCase 执行失败: $e');
      rethrow;
    }
  }
}
