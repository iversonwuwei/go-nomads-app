import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../features/async_task/domain/entities/async_task.dart';
import '../features/async_task/infrastructure/models/async_task_dto.dart';
import 'token_storage_service.dart';

/// SignalR 实时通知服务
/// 管理与后端 SignalR Hub 的连接,接收任务进度和完成通知
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  HubConnection? _hubConnection;
  bool _isConnected = false;

  // 事件流控制器
  final _taskProgressController = StreamController<AsyncTask>.broadcast();
  final _taskCompletedController = StreamController<AsyncTask>.broadcast();
  final _taskFailedController = StreamController<AsyncTask>.broadcast();

  // 事件流
  Stream<AsyncTask> get taskProgressStream => _taskProgressController.stream;
  Stream<AsyncTask> get taskCompletedStream => _taskCompletedController.stream;
  Stream<AsyncTask> get taskFailedStream => _taskFailedController.stream;

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
