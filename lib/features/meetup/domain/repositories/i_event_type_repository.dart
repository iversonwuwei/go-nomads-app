import 'package:go_nomads_app/features/meetup/domain/entities/event_type.dart';

/// 事件类型仓储接口
/// 定义事件类型数据访问的契约
abstract class IEventTypeRepository {
  /// 获取所有活跃的事件类型列表
  /// 返回按 sortOrder 排序的类型列表
  Future<List<EventType>> getEventTypes();

  /// 根据 ID 获取单个事件类型
  Future<EventType?> getEventTypeById(String id);
}
