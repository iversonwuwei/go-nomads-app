import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

/// 数据版本信息
class DataVersion {
  final String entityType;
  final String? entityId;
  final int version;
  final DateTime lastUpdated;

  DataVersion({
    required this.entityType,
    this.entityId,
    required this.version,
    required this.lastUpdated,
  });

  String get key => entityId != null ? '$entityType:$entityId' : entityType;

  DataVersion incrementVersion() {
    return DataVersion(
      entityType: entityType,
      entityId: entityId,
      version: version + 1,
      lastUpdated: DateTime.now(),
    );
  }
}

/// 数据同步状态
enum SyncStatus {
  idle, // 空闲
  syncing, // 同步中
  synced, // 已同步
  error, // 错误
  stale, // 数据过期
}

/// 同步优先级
enum SyncPriority {
  low, // 低优先级 - 后台静默同步
  normal, // 普通优先级 - 正常加载
  high, // 高优先级 - 用户主动刷新
  critical, // 关键优先级 - 必须立即同步
}

/// 数据同步服务
///
/// 提供统一的数据版本管理、缓存控制和跨设备同步能力
///
/// 主要功能:
/// 1. 数据版本追踪 - 跟踪每个数据实体的版本
/// 2. 缓存失效管理 - 智能判断数据是否过期
/// 3. 同步队列管理 - 批量处理同步请求
/// 4. 事件通知 - 数据变更时通知订阅者
class DataSyncService extends GetxService {
  static DataSyncService get instance => Get.find<DataSyncService>();

  // 数据版本存储
  final Map<String, DataVersion> _versions = {};

  // 同步状态
  final Rx<SyncStatus> globalSyncStatus = SyncStatus.idle.obs;

  // 同步队列
  final List<SyncTask> _syncQueue = [];

  // 正在同步的任务
  final Set<String> _activeSyncs = {};

  // 默认缓存有效期配置
  static const Map<String, Duration> _defaultCacheDurations = {
    'city_list': Duration(minutes: 5),
    'city_detail': Duration(minutes: 3),
    'coworking_list': Duration(minutes: 3),
    'coworking_detail': Duration(minutes: 2),
    'user_profile': Duration(minutes: 10),
    'user_favorites': Duration(minutes: 2),
    'meetup_list': Duration(minutes: 2),
    'notification_list': Duration(minutes: 1),
    'weather': Duration(minutes: 15),
    'travel_plan': Duration(minutes: 5),
  };

  // 自定义缓存有效期
  final Map<String, Duration> _customCacheDurations = {};

  /// 注册数据版本
  void registerVersion(String entityType, {String? entityId, int initialVersion = 0}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    if (!_versions.containsKey(key)) {
      _versions[key] = DataVersion(
        entityType: entityType,
        entityId: entityId,
        version: initialVersion,
        lastUpdated: DateTime.now(),
      );
      log('📝 [DataSync] 注册版本: $key (v$initialVersion)');
    }
  }

  /// 获取数据版本
  DataVersion? getVersion(String entityType, {String? entityId}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    return _versions[key];
  }

  /// 更新数据版本 (数据变更时调用)
  void updateVersion(String entityType, {String? entityId}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    final current = _versions[key];

    if (current != null) {
      _versions[key] = current.incrementVersion();
      log('⬆️ [DataSync] 版本更新: $key -> v${_versions[key]!.version}');

      // 通知订阅者
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: entityType,
        entityId: entityId,
        version: _versions[key]!.version,
        changeType: DataChangeType.updated,
      ));
    } else {
      registerVersion(entityType, entityId: entityId, initialVersion: 1);
    }
  }

  /// 检查数据是否过期
  bool isDataStale(String entityType, {String? entityId}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    final version = _versions[key];

    if (version == null) {
      return true; // 未注册的数据视为过期
    }

    final cacheDuration =
        _customCacheDurations[entityType] ?? _defaultCacheDurations[entityType] ?? const Duration(minutes: 5);

    final now = DateTime.now();
    final isStale = now.difference(version.lastUpdated) > cacheDuration;

    if (isStale) {
      log('⏰ [DataSync] 数据过期: $key (距上次更新: ${now.difference(version.lastUpdated).inSeconds}s)');
    }

    return isStale;
  }

  /// 设置自定义缓存有效期
  void setCacheDuration(String entityType, Duration duration) {
    _customCacheDurations[entityType] = duration;
    log('⚙️ [DataSync] 设置缓存有效期: $entityType -> ${duration.inSeconds}s');
  }

  /// 标记数据为已刷新 (加载数据后调用)
  void markAsFresh(String entityType, {String? entityId}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    final current = _versions[key];

    if (current != null) {
      _versions[key] = DataVersion(
        entityType: entityType,
        entityId: entityId,
        version: current.version,
        lastUpdated: DateTime.now(),
      );
      log('✅ [DataSync] 标记为最新: $key');
    } else {
      registerVersion(entityType, entityId: entityId);
    }
  }

  /// 使缓存失效 (强制下次加载时刷新)
  void invalidateCache(String entityType, {String? entityId}) {
    final key = entityId != null ? '$entityType:$entityId' : entityType;
    final current = _versions[key];

    if (current != null) {
      _versions[key] = DataVersion(
        entityType: entityType,
        entityId: entityId,
        version: current.version,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(0), // 设为过去时间
      );
      log('🗑️ [DataSync] 缓存失效: $key');

      // 通知订阅者
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: entityType,
        entityId: entityId,
        version: current.version,
        changeType: DataChangeType.invalidated,
      ));
    }
  }

  /// 批量使缓存失效
  void invalidateCaches(List<String> entityTypes) {
    for (final entityType in entityTypes) {
      invalidateCache(entityType);
    }
  }

  /// 使所有相关实体的缓存失效
  void invalidateRelated(String entityType) {
    final keysToInvalidate = _versions.keys.where((key) => key.startsWith(entityType)).toList();

    for (final key in keysToInvalidate) {
      final parts = key.split(':');
      invalidateCache(parts[0], entityId: parts.length > 1 ? parts[1] : null);
    }

    log('🗑️ [DataSync] 批量失效: ${keysToInvalidate.length} 个实体');
  }

  /// 添加同步任务到队列
  Future<void> queueSync(
    String entityType, {
    String? entityId,
    SyncPriority priority = SyncPriority.normal,
    Future<void> Function()? syncAction,
  }) async {
    final key = entityId != null ? '$entityType:$entityId' : entityType;

    // 检查是否已在同步中
    if (_activeSyncs.contains(key)) {
      log('⏭️ [DataSync] 跳过重复同步: $key');
      return;
    }

    final task = SyncTask(
      entityType: entityType,
      entityId: entityId,
      priority: priority,
      syncAction: syncAction,
    );

    _syncQueue.add(task);
    _syncQueue.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    log('➕ [DataSync] 添加同步任务: $key (优先级: ${priority.name})');

    // 立即处理高优先级任务
    if (priority == SyncPriority.high || priority == SyncPriority.critical) {
      await _processSyncQueue();
    }
  }

  /// 处理同步队列
  Future<void> _processSyncQueue() async {
    while (_syncQueue.isNotEmpty) {
      final task = _syncQueue.removeAt(0);
      final key = task.entityId != null ? '${task.entityType}:${task.entityId}' : task.entityType;

      if (_activeSyncs.contains(key)) {
        continue;
      }

      _activeSyncs.add(key);
      globalSyncStatus.value = SyncStatus.syncing;

      try {
        if (task.syncAction != null) {
          await task.syncAction!();
        }
        markAsFresh(task.entityType, entityId: task.entityId);
      } catch (e) {
        log('❌ [DataSync] 同步失败: $key - $e');
      } finally {
        _activeSyncs.remove(key);
      }
    }

    globalSyncStatus.value = SyncStatus.idle;
  }

  /// 清除所有版本信息
  void clearAll() {
    _versions.clear();
    _syncQueue.clear();
    _activeSyncs.clear();
    log('🧹 [DataSync] 已清除所有版本信息');
  }

  /// 获取同步状态摘要
  Map<String, dynamic> getSyncSummary() {
    return {
      'totalEntities': _versions.length,
      'staleEntities': _versions.values.where((v) {
        final duration =
            _customCacheDurations[v.entityType] ?? _defaultCacheDurations[v.entityType] ?? const Duration(minutes: 5);
        return DateTime.now().difference(v.lastUpdated) > duration;
      }).length,
      'activeSyncs': _activeSyncs.length,
      'queuedSyncs': _syncQueue.length,
      'globalStatus': globalSyncStatus.value.name,
    };
  }
}

/// 同步任务
class SyncTask {
  final String entityType;
  final String? entityId;
  final SyncPriority priority;
  final Future<void> Function()? syncAction;
  final DateTime createdAt;

  SyncTask({
    required this.entityType,
    this.entityId,
    this.priority = SyncPriority.normal,
    this.syncAction,
  }) : createdAt = DateTime.now();
}

/// 数据变更类型
enum DataChangeType {
  created, // 新建
  updated, // 更新
  deleted, // 删除
  invalidated, // 缓存失效
}

/// 数据变更事件
class DataChangedEvent {
  final String entityType;
  final String? entityId;
  final int version;
  final DataChangeType changeType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  DataChangedEvent({
    required this.entityType,
    this.entityId,
    required this.version,
    required this.changeType,
    this.metadata,
  }) : timestamp = DateTime.now();

  String get key => entityId != null ? '$entityType:$entityId' : entityType;
}

/// 数据事件总线
///
/// 用于在不同控制器/页面之间传递数据变更通知
class DataEventBus {
  static final DataEventBus _instance = DataEventBus._internal();
  static DataEventBus get instance => _instance;

  DataEventBus._internal();

  // 事件流控制器
  final _eventController = StreamController<DataChangedEvent>.broadcast();

  // 订阅映射 (entityType -> subscriptions)
  final Map<String, List<StreamSubscription>> _subscriptions = {};

  /// 发送事件
  void emit(DataChangedEvent event) {
    log('📢 [EventBus] 发送事件: ${event.entityType} (${event.changeType.name})');
    _eventController.add(event);
  }

  /// 监听所有事件
  StreamSubscription<DataChangedEvent> listen(
    void Function(DataChangedEvent event) onEvent,
  ) {
    return _eventController.stream.listen(onEvent);
  }

  /// 监听特定实体类型的事件
  StreamSubscription<DataChangedEvent> on(
    String entityType,
    void Function(DataChangedEvent event) onEvent,
  ) {
    final subscription = _eventController.stream.where((event) => event.entityType == entityType).listen(onEvent);

    _subscriptions.putIfAbsent(entityType, () => []).add(subscription);

    return subscription;
  }

  /// 监听特定实体的事件
  StreamSubscription<DataChangedEvent> onEntity(
    String entityType,
    String entityId,
    void Function(DataChangedEvent event) onEvent,
  ) {
    final key = '$entityType:$entityId';
    final subscription = _eventController.stream.where((event) => event.key == key).listen(onEvent);

    _subscriptions.putIfAbsent(key, () => []).add(subscription);

    return subscription;
  }

  /// 取消特定实体类型的所有订阅
  void unsubscribeAll(String entityType) {
    final subs = _subscriptions[entityType];
    if (subs != null) {
      for (final sub in subs) {
        sub.cancel();
      }
      _subscriptions.remove(entityType);
    }
  }

  /// 释放资源
  void dispose() {
    for (final subs in _subscriptions.values) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
    _subscriptions.clear();
    _eventController.close();
  }
}

/// 快捷方法扩展
extension DataSyncExtension on DataSyncService {
  /// 检查并刷新数据 (如果过期)
  Future<bool> refreshIfStale(
    String entityType, {
    String? entityId,
    required Future<void> Function() refreshAction,
  }) async {
    if (isDataStale(entityType, entityId: entityId)) {
      await queueSync(
        entityType,
        entityId: entityId,
        priority: SyncPriority.high,
        syncAction: refreshAction,
      );
      return true;
    }
    return false;
  }

  /// 带版本检查的加载
  Future<T?> loadWithVersionCheck<T>(
    String entityType, {
    String? entityId,
    required Future<T> Function() loader,
    T? cachedData,
  }) async {
    if (cachedData != null && !isDataStale(entityType, entityId: entityId)) {
      log('📦 [DataSync] 使用缓存: $entityType${entityId != null ? ':$entityId' : ''}');
      return cachedData;
    }

    final data = await loader();
    markAsFresh(entityType, entityId: entityId);
    return data;
  }
}
