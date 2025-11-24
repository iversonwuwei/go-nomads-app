import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 取消活动 Use Case
/// 业务逻辑: 组织者取消活动
class CancelMeetupUseCase {
  final IMeetupRepository _repository;

  CancelMeetupUseCase(this._repository);

  /// 执行取消活动操作
  ///
  /// [meetupId] 活动ID
  /// 返回 true 表示取消成功
  Future<bool> execute(String meetupId) async {
    return await _repository.cancelMeetup(meetupId);
  }
}
