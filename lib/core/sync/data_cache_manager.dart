import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/core/sync/data_sync_service.dart';

/// 缓存条目
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int version;
  final Map<String, dynamic>? metadata;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.version = 0,
    this.metadata,
  });

  /// 是否过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 剩余有效时间
  Duration? get remainingTime {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 更新数据
  CacheEntry<T> copyWith({
    T? data,
    DateTime? expiresAt,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return CacheEntry(
      data: data ?? this.data,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 缓存策略
enum CachePolicy {
  /// 仅内存缓存
  memoryOnly,

  /// 持久化缓存（存储到本地）
  persistent,

  /// 网络优先（先请求网络，失败时使用缓存）
  networkFirst,

  /// 缓存优先（先使用缓存，过期时请求网络）
  cacheFirst,

  /// 缓存和网络（先返回缓存，同时请求网络更新）
  staleWhileRevalidate,
}

/// 数据缓存管理器
///
/// 提供统一的内存缓存管理，支持:
/// - 自动过期清理
/// - 容量限制
/// - LRU 淘汰策略
/// - 与 DataSyncService 集成
class DataCacheManager {
  static final DataCacheManager _instance = DataCacheManager._internal();
  static DataCacheManager get instance => _instance;

  DataCacheManager._internal() {
    _startCleanupTimer();
  }

  // 缓存存储
  final Map<String, CacheEntry<dynamic>> _cache = {};

  // 访问顺序（用于 LRU）
  final List<String> _accessOrder = [];

  // 配置
  int _maxEntries = 500;
  Duration _defaultTtl = const Duration(minutes: 5);
  Timer? _cleanupTimer;

  /// 设置最大缓存条目数
  void setMaxEntries(int max) {
    _maxEntries = max;
    _enforceCapacity();
  }

  /// 设置默认 TTL
  void setDefaultTtl(Duration ttl) {
    _defaultTtl = ttl;
  }

  /// 获取缓存数据
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      log('🔍 [Cache] 未命中: $key');
      return null;
    }

    if (entry.isExpired) {
      log('⏰ [Cache] 已过期: $key');
      _cache.remove(key);
      _accessOrder.remove(key);
      return null;
    }

    // 更新访问顺序
    _accessOrder.remove(key);
    _accessOrder.add(key);

    log('✅ [Cache] 命中: $key (剩余: ${entry.remainingTime?.inSeconds}s)');
    return entry.data as T?;
  }

  /// 存储缓存数据
  void set<T>(
    String key,
    T data, {
    Duration? ttl,
    int version = 0,
    Map<String, dynamic>? metadata,
  }) {
    final effectiveTtl = ttl ?? _defaultTtl;
    final expiresAt = effectiveTtl.inSeconds > 0 ? DateTime.now().add(effectiveTtl) : null;

    _cache[key] = CacheEntry<T>(
      data: data,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      version: version,
      metadata: metadata,
    );

    // 更新访问顺序
    _accessOrder.remove(key);
    _accessOrder.add(key);

    log('💾 [Cache] 存储: $key (TTL: ${effectiveTtl.inSeconds}s)');

    // 检查容量
    _enforceCapacity();
  }

  /// 获取或加载数据
  Future<T> getOrLoad<T>(
    String key, {
    required Future<T> Function() loader,
    Duration? ttl,
    CachePolicy policy = CachePolicy.cacheFirst,
  }) async {
    switch (policy) {
      case CachePolicy.memoryOnly:
      case CachePolicy.cacheFirst:
        final cached = get<T>(key);
        if (cached != null) {
          return cached;
        }
        final data = await loader();
        set(key, data, ttl: ttl);
        return data;

      case CachePolicy.networkFirst:
        try {
          final data = await loader();
          set(key, data, ttl: ttl);
          return data;
        } catch (e) {
          final cached = get<T>(key);
          if (cached != null) {
            log('⚠️ [Cache] 网络失败，使用缓存: $key');
            return cached;
          }
          rethrow;
        }

      case CachePolicy.staleWhileRevalidate:
        final cached = get<T>(key);

        // 异步更新
        loader().then((data) {
          set(key, data, ttl: ttl);
        }).catchError((e) {
          log('⚠️ [Cache] 后台更新失败: $key - $e');
        });

        if (cached != null) {
          return cached;
        }
        // 没有缓存时同步加载
        return await loader();

      case CachePolicy.persistent:
        // TODO: 实现持久化缓存
        final data = await loader();
        set(key, data, ttl: ttl);
        return data;
    }
  }

  /// 检查缓存是否存在且有效
  bool has(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// 获取缓存条目信息
  CacheEntry<dynamic>? getEntry(String key) {
    return _cache[key];
  }

  /// 删除缓存
  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
    log('🗑️ [Cache] 删除: $key');
  }

  /// 删除匹配的缓存
  void removeWhere(bool Function(String key, CacheEntry<dynamic> entry) test) {
    final keysToRemove = <String>[];

    _cache.forEach((key, entry) {
      if (test(key, entry)) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      log('🗑️ [Cache] 批量删除: ${keysToRemove.length} 条');
    }
  }

  /// 删除指定前缀的缓存
  void removeByPrefix(String prefix) {
    removeWhere((key, _) => key.startsWith(prefix));
  }

  /// 使缓存失效（标记为过期但不删除）
  void invalidate(String key) {
    final entry = _cache[key];
    if (entry != null) {
      _cache[key] = entry.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      log('⏰ [Cache] 标记失效: $key');

      // 通知 DataSyncService
      final parts = key.split(':');
      if (parts.isNotEmpty) {
        DataSyncService.instance.invalidateCache(
          parts[0],
          entityId: parts.length > 1 ? parts.sublist(1).join(':') : null,
        );
      }
    }
  }

  /// 批量使缓存失效
  void invalidateByPrefix(String prefix) {
    _cache.forEach((key, _) {
      if (key.startsWith(prefix)) {
        invalidate(key);
      }
    });
  }

  /// 清除所有缓存
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    log('🧹 [Cache] 已清空');
  }

  /// 清除过期缓存
  int cleanupExpired() {
    final keysToRemove = <String>[];

    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      log('🧹 [Cache] 清理过期: ${keysToRemove.length} 条');
    }

    return keysToRemove.length;
  }

  /// 强制执行容量限制（LRU 淘汰）
  void _enforceCapacity() {
    while (_cache.length > _maxEntries && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
      log('🗑️ [Cache] LRU 淘汰: $oldest');
    }
  }

  /// 启动定期清理定时器
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => cleanupExpired(),
    );
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    int validCount = 0;
    int expiredCount = 0;
    int totalSize = 0;

    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
      // 粗略估算大小（实际生产中需要更精确的计算）
      totalSize += key.length * 2; // 假设每个字符2字节
    });

    return {
      'totalEntries': _cache.length,
      'validEntries': validCount,
      'expiredEntries': expiredCount,
      'maxEntries': _maxEntries,
      'defaultTtlSeconds': _defaultTtl.inSeconds,
      'estimatedSizeBytes': totalSize,
    };
  }

  /// 释放资源
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _accessOrder.clear();
  }
}

/// 缓存键构建器
class CacheKeyBuilder {
  final List<String> _parts = [];

  CacheKeyBuilder(String entityType) {
    _parts.add(entityType);
  }

  CacheKeyBuilder id(String id) {
    _parts.add(id);
    return this;
  }

  CacheKeyBuilder page(int page) {
    _parts.add('p$page');
    return this;
  }

  CacheKeyBuilder param(String key, dynamic value) {
    if (value != null) {
      _parts.add('$key=$value');
    }
    return this;
  }

  String build() {
    return _parts.join(':');
  }
}

/// 快捷方法扩展
extension CacheKeyExtension on String {
  CacheKeyBuilder get cacheKey => CacheKeyBuilder(this);
}
