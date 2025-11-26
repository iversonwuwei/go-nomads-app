import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 取消 RSVP Use Case
class CancelRsvpUseCase {
  final IMeetupRepository _repository;

  CancelRsvpUseCase(this._repository);

  /// 执行取消 RSVP
  Future<bool> execute(String meetupId) async {
    try {
      print('🎯 执行 CancelRsvpUseCase...');
      print('   活动ID: $meetupId');

      if (meetupId.trim().isEmpty) {
        throw ArgumentError('活动ID不能为空');
      }

      final success = await _repository.cancelRsvp(meetupId);

      if (success) {
        print('✅ 取消 RSVP 成功');
      } else {
        print('⚠️ 取消 RSVP 返回false');
      }

      return success;
    } catch (e) {
      print('❌ CancelRsvpUseCase 执行失败: $e');
      rethrow;
    }
  }
}
