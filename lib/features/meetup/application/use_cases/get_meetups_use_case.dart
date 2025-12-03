import 'dart:developer';

import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 获取活动列表 Use Case
class GetMeetupsUseCase {
  final IMeetupRepository _repository;

  GetMeetupsUseCase(this._repository);

  /// 执行获取活动列表
  Future<List<Meetup>> execute({
    String? status,
    String? cityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      log('🎯 执行 GetMeetupsUseCase...');
      log('   筛选条件: status=$status, cityId=$cityId');

      final meetups = await _repository.getMeetups(
        status: status,
        cityId: cityId,
        page: page,
        pageSize: pageSize,
      );

      log('✅ 获取到 ${meetups.length} 个活动');
      return meetups;
    } catch (e) {
      log('❌ GetMeetupsUseCase 执行失败: $e');
      rethrow;
    }
  }
}
