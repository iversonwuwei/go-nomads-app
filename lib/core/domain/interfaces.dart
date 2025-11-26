/// Repository基类接口
///
/// 所有Repository接口应该继承此接口,确保统一的设计模式
abstract class IRepository {
  /// Repository名称(用于日志和调试)
  String get repositoryName;
}

/// 聚合根标记接口
///
/// 标识一个实体是聚合根
abstract class IAggregateRoot {
  /// 聚合根的唯一标识
  dynamic get id;
}

/// 值对象标记接口
///
/// 标识一个对象是值对象(不可变)
abstract class IValueObject {
  /// 值对象应该实现相等性比较
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

/// 领域服务标记接口
///
/// 标识一个服务是领域服务
abstract class IDomainService {
  /// 服务名称
  String get serviceName;
}

/// 领域事件接口
///
/// 所有领域事件应该实现此接口
abstract class IDomainEvent {
  /// 事件发生时间
  DateTime get occurredOn;

  /// 事件名称
  String get eventName;
}
