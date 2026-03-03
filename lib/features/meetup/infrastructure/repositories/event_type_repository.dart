import 'dart:developer';

import 'package:go_nomads_app/features/meetup/domain/entities/event_type.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_event_type_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/models/event_type_dto.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// 事件类型仓储实现
/// 负责从后端 API 获取事件类型数据
class EventTypeRepository implements IEventTypeRepository {
  final HttpService _httpService;

  EventTypeRepository(this._httpService);

  @override
  Future<List<EventType>> getEventTypes() async {
    try {
      // 调用后端 API 获取事件类型列表
      // 后端路径: /api/v1/event-types
      final response = await _httpService.get('/event-types');

      // 后端返回格式: { success: true, message: "...", data: [...] }
      // 需要提取 data 字段
      final responseData = response.data;
      final List<dynamic> dataList = responseData is Map<String, dynamic>
          ? (responseData['data'] as List<dynamic>)
          : (responseData as List<dynamic>);

      log('✅ 收到 ${dataList.length} 个事件类型');

      // 转换为领域实体列表
      final eventTypes = dataList
          .map((json) => EventTypeDto.fromJson(json as Map<String, dynamic>))
          .map((dto) => dto.toDomain())
          .where((type) => type.isActive) // 只返回活跃的类型
          .toList();

      // 按 sortOrder 排序
      eventTypes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return eventTypes;
    } catch (e, stackTrace) {
      log('❌ 获取事件类型失败: $e');
      log('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<EventType?> getEventTypeById(String id) async {
    try {
      final response = await _httpService.get('/event-types/$id');

      // 后端返回格式: { success: true, message: "...", data: {...} }
      final responseData = response.data;
      final Map<String, dynamic> data = responseData is Map<String, dynamic>
          ? (responseData.containsKey('data') ? responseData['data'] : responseData)
          : responseData as Map<String, dynamic>;

      final dto = EventTypeDto.fromJson(data);
      return dto.toDomain();
    } catch (e) {
      log('❌ 获取事件类型详情失败 (ID: $id): $e');
      return null;
    }
  }
}
