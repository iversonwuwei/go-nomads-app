import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/async_task/domain/entities/async_task.dart';
import 'package:go_nomads_app/features/async_task/infrastructure/models/async_task_dto.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'token_storage_service.dart';

/// SignalR 实时通知服务
/// 管理与后端 SignalR Hub 的连接,接收任务进度和完成通知
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  HubConnection? _hubConnection;
  HubConnection? _notificationHubConnection;
  bool _isConnected = false;
  bool _isNotificationHubConnected = false;
  String? _currentUserId;

  // 重连控制
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  DateTime? _lastReconnectTime;

  // 事件流控制器
  final _taskProgressController = StreamController<AsyncTask>.broadcast();
  final _taskCompletedController = StreamController<AsyncTask>.broadcast();
  final _taskFailedController = StreamController<AsyncTask>.broadcast();
  final _cityImageUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationReceivedController = StreamController<Map<String, dynamic>>.broadcast();
  final _cityRatingUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _cityReviewUpdatedController = StreamController<Map<String, dynamic>>.broadcast();

  // 事件流
  Stream<AsyncTask> get taskProgressStream => _taskProgressController.stream;
  Stream<AsyncTask> get taskCompletedStream => _taskCompletedController.stream;
  Stream<AsyncTask> get taskFailedStream => _taskFailedController.stream;
  Stream<Map<String, dynamic>> get cityImageUpdatedStream => _cityImageUpdatedController.stream;
  Stream<Map<String, dynamic>> get notificationReceivedStream => _notificationReceivedController.stream;
  Stream<Map<String, dynamic>> get cityRatingUpdatedStream => _cityRatingUpdatedController.stream;
  Stream<Map<String, dynamic>> get cityReviewUpdatedStream => _cityReviewUpdatedController.stream;

  SignalRService._internal();

  /// 连接到 SignalR Hub
  ///
  /// [baseUrl] AI Service 基础 URL,例如 'http://localhost:8009'
  /// [userId] 当前登录用户的 ID（可选，用于加入用户组）
  Future<void> connect(String baseUrl, {String? userId}) async {
    // 如果已经有连接且处于连接状态，直接返回
    if (_isConnected && _hubConnection != null) {
      log('📡 SignalR 已连接,跳过重复连接');
      // 如果已连接但用户ID变化，重新加入用户组
      if (userId != null && userId != _currentUserId) {
        await joinUserGroup(userId);
      }
      return;
    }

    // 如果已经有连接但没有 connected，先停止旧连接
    if (_hubConnection != null) {
      log('🔄 停止旧的 SignalR 连接...');
      try {
        await _hubConnection?.stop();
      } catch (e) {
        log('⚠️ 停止旧连接时出错: $e');
      }
      _hubConnection = null;
    }

    try {
      // 获取认证 token
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      // 构建 Hub URL - 使用 ai-progress hub
      final hubUrl = '$baseUrl/hubs/ai-progress';
      log('🔌 正在连接 SignalR Hub: $hubUrl');

      // 创建连接（带认证）
      _hubConnection = HubConnectionBuilder()
          .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          skipNegotiation: false,
          transport: HttpTransportType.WebSockets,
          accessTokenFactory: () async => token ?? '', // 添加认证 token
          requestTimeout: 60000, // 请求超时 60 秒
        ),
      )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000]) // 重连延迟
          .build();

      // 设置服务器超时和保持连接间隔
      _hubConnection!.serverTimeoutInMilliseconds = 60000; // 服务器超时 60 秒
      _hubConnection!.keepAliveIntervalInMilliseconds = 15000; // 保持连接间隔 15 秒

      // 注册事件处理器
      _registerEventHandlers();

      // 连接状态监听
      _hubConnection?.onclose(({error}) {
        log('❌ SignalR 连接关闭: $error');
        _isConnected = false;
        _currentUserId = null;
      });

      _hubConnection?.onreconnecting(({error}) {
        _reconnectAttempts++;
        final now = DateTime.now();

        // 检查是否在短时间内重连过多次
        if (_lastReconnectTime != null &&
            now.difference(_lastReconnectTime!).inSeconds < 10 &&
            _reconnectAttempts > _maxReconnectAttempts) {
          log('⚠️ SignalR 重连次数过多 ($_reconnectAttempts 次)，暂停重连');
          _hubConnection?.stop();
          return;
        }

        _lastReconnectTime = now;
        log('🔄 SignalR 正在重新连接 (第 $_reconnectAttempts 次): $error');
        _isConnected = false;
      });

      _hubConnection?.onreconnected(({connectionId}) {
        log('✅ SignalR 重新连接成功: $connectionId');
        _isConnected = true;
        _reconnectAttempts = 0; // 重置重连计数

        // 重连后延迟重新加入用户组，确保连接稳定
        if (_currentUserId != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (_isConnected && _currentUserId != null) {
              _joinUserGroupSafe(_currentUserId!);
            }
          });
        }
      });

      // 启动连接
      await _hubConnection?.start();
      _isConnected = true;
      _reconnectAttempts = 0; // 初始连接成功，重置计数

      log('✅ SignalR AI-Progress 连接成功! ConnectionId: ${_hubConnection?.connectionId}');

      // 连接成功后延迟加入用户组，确保连接完全就绪
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await joinUserGroup(userId);
      }

      // 同时连接 NotificationHub
      await _connectNotificationHub(baseUrl, userId: userId);
    } catch (e) {
      log('❌ SignalR 连接失败: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// 连接到 NotificationHub (使用 MessageService URL)
  Future<void> _connectNotificationHub(String baseUrl, {String? userId}) async {
    // 如果已经有连接且处于连接状态，直接返回
    if (_isNotificationHubConnected && _notificationHubConnection != null) {
      log('📡 NotificationHub 已连接,跳过重复连接');
      return;
    }

    // 如果已经有连接但没有 connected，先停止旧连接
    if (_notificationHubConnection != null) {
      log('🔄 停止旧的 NotificationHub 连接...');
      try {
        await _notificationHubConnection?.stop();
      } catch (e) {
        log('⚠️ 停止旧 NotificationHub 连接时出错: $e');
      }
      _notificationHubConnection = null;
    }

    try {
      // 获取认证 token
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      // 使用 MessageService URL 而不是 AI Service URL
      // NotificationHub 部署在 MessageService 上
      final messageServiceUrl = ApiConfig.messageServiceBaseUrl;
      final hubUrl = '$messageServiceUrl/hubs/notifications';
      log('🔌 正在连接 NotificationHub: $hubUrl');

      // 创建连接（带认证）
      _notificationHubConnection = HubConnectionBuilder()
          .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          skipNegotiation: false,
          transport: HttpTransportType.WebSockets,
          accessTokenFactory: () async => token ?? '',
          requestTimeout: 60000, // 请求超时 60 秒
        ),
      )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000]) // 重连延迟
          .build();

      // 设置服务器超时和保持连接间隔
      _notificationHubConnection!.serverTimeoutInMilliseconds = 60000; // 服务器超时 60 秒
      _notificationHubConnection!.keepAliveIntervalInMilliseconds = 15000; // 保持连接间隔 15 秒

      // 注册通知事件处理器
      _registerNotificationEventHandlers();

      // 连接状态监听
      _notificationHubConnection?.onclose(({error}) {
        log('❌ NotificationHub 连接关闭: $error');
        _isNotificationHubConnected = false;
      });

      _notificationHubConnection?.onreconnected(({connectionId}) {
        log('✅ NotificationHub 重新连接成功: $connectionId');
        _isNotificationHubConnected = true;
      });

      // 启动连接
      await _notificationHubConnection?.start();
      _isNotificationHubConnected = true;

      log('✅ NotificationHub 连接成功! ConnectionId: ${_notificationHubConnection?.connectionId}');

      // 连接成功后加入用户组（因为后端使用 AllowAnonymous，需要手动加入用户组）
      if (userId != null) {
        await _joinNotificationUserGroup(userId);
      }
    } catch (e) {
      log('❌ NotificationHub 连接失败: $e');
      _isNotificationHubConnected = false;
      // 不抛出异常，NotificationHub 连接失败不影响主要功能
    }
  }

  /// 加入 NotificationHub 用户组
  Future<void> _joinNotificationUserGroup(String userId) async {
    if (!_isNotificationHubConnected) {
      return;
    }

    try {
      await _notificationHubConnection?.invoke('JoinUserGroup', args: [userId]);
      log('✅ 已加入 NotificationHub 用户组: user-$userId');
    } catch (e) {
      log('❌ 加入 NotificationHub 用户组失败: $e');
    }
  }

  /// 注册通知事件处理器
  void _registerNotificationEventHandlers() {
    log('🔧 注册 NotificationHub 事件处理器...');

    // ReceiveNotification: 接收实时通知
    _notificationHubConnection?.on('ReceiveNotification', (arguments) {
      log('🔔 收到 ReceiveNotification 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ ReceiveNotification 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        log('📬 收到实时通知:');
        log('   Type: ${data['Type'] ?? data['type']}');
        log('   Title: ${data['Title'] ?? data['title']}');
        log('   Content: ${data['Content'] ?? data['content']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _notificationReceivedController.add(normalizedData);
      } catch (e) {
        log('❌ 解析 ReceiveNotification 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    // CityRatingUpdated: 城市评分更新
    _notificationHubConnection?.on('CityRatingUpdated', (arguments) {
      log('⭐ 收到 CityRatingUpdated 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ CityRatingUpdated 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        log('📊 收到城市评分更新:');
        log('   CityId: ${data['CityId'] ?? data['cityId']}');
        log('   OverallScore: ${data['OverallScore'] ?? data['overallScore']}');
        log('   ReviewCount: ${data['ReviewCount'] ?? data['reviewCount']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _cityRatingUpdatedController.add(normalizedData);
      } catch (e) {
        log('❌ 解析 CityRatingUpdated 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    // CityReviewUpdated: 城市评论更新
    _notificationHubConnection?.on('CityReviewUpdated', (arguments) {
      log('💬 收到 CityReviewUpdated 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ CityReviewUpdated 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        log('📝 收到城市评论更新:');
        log('   CityId: ${data['CityId'] ?? data['cityId']}');
        log('   ChangeType: ${data['ChangeType'] ?? data['changeType']}');
        log('   ReviewCount: ${data['ReviewCount'] ?? data['reviewCount']}');
        log('   OverallScore: ${data['OverallScore'] ?? data['overallScore']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _cityReviewUpdatedController.add(normalizedData);
      } catch (e) {
        log('❌ 解析 CityReviewUpdated 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    log('✅ NotificationHub 事件处理器注册完成');
  }

  /// 安全地加入用户组（带重试逻辑，用于重连后）
  Future<void> _joinUserGroupSafe(String userId, {int retryCount = 0}) async {
    if (!_isConnected || retryCount >= 3) {
      if (retryCount >= 3) {
        log('⚠️ 加入 AI-Progress 用户组重试次数已达上限');
      }
      return;
    }

    try {
      await _hubConnection?.invoke('JoinUserGroup', args: [userId]);
      log('✅ 已加入 AI-Progress 用户组: user-$userId');
    } catch (e) {
      log('⚠️ 加入 AI-Progress 用户组失败 (尝试 ${retryCount + 1}/3): $e');
      // 如果失败且连接仍然有效，延迟后重试
      if (_isConnected && retryCount < 2) {
        await Future.delayed(Duration(milliseconds: 1000 * (retryCount + 1)));
        await _joinUserGroupSafe(userId, retryCount: retryCount + 1);
      }
    }
  }

  /// 加入用户组（用于接收用户相关通知）
  Future<void> joinUserGroup(String userId) async {
    _currentUserId = userId;

    // 加入 AI-Progress Hub 用户组
    if (_isConnected) {
      try {
        await _hubConnection?.invoke('JoinUserGroup', args: [userId]);
        log('✅ 已加入 AI-Progress 用户组: user-$userId');
      } catch (e) {
        log('❌ 加入 AI-Progress 用户组失败: $e');
      }
    }

    // 加入 NotificationHub 用户组
    if (_isNotificationHubConnected) {
      await _joinNotificationUserGroup(userId);
    }
  }

  /// 离开用户组
  Future<void> leaveUserGroup(String userId) async {
    if (!_isConnected) {
      return;
    }

    try {
      await _hubConnection?.invoke('LeaveUserGroup', args: [userId]);
      if (_currentUserId == userId) {
        _currentUserId = null;
      }
      log('✅ 已离开用户组: user-$userId');
    } catch (e) {
      log('❌ 离开用户组失败: $e');
    }
  }

  /// 注册 SignalR 事件处理器
  void _registerEventHandlers() {
    log('🔧 注册 SignalR 事件处理器...');

    // TaskProgress: 任务进度更新
    _hubConnection?.on('TaskProgress', (arguments) {
      log('🎯 收到 TaskProgress 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ TaskProgress 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        log('📊 原始 TaskProgress JSON数据:');
        log('   完整JSON: $data');
        log('   progress: ${data['progress'] ?? data['Progress']}');
        log('   completed (小写): ${data['completed']}');
        log('   Completed (大写): ${data['Completed']}');

        final taskDto = AsyncTaskDto.fromJson(data);
        final task = taskDto.toDomain();

        log('📊 收到任务进度: ${task.taskId} - ${task.progress.percentage}%');
        log('   消息: ${task.progress.message}');
        log('   ✅ completed字段: ${task.progress.completed}');
        _taskProgressController.add(task);
      } catch (e) {
        log('❌ 解析 TaskProgress 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    // TaskCompleted: 任务完成
    _hubConnection?.on('TaskCompleted', (arguments) {
      log('🎯 收到 TaskCompleted 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ TaskCompleted 参数为空');
        return;
      }

      try {
        log('📦 收到 TaskCompleted 事件，原始数据:');
        log('   arguments 长度: ${arguments.length}');
        if (arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          log('   原始 JSON keys: ${data.keys.toList()}');
          log('   完整数据: ${data.toString().substring(0, data.toString().length > 500 ? 500 : data.toString().length)}...');

          final taskDto = AsyncTaskDto.fromJson(data);
          final task = taskDto.toDomain();

          log('✅ 收到任务完成通知: ${task.taskId}');
          log('   - planId: ${task.result?.planId}');
          log('   - guideId: ${task.result?.guideId}');
          log('   - hasRawData: ${task.result?.hasRawData}');
          if (task.result?.rawData != null) {
            log('   - rawData keys: ${task.result!.rawData!.keys.toList()}');
          }

          _taskCompletedController.add(task);
        }
      } catch (e, stackTrace) {
        log('❌ 解析 TaskCompleted 失败: $e');
        log('   StackTrace: $stackTrace');
        log('   原始数据: ${arguments[0]}');
      }
    });

    // TaskFailed: 任务失败
    _hubConnection?.on('TaskFailed', (arguments) {
      log('🎯 收到 TaskFailed 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ TaskFailed 参数为空');
        return;
      }

      try {
        log('❌ 原始 TaskFailed 数据: ${arguments[0]}');
        final data = arguments[0] as Map<String, dynamic>;
        final taskDto = AsyncTaskDto.fromJson(data);
        final task = taskDto.toDomain();

        log('❌ 收到任务失败通知: ${task.taskId} - ${task.error}');
        _taskFailedController.add(task);
      } catch (e) {
        log('❌ 解析 TaskFailed 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    // CityImageUpdated: 城市图片更新完成
    _hubConnection?.on('CityImageUpdated', (arguments) {
      log('🎯 收到 CityImageUpdated 事件！');
      log('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        log('❌ CityImageUpdated 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        log('🖼️ 收到城市图片更新通知:');
        log('   CityId: ${data['CityId'] ?? data['cityId']}');
        log('   CityName: ${data['CityName'] ?? data['cityName']}');
        log('   Success: ${data['Success'] ?? data['success']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          // 转换 PascalCase 到 camelCase
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _cityImageUpdatedController.add(normalizedData);
      } catch (e) {
        log('❌ 解析 CityImageUpdated 失败: $e');
        log('   原始数据: ${arguments[0]}');
      }
    });

    log('✅ SignalR 事件处理器注册完成');
  }

  /// 订阅任务通知
  ///
  /// [taskId] 任务 ID
  Future<void> subscribeToTask(String taskId) async {
    if (!_isConnected) {
      log('❌ SignalR 未连接,无法订阅任务: $taskId');
      return;
    }

    try {
      await _hubConnection?.invoke('SubscribeToTask', args: [taskId]);
      log('✅ 已订阅任务通知: $taskId');
    } catch (e) {
      log('❌ 订阅任务失败: $taskId, 错误: $e');
      rethrow;
    }
  }

  /// 取消订阅任务通知
  ///
  /// [taskId] 任务 ID
  Future<void> unsubscribeFromTask(String taskId) async {
    if (!_isConnected) {
      log('📡 SignalR 未连接,跳过取消订阅: $taskId');
      return;
    }

    try {
      await _hubConnection?.invoke('UnsubscribeFromTask', args: [taskId]);
      log('✅ 已取消订阅任务通知: $taskId');
    } catch (e) {
      log('❌ 取消订阅任务失败: $taskId, 错误: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    // 断开 AI-Progress Hub
    if (_isConnected) {
      try {
        await _hubConnection?.stop();
        _isConnected = false;
        log('✅ AI-Progress Hub 已断开');
      } catch (e) {
        log('❌ AI-Progress Hub 断开失败: $e');
      }
    }

    // 断开 NotificationHub
    if (_isNotificationHubConnected) {
      try {
        await _notificationHubConnection?.stop();
        _isNotificationHubConnected = false;
        log('✅ NotificationHub 已断开');
      } catch (e) {
        log('❌ NotificationHub 断开失败: $e');
      }
    }
  }

  /// 获取连接状态
  bool get isConnected => _isConnected;

  /// 获取 NotificationHub 连接状态
  bool get isNotificationHubConnected => _isNotificationHubConnected;

  /// 获取 ConnectionId (用于后端关联)
  String? get connectionId => _hubConnection?.connectionId;

  /// 释放资源
  void dispose() {
    _taskProgressController.close();
    _taskCompletedController.close();
    _taskFailedController.close();
    _cityImageUpdatedController.close();
    _notificationReceivedController.close();
    _cityRatingUpdatedController.close();
    _cityReviewUpdatedController.close();
    disconnect();
  }
}
