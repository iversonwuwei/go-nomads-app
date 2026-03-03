/// 统一的导航结果模型
///
/// 用于页面之间传递导航结果，实现统一的数据刷新机制
///
/// 使用场景：
/// - 创建/编辑页面返回到列表页，通知列表刷新
/// - 详情页返回到列表页，携带更新后的数据
/// - 任何需要页面间数据传递的场景
library;

/// 导航操作类型
enum NavigationAction {
  /// 新建数据
  created,

  /// 更新数据
  updated,

  /// 删除数据
  deleted,

  /// 未变更（用户取消或直接返回）
  unchanged,

  /// 强制刷新（即使没有数据变更也要刷新）
  forceRefresh,
}

/// 统一的导航结果类
///
/// 泛型 [T] 为携带的数据类型
class NavigationResult<T> {
  /// 操作类型
  final NavigationAction action;

  /// 携带的数据（可选）
  final T? data;

  /// 实体ID（用于删除场景）
  final String? entityId;

  /// 额外消息（可选，用于显示提示）
  final String? message;

  /// 私有构造函数
  const NavigationResult._({
    required this.action,
    this.data,
    this.entityId,
    this.message,
  });

  /// 内部构造器（仅供 NavigationUtil 使用）
  ///
  /// 用于在处理泛型转换时创建新的 NavigationResult 实例
  static NavigationResult<T> internal<T>({
    required NavigationAction action,
    T? data,
    String? entityId,
    String? message,
  }) {
    return NavigationResult<T>._(
      action: action,
      data: data,
      entityId: entityId,
      message: message,
    );
  }

  /// 创建"新建成功"结果
  factory NavigationResult.created(T data, {String? message}) {
    return NavigationResult._(
      action: NavigationAction.created,
      data: data,
      message: message,
    );
  }

  /// 创建"更新成功"结果
  factory NavigationResult.updated(T data, {String? message}) {
    return NavigationResult._(
      action: NavigationAction.updated,
      data: data,
      message: message,
    );
  }

  /// 创建"删除成功"结果
  factory NavigationResult.deleted({String? entityId, String? message}) {
    return NavigationResult._(
      action: NavigationAction.deleted,
      entityId: entityId,
      message: message,
    );
  }

  /// 创建"未变更"结果
  factory NavigationResult.unchanged() {
    return const NavigationResult._(action: NavigationAction.unchanged);
  }

  /// 创建"强制刷新"结果
  factory NavigationResult.forceRefresh({T? data}) {
    return NavigationResult._(
      action: NavigationAction.forceRefresh,
      data: data,
    );
  }

  /// 是否需要刷新列表
  bool get needsRefresh => action != NavigationAction.unchanged;

  /// 是否有数据
  bool get hasData => data != null;

  /// 是否为创建操作
  bool get isCreated => action == NavigationAction.created;

  /// 是否为更新操作
  bool get isUpdated => action == NavigationAction.updated;

  /// 是否为删除操作
  bool get isDeleted => action == NavigationAction.deleted;

  /// 是否未变更
  bool get isUnchanged => action == NavigationAction.unchanged;

  @override
  String toString() {
    return 'NavigationResult(action: $action, hasData: $hasData, entityId: $entityId)';
  }
}

// ==================== 核心接口定义 ====================

/// 可刷新列表接口
///
/// 实现此接口的 Controller 可以与 NavigationUtil 自动集成
///
/// 示例：
/// ```dart
/// class MeetupListController extends GetxController
///     implements IRefreshableList<Meetup> {
///   final RxList<Meetup> meetups = <Meetup>[].obs;
///
///   @override
///   String getItemId(Meetup item) => item.id;
///
///   @override
///   Future<void> refreshList() => loadMeetups();
///
///   @override
///   void addItem(Meetup item) => meetups.insert(0, item);
///
///   @override
///   void updateItem(Meetup item) {
///     final idx = meetups.indexWhere((m) => m.id == item.id);
///     if (idx != -1) { meetups[idx] = item; meetups.refresh(); }
///   }
///
///   @override
///   void removeItemById(String id) => meetups.removeWhere((m) => m.id == id);
/// }
/// ```
abstract class IRefreshableList<T> {
  /// 获取列表项ID
  String getItemId(T item);

  /// 刷新整个列表
  Future<void> refreshList();

  /// 在列表头部添加项
  void addItem(T item);

  /// 更新列表中的项
  void updateItem(T item);

  /// 从列表中移除项
  void removeItemById(String id);
}

/// 详情页数据变更跟踪接口
///
/// 实现此接口的 Controller 可以统一处理返回逻辑
abstract class IDetailPage<T> {
  /// 获取当前实体数据
  T? get currentEntity;

  /// 获取实体ID（用于删除场景）
  String? get entityId;

  /// 数据是否有变更
  bool get hasDataChanged;

  /// 标记数据已变更
  void markDataChanged();
}
