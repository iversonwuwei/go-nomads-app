import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../models/async_task_models.dart';

/// SignalR 实时通知服务
/// 管理与后端 SignalR Hub 的连接,接收任务进度和完成通知
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // 事件流控制器
  final _taskProgressController = StreamController<TaskStatus>.broadcast();
  final _taskCompletedController = StreamController<TaskStatus>.broadcast();
  final _taskFailedController = StreamController<TaskStatus>.broadcast();

  // 事件流
  Stream<TaskStatus> get taskProgressStream => _taskProgressController.stream;
  Stream<TaskStatus> get taskCompletedStream => _taskCompletedController.stream;
  Stream<TaskStatus> get taskFailedStream => _taskFailedController.stream;

  SignalRService._internal();

  /// 连接到 SignalR Hub
  ///
  /// [baseUrl] AI Service 基础 URL,例如 'http://localhost:8009'
  Future<void> connect(String baseUrl) async {
    if (_isConnected) {
      print('📡 SignalR 已连接,跳过重复连接');
      return;
    }

    try {
      // 构建 Hub URL
      final hubUrl = '$baseUrl/hubs/notifications';
      print('🔌 正在连接 SignalR Hub: $hubUrl');

      // 创建连接
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              skipNegotiation: false,
              transport: HttpTransportType.WebSockets,
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
      });

      _hubConnection?.onreconnecting(({error}) {
        print('🔄 SignalR 正在重新连接: $error');
        _isConnected = false;
      });

      _hubConnection?.onreconnected(({connectionId}) {
        print('✅ SignalR 重新连接成功: $connectionId');
        _isConnected = true;
      });

      // 启动连接
      await _hubConnection?.start();
      _isConnected = true;

      print('✅ SignalR 连接成功! ConnectionId: ${_hubConnection?.connectionId}');
    } catch (e) {
      print('❌ SignalR 连接失败: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// 注册 SignalR 事件处理器
  void _registerEventHandlers() {
    // TaskProgress: 任务进度更新
    _hubConnection?.on('TaskProgress', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final taskStatus = TaskStatus.fromJson(data);

        print('📊 收到任务进度: ${taskStatus.taskId} - ${taskStatus.progress}%');
        _taskProgressController.add(taskStatus);
      } catch (e) {
        print('❌ 解析 TaskProgress 失败: $e');
      }
    });

    // TaskCompleted: 任务完成
    _hubConnection?.on('TaskCompleted', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final taskStatus = TaskStatus.fromJson(data);

        print(
            '✅ 收到任务完成通知: ${taskStatus.taskId} - PlanId: ${taskStatus.planId}');
        _taskCompletedController.add(taskStatus);
      } catch (e) {
        print('❌ 解析 TaskCompleted 失败: $e');
      }
    });

    // TaskFailed: 任务失败
    _hubConnection?.on('TaskFailed', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      try {
        final data = arguments[0] as Map<String, dynamic>;
        final taskStatus = TaskStatus.fromJson(data);

        print('❌ 收到任务失败通知: ${taskStatus.taskId} - ${taskStatus.error}');
        _taskFailedController.add(taskStatus);
      } catch (e) {
        print('❌ 解析 TaskFailed 失败: $e');
      }
    });
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (!_isConnected) {
      print('📡 SignalR 未连接,跳过断开');
      return;
    }

    try {
      await _hubConnection?.stop();
      _isConnected = false;
      print('✅ SignalR 已断开');
    } catch (e) {
      print('❌ SignalR 断开失败: $e');
    }
  }

  /// 获取连接状态
  bool get isConnected => _isConnected;

  /// 获取 ConnectionId (用于后端关联)
  String? get connectionId => _hubConnection?.connectionId;

  /// 释放资源
  void dispose() {
    _taskProgressController.close();
    _taskCompletedController.close();
    _taskFailedController.close();
    disconnect();
  }
}
