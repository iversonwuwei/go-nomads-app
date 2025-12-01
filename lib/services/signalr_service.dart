import 'dart:async';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/features/async_task/domain/entities/async_task.dart';
import 'package:df_admin_mobile/features/async_task/infrastructure/models/async_task_dto.dart';
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

  // 事件流控制器
  final _taskProgressController = StreamController<AsyncTask>.broadcast();
  final _taskCompletedController = StreamController<AsyncTask>.broadcast();
  final _taskFailedController = StreamController<AsyncTask>.broadcast();
  final _cityImageUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationReceivedController = StreamController<Map<String, dynamic>>.broadcast();

  // 事件流
  Stream<AsyncTask> get taskProgressStream => _taskProgressController.stream;
  Stream<AsyncTask> get taskCompletedStream => _taskCompletedController.stream;
  Stream<AsyncTask> get taskFailedStream => _taskFailedController.stream;
  Stream<Map<String, dynamic>> get cityImageUpdatedStream => _cityImageUpdatedController.stream;
  Stream<Map<String, dynamic>> get notificationReceivedStream => _notificationReceivedController.stream;

  SignalRService._internal();

  /// 连接到 SignalR Hub
  ///
  /// [baseUrl] AI Service 基础 URL,例如 'http://localhost:8009'
  /// [userId] 当前登录用户的 ID（可选，用于加入用户组）
  Future<void> connect(String baseUrl, {String? userId}) async {
    if (_isConnected) {
      print('📡 SignalR 已连接,跳过重复连接');
      // 如果已连接但用户ID变化，重新加入用户组
      if (userId != null && userId != _currentUserId) {
        await joinUserGroup(userId);
      }
      return;
    }

    try {
      // 获取认证 token
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      // 构建 Hub URL - 使用 ai-progress hub
      final hubUrl = '$baseUrl/hubs/ai-progress';
      print('🔌 正在连接 SignalR Hub: $hubUrl');

      // 创建连接（带认证）
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
              accessTokenFactory: () async => token ?? '', // 添加认证 token
            ),
          )
          .withAutomaticReconnect()
          .build();

      // 注册事件处理器
      _registerEventHandlers();

      // 连接状态监听
      _hubConnection?.onclose(({error}) {
        print('❌ SignalR 连接关闭: $error');
        _isConnected = false;
        _currentUserId = null;
      });

      _hubConnection?.onreconnecting(({error}) {
        print('🔄 SignalR 正在重新连接: $error');
        _isConnected = false;
      });

      _hubConnection?.onreconnected(({connectionId}) async {
        print('✅ SignalR 重新连接成功: $connectionId');
        _isConnected = true;
        // 重连后重新加入用户组
        if (_currentUserId != null) {
          await joinUserGroup(_currentUserId!);
        }
      });

      // 启动连接
      await _hubConnection?.start();
      _isConnected = true;

      print('✅ SignalR AI-Progress 连接成功! ConnectionId: ${_hubConnection?.connectionId}');

      // 连接成功后加入用户组
      if (userId != null) {
        await joinUserGroup(userId);
      }

      // 同时连接 NotificationHub
      await _connectNotificationHub(baseUrl, userId: userId);
    } catch (e) {
      print('❌ SignalR 连接失败: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// 连接到 NotificationHub (使用 MessageService URL)
  Future<void> _connectNotificationHub(String baseUrl, {String? userId}) async {
    if (_isNotificationHubConnected) {
      print('📡 NotificationHub 已连接,跳过重复连接');
      return;
    }

    try {
      // 获取认证 token
      final tokenService = TokenStorageService();
      final token = await tokenService.getAccessToken();

      // 使用 MessageService URL 而不是 AI Service URL
      // NotificationHub 部署在 MessageService 上
      final messageServiceUrl = ApiConfig.messageServiceBaseUrl;
      final hubUrl = '$messageServiceUrl/hubs/notifications';
      print('🔌 正在连接 NotificationHub: $hubUrl');

      // 创建连接（带认证）
      _notificationHubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
              accessTokenFactory: () async => token ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      // 注册通知事件处理器
      _registerNotificationEventHandlers();

      // 连接状态监听
      _notificationHubConnection?.onclose(({error}) {
        print('❌ NotificationHub 连接关闭: $error');
        _isNotificationHubConnected = false;
      });

      _notificationHubConnection?.onreconnected(({connectionId}) {
        print('✅ NotificationHub 重新连接成功: $connectionId');
        _isNotificationHubConnected = true;
      });

      // 启动连接
      await _notificationHubConnection?.start();
      _isNotificationHubConnected = true;

      print('✅ NotificationHub 连接成功! ConnectionId: ${_notificationHubConnection?.connectionId}');

      // 连接成功后加入用户组（因为后端使用 AllowAnonymous，需要手动加入用户组）
      if (userId != null) {
        await _joinNotificationUserGroup(userId);
      }
    } catch (e) {
      print('❌ NotificationHub 连接失败: $e');
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
      print('✅ 已加入 NotificationHub 用户组: user-$userId');
    } catch (e) {
      print('❌ 加入 NotificationHub 用户组失败: $e');
    }
  }

  /// 注册通知事件处理器
  void _registerNotificationEventHandlers() {
    print('🔧 注册 NotificationHub 事件处理器...');

    // ReceiveNotification: 接收实时通知
    _notificationHubConnection?.on('ReceiveNotification', (arguments) {
      print('🔔 收到 ReceiveNotification 事件！');
      print('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        print('❌ ReceiveNotification 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        print('📬 收到实时通知:');
        print('   Type: ${data['Type'] ?? data['type']}');
        print('   Title: ${data['Title'] ?? data['title']}');
        print('   Content: ${data['Content'] ?? data['content']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _notificationReceivedController.add(normalizedData);
      } catch (e) {
        print('❌ 解析 ReceiveNotification 失败: $e');
        print('   原始数据: ${arguments[0]}');
      }
    });

    print('✅ NotificationHub 事件处理器注册完成');
  }

  /// 加入用户组（用于接收用户相关通知）
  Future<void> joinUserGroup(String userId) async {
    _currentUserId = userId;

    // 加入 AI-Progress Hub 用户组
    if (_isConnected) {
      try {
        await _hubConnection?.invoke('JoinUserGroup', args: [userId]);
        print('✅ 已加入 AI-Progress 用户组: user-$userId');
      } catch (e) {
        print('❌ 加入 AI-Progress 用户组失败: $e');
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
      print('✅ 已离开用户组: user-$userId');
    } catch (e) {
      print('❌ 离开用户组失败: $e');
    }
  }

  /// 注册 SignalR 事件处理器
  void _registerEventHandlers() {
    print('🔧 注册 SignalR 事件处理器...');

    // TaskProgress: 任务进度更新
    _hubConnection?.on('TaskProgress', (arguments) {
      print('🎯 收到 TaskProgress 事件！');
      print('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        print('❌ TaskProgress 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        print('📊 原始 TaskProgress JSON数据:');
        print('   完整JSON: $data');
        print('   progress: ${data['progress'] ?? data['Progress']}');
        print('   completed (小写): ${data['completed']}');
        print('   Completed (大写): ${data['Completed']}');

        final taskDto = AsyncTaskDto.fromJson(data);
        final task = taskDto.toDomain();

        print('📊 收到任务进度: ${task.taskId} - ${task.progress.percentage}%');
        print('   消息: ${task.progress.message}');
        print('   ✅ completed字段: ${task.progress.completed}');
        _taskProgressController.add(task);
      } catch (e) {
        print('❌ 解析 TaskProgress 失败: $e');
        print('   原始数据: ${arguments[0]}');
      }
    });

    // TaskCompleted: 任务完成
    _hubConnection?.on('TaskCompleted', (arguments) {
      print('🎯 收到 TaskCompleted 事件！');
      print('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        print('❌ TaskCompleted 参数为空');
        return;
      }

      try {
        print('📦 收到 TaskCompleted 事件，原始数据:');
        print('   arguments 长度: ${arguments.length}');
        if (arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          print('   原始 JSON keys: ${data.keys.toList()}');
          print(
              '   完整数据: ${data.toString().substring(0, data.toString().length > 500 ? 500 : data.toString().length)}...');

          final taskDto = AsyncTaskDto.fromJson(data);
          final task = taskDto.toDomain();

          print('✅ 收到任务完成通知: ${task.taskId}');
          print('   - planId: ${task.result?.planId}');
          print('   - guideId: ${task.result?.guideId}');
          print('   - hasRawData: ${task.result?.hasRawData}');
          if (task.result?.rawData != null) {
            print('   - rawData keys: ${task.result!.rawData!.keys.toList()}');
          }

          _taskCompletedController.add(task);
        }
      } catch (e, stackTrace) {
        print('❌ 解析 TaskCompleted 失败: $e');
        print('   StackTrace: $stackTrace');
        print('   原始数据: ${arguments[0]}');
      }
    });

    // TaskFailed: 任务失败
    _hubConnection?.on('TaskFailed', (arguments) {
      print('🎯 收到 TaskFailed 事件！');
      print('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        print('❌ TaskFailed 参数为空');
        return;
      }

      try {
        print('❌ 原始 TaskFailed 数据: ${arguments[0]}');
        final data = arguments[0] as Map<String, dynamic>;
        final taskDto = AsyncTaskDto.fromJson(data);
        final task = taskDto.toDomain();

        print('❌ 收到任务失败通知: ${task.taskId} - ${task.error}');
        _taskFailedController.add(task);
      } catch (e) {
        print('❌ 解析 TaskFailed 失败: $e');
        print('   原始数据: ${arguments[0]}');
      }
    });

    // CityImageUpdated: 城市图片更新完成
    _hubConnection?.on('CityImageUpdated', (arguments) {
      print('🎯 收到 CityImageUpdated 事件！');
      print('   参数数量: ${arguments?.length ?? 0}');

      if (arguments == null || arguments.isEmpty) {
        print('❌ CityImageUpdated 参数为空');
        return;
      }

      try {
        final data = arguments[0] as Map<String, dynamic>;
        print('🖼️ 收到城市图片更新通知:');
        print('   CityId: ${data['CityId'] ?? data['cityId']}');
        print('   CityName: ${data['CityName'] ?? data['cityName']}');
        print('   Success: ${data['Success'] ?? data['success']}');

        // 转换为小写 key 的 map
        final normalizedData = <String, dynamic>{};
        data.forEach((key, value) {
          // 转换 PascalCase 到 camelCase
          final normalizedKey = key[0].toLowerCase() + key.substring(1);
          normalizedData[normalizedKey] = value;
        });

        _cityImageUpdatedController.add(normalizedData);
      } catch (e) {
        print('❌ 解析 CityImageUpdated 失败: $e');
        print('   原始数据: ${arguments[0]}');
      }
    });

    print('✅ SignalR 事件处理器注册完成');
  }

  /// 订阅任务通知
  ///
  /// [taskId] 任务 ID
  Future<void> subscribeToTask(String taskId) async {
    if (!_isConnected) {
      print('❌ SignalR 未连接,无法订阅任务: $taskId');
      return;
    }

    try {
      await _hubConnection?.invoke('SubscribeToTask', args: [taskId]);
      print('✅ 已订阅任务通知: $taskId');
    } catch (e) {
      print('❌ 订阅任务失败: $taskId, 错误: $e');
      rethrow;
    }
  }

  /// 取消订阅任务通知
  ///
  /// [taskId] 任务 ID
  Future<void> unsubscribeFromTask(String taskId) async {
    if (!_isConnected) {
      print('📡 SignalR 未连接,跳过取消订阅: $taskId');
      return;
    }

    try {
      await _hubConnection?.invoke('UnsubscribeFromTask', args: [taskId]);
      print('✅ 已取消订阅任务通知: $taskId');
    } catch (e) {
      print('❌ 取消订阅任务失败: $taskId, 错误: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    // 断开 AI-Progress Hub
    if (_isConnected) {
      try {
        await _hubConnection?.stop();
        _isConnected = false;
        print('✅ AI-Progress Hub 已断开');
      } catch (e) {
        print('❌ AI-Progress Hub 断开失败: $e');
      }
    }

    // 断开 NotificationHub
    if (_isNotificationHubConnected) {
      try {
        await _notificationHubConnection?.stop();
        _isNotificationHubConnected = false;
        print('✅ NotificationHub 已断开');
      } catch (e) {
        print('❌ NotificationHub 断开失败: $e');
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
    disconnect();
  }
}
