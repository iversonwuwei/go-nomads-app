import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';

/// 按城市获取活动列表 Use Case
class GetMeetupsByCityUseCase {
  final IMeetupRepository _repository;

  GetMeetupsByCityUseCase(this._repository);

  /// 执行按城市获取活动
  Future<List<Meetup>> execute({
    required String cityId,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('🎯 执行 GetMeetupsByCityUseCase...');
      print('   城市ID: $cityId, 状态: $status');

      final meetups = await _repository.getMeetups(
        status: status ?? 'upcoming',
        cityId: cityId,
        page: page,
        pageSize: pageSize,
      );

      // 按开始时间排序
      meetups
          .sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));

      print('✅ 获取到 ${meetups.length} 个活动');
      return meetups;
    } catch (e) {
      print('❌ GetMeetupsByCityUseCase 执行失败: $e');
      rethrow;
    }
  }

  /// 按城市名称获取活动 (需要先查找城市ID)
  Future<List<Meetup>> executeByName({
    required String cityName,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('🎯 按城市名称获取活动: $cityName');

      // 获取所有活动并过滤
      final allMeetups = await _repository.getMeetups(
        status: status ?? 'upcoming',
        page: page,
        pageSize: pageSize,
      );

      // 过滤匹配城市名称的活动
      final filtered = allMeetups
          .where((m) =>
              m.location.city == cityName || m.location.cityName == cityName)
          .toList();

      // 按开始时间排序
      filtered
          .sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));

      print('✅ 找到 ${filtered.length} 个活动');
      return filtered;
    } catch (e) {
      print('❌ GetMeetupsByCityUseCase.executeByName 失败: $e');
      rethrow;
    }
  }
}
