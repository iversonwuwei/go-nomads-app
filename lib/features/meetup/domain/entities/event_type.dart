/// 事件类型领域实体
/// 代表聚会活动的类型分类
class EventType {
  final String id;
  final String name;
  final String enName;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EventType({
    required this.id,
    required this.name,
    required this.enName,
    this.description,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// 根据当前语言环境获取显示名称
  String getDisplayName(String locale) {
    if (locale.startsWith('zh')) {
      return name;
    }
    return enName;
  }

  /// 复制并修改部分字段
  EventType copyWith({
    String? id,
    String? name,
    String? enName,
    String? description,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventType(
      id: id ?? this.id,
      name: name ?? this.name,
      enName: enName ?? this.enName,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventType && other.id == id && other.name == name && other.enName == enName;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ enName.hashCode;

  @override
  String toString() => 'EventType(id: $id, name: $name, enName: $enName)';
}
