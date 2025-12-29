import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/sync/data_sync_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// 数据同步 SignalR 服务
///
/// 提供实时数据同步能力，当其他设备或用户更新数据时，
/// 通过 SignalR 接收通知并更新本地缓存
class DataSyncSignalRService {
  static final DataSyncSignalRService _instance = DataSyncSignalRService._internal();
  static DataSyncSignalRService get instance => _instance;

  DataSyncSignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _currentUserId;

  // 重连控制
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  DateTime? _lastReconnectTime;

  // 事件流控制器
  final _dataChangedController = StreamController<RemoteDataChange>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  // 事件流
  Stream<RemoteDataChange> get dataChangedStream => _dataChangedController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// 连接状态
  bool get isConnected => _isConnected;

  /// 连接到数据同步 Hub
  Future<void> connect({String? userId}) async {
    if (_isConnected && _hubConnection != null) {
      log('📡 [DataSyncSignalR] 已连接，跳过');
      if (userId != null && userId != _currentUserId) {
        await joinUserGroup(userId);
      }
      return;
    }

    if (_hubConnection != null) {
      try {
        await _hubConnection?.stop();
      } catch (e) {
        log('⚠️ [DataSyncSignalR] 停止旧连接失败: $e');
      }
      _hubConnection = null;
    }

    try {
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      // 使用 Gateway 的数据同步 Hub
      final hubUrl = '${ApiConfig.baseUrl}/hubs/data-sync';
      log('🔌 [DataSyncSignalR] 正在连接: $hubUrl');

      _hubConnection = HubConnectionBuilder()
          .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          skipNegotiation: false,
          transport: HttpTransportType.WebSockets,
          accessTokenFactory: () async => token ?? '',
          requestTimeout: 60000,
        ),
      )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000]).build();

      _hubConnection!.serverTimeoutInMilliseconds = 60000;
      _hubConnection!.keepAliveIntervalInMilliseconds = 15000;

      _registerEventHandlers();
      _setupConnectionListeners();

      await _hubConnection?.start();
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStateController.add(true);

      log('✅ [DataSyncSignalR] 连接成功: ${_hubConnection?.connectionId}');

      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await joinUserGroup(userId);
      }
    } catch (e) {
      log('❌ [DataSyncSignalR] 连接失败: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 设置连接监听
  void _setupConnectionListeners() {
    _hubConnection?.onclose(({error}) {
      log('❌ [DataSyncSignalR] 连接关闭: $error');
      _isConnected = false;
      _currentUserId = null;
      _connectionStateController.add(false);
    });

    _hubConnection?.onreconnecting(({error}) {
      _reconnectAttempts++;
      final now = DateTime.now();

      if (_lastReconnectTime != null &&
          now.difference(_lastReconnectTime!).inSeconds < 10 &&
          _reconnectAttempts > _maxReconnectAttempts) {
        log('⚠️ [DataSyncSignalR] 重连次数过多，暂停');
        _hubConnection?.stop();
        return;
      }

      _lastReconnectTime = now;
      log('🔄 [DataSyncSignalR] 正在重连 (第 $_reconnectAttempts 次)');
      _isConnected = false;
      _connectionStateController.add(false);
    });

    _hubConnection?.onreconnected(({connectionId}) {
      log('✅ [DataSyncSignalR] 重连成功: $connectionId');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStateController.add(true);

      if (_currentUserId != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_isConnected && _currentUserId != null) {
            joinUserGroup(_currentUserId!);
          }
        });
      }
    });
  }

  /// 注册事件处理器
  void _registerEventHandlers() {
    // 数据变更事件
    _hubConnection?.on('DataChanged', (arguments) {
      log('📬 [DataSyncSignalR] 收到 DataChanged 事件');

      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final change = RemoteDataChange.fromJson(data);

        log('📊 [DataSyncSignalR] 数据变更:');
        log('   - EntityType: ${change.entityType}');
        log('   - EntityId: ${change.entityId}');
        log('   - ChangeType: ${change.changeType}');
        log('   - Version: ${change.version}');

        _dataChangedController.add(change);

        // 自动使本地缓存失效
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: change.entityType,
          entityId: change.entityId,
          version: change.version,
          changeType: _mapChangeType(change.changeType),
          metadata: change.payload,
        ));
      } catch (e) {
        log('❌ [DataSyncSignalR] 解析 DataChanged 失败: $e');
      }
    });

    // 批量数据变更
    _hubConnection?.on('BatchDataChanged', (arguments) {
      log('📬 [DataSyncSignalR] 收到 BatchDataChanged 事件');

      if (arguments == null || arguments.isEmpty) return;

      try {
        final dataList = arguments[0] as List<dynamic>;

        for (final item in dataList) {
          final change = RemoteDataChange.fromJson(item as Map<String, dynamic>);
          _dataChangedController.add(change);

          DataEventBus.instance.emit(DataChangedEvent(
            entityType: change.entityType,
            entityId: change.entityId,
            version: change.version,
            changeType: _mapChangeType(change.changeType),
            metadata: change.payload,
          ));
        }

        log('📊 [DataSyncSignalR] 批量处理 ${dataList.length} 条变更');
      } catch (e) {
        log('❌ [DataSyncSignalR] 解析 BatchDataChanged 失败: $e');
      }
    });

    // 全量同步请求
    _hubConnection?.on('RequestFullSync', (arguments) {
      log('🔄 [DataSyncSignalR] 收到全量同步请求');

      if (arguments != null && arguments.isNotEmpty) {
        final entityTypes = (arguments[0] as List<dynamic>).cast<String>();
        for (final entityType in entityTypes) {
          DataSyncService.instance.invalidateRelated(entityType);
        }
      } else {
        // 使所有缓存失效
        DataSyncService.instance.clearAll();
      }
    });

    log('✅ [DataSyncSignalR] 事件处理器注册完成');
  }

  DataChangeType _mapChangeType(String remoteType) {
    switch (remoteType.toLowerCase()) {
      case 'created':
        return DataChangeType.created;
      case 'updated':
        return DataChangeType.updated;
      case 'deleted':
        return DataChangeType.deleted;
      default:
        return DataChangeType.updated;
    }
  }

  /// 加入用户组
  Future<void> joinUserGroup(String userId) async {
    _currentUserId = userId;

    if (!_isConnected) return;

    try {
      await _hubConnection?.invoke('JoinUserGroup', args: [userId]);
      log('✅ [DataSyncSignalR] 已加入用户组: user-$userId');
    } catch (e) {
      log('❌ [DataSyncSignalR] 加入用户组失败: $e');
    }
  }

  /// 离开用户组
  Future<void> leaveUserGroup(String userId) async {
    if (!_isConnected) return;

    try {
      await _hubConnection?.invoke('LeaveUserGroup', args: [userId]);
      if (_currentUserId == userId) {
        _currentUserId = null;
      }
      log('✅ [DataSyncSignalR] 已离开用户组: user-$userId');
    } catch (e) {
      log('❌ [DataSyncSignalR] 离开用户组失败: $e');
    }
  }

  /// 订阅实体变更
  Future<void> subscribeEntity(String entityType, {String? entityId}) async {
    if (!_isConnected) return;

    try {
      final List<Object> args = entityId != null ? [entityType, entityId] : [entityType];
      await _hubConnection?.invoke('Subscribe', args: args);
      log('✅ [DataSyncSignalR] 已订阅: $entityType${entityId != null ? ':$entityId' : ''}');
    } catch (e) {
      log('❌ [DataSyncSignalR] 订阅失败: $e');
    }
  }

  /// 取消订阅实体变更
  Future<void> unsubscribeEntity(String entityType, {String? entityId}) async {
    if (!_isConnected) return;

    try {
      final List<Object> args = entityId != null ? [entityType, entityId] : [entityType];
      await _hubConnection?.invoke('Unsubscribe', args: args);
      log('✅ [DataSyncSignalR] 已取消订阅: $entityType${entityId != null ? ':$entityId' : ''}');
    } catch (e) {
      log('❌ [DataSyncSignalR] 取消订阅失败: $e');
    }
  }

  /// 广播数据变更（通知其他设备）
  Future<void> broadcastChange(
    String entityType, {
    String? entityId,
    required String changeType,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isConnected) return;

    try {
      await _hubConnection?.invoke('BroadcastChange', args: [
        {
          'entityType': entityType,
          'entityId': entityId,
          'changeType': changeType,
          'payload': payload,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]);
      log('📤 [DataSyncSignalR] 已广播变更: $entityType${entityId != null ? ':$entityId' : ''}');
    } catch (e) {
      log('❌ [DataSyncSignalR] 广播变更失败: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_isConnected) {
      try {
        await _hubConnection?.stop();
        _isConnected = false;
        _connectionStateController.add(false);
        log('✅ [DataSyncSignalR] 已断开');
      } catch (e) {
        log('❌ [DataSyncSignalR] 断开失败: $e');
      }
    }
  }

  /// 释放资源
  void dispose() {
    _dataChangedController.close();
    _connectionStateController.close();
    disconnect();
  }
}

/// 远程数据变更
class RemoteDataChange {
  final String entityType;
  final String? entityId;
  final String changeType;
  final int version;
  final Map<String, dynamic>? payload;
  final DateTime timestamp;
  final String? sourceUserId;
  final String? sourceDeviceId;

  RemoteDataChange({
    required this.entityType,
    this.entityId,
    required this.changeType,
    required this.version,
    this.payload,
    required this.timestamp,
    this.sourceUserId,
    this.sourceDeviceId,
  });

  factory RemoteDataChange.fromJson(Map<String, dynamic> json) {
    return RemoteDataChange(
      entityType: json['entityType'] as String? ?? json['EntityType'] as String,
      entityId: json['entityId'] as String? ?? json['EntityId'] as String?,
      changeType: json['changeType'] as String? ?? json['ChangeType'] as String? ?? 'updated',
      version: json['version'] as int? ?? json['Version'] as int? ?? 0,
      payload: json['payload'] as Map<String, dynamic>? ?? json['Payload'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : json['Timestamp'] != null
              ? DateTime.parse(json['Timestamp'] as String)
              : DateTime.now(),
      sourceUserId: json['sourceUserId'] as String? ?? json['SourceUserId'] as String?,
      sourceDeviceId: json['sourceDeviceId'] as String? ?? json['SourceDeviceId'] as String?,
    );
  }

  String get key => entityId != null ? '$entityType:$entityId' : entityType;
}
