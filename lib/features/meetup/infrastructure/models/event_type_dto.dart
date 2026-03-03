import 'package:go_nomads_app/features/meetup/domain/entities/event_type.dart';

/// 事件类型数据传输对象
/// 用于与后端 API 进行数据交换
class EventTypeDto {
  final String id;
  final String name;
  final String enName;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final String? createdAt; // 改为可空
  final String? updatedAt;

  const EventTypeDto({
    required this.id,
    required this.name,
    required this.enName,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.createdAt, // 改为可选
    this.updatedAt,
  });

  /// 从 JSON 创建 DTO
  factory EventTypeDto.fromJson(Map<String, dynamic> json) {
    return EventTypeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      enName: json['enName'] as String,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?, // 允许为 null
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enName': enName,
      'description': description,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 转换为领域实体
  EventType toDomain() {
    return EventType(
      id: id,
      name: name,
      enName: enName,
      description: description,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// 从领域实体创建 DTO
  factory EventTypeDto.fromDomain(EventType eventType) {
    return EventTypeDto(
      id: eventType.id,
      name: eventType.name,
      enName: eventType.enName,
      description: eventType.description,
      sortOrder: eventType.sortOrder,
      isActive: eventType.isActive,
      createdAt: eventType.createdAt.toIso8601String(),
      updatedAt: eventType.updatedAt?.toIso8601String(),
    );
  }
}
