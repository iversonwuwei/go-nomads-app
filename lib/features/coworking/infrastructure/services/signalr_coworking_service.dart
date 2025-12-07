import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// SignalR Coworking 服务
/// 负责与后端 MessageService 的 ChatHub 建立实时通信连接，监听验证人数变化
class SignalRCoworkingService extends GetxService {
  HubConnection? _hubConnection;
  final _isConnected = false.obs;
  final _isConnecting = false.obs;

  bool get isConnected => _isConnected.value;
  bool get isConnecting => _isConnecting.value;

  // 事件流控制器
  final _verificationVotesController =
      StreamController<VerificationVotesUpdate>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // 公开的事件流
  Stream<VerificationVotesUpdate> get onVerificationVotesUpdated =>
      _verificationVotesController.stream;
  Stream<String> get onError => _errorController.stream;

  // 当前订阅的 Coworking IDs
  final _subscribedCoworkingIds = <String>{}.obs;
  Set<String> get subscribedCoworkingIds => _subscribedCoworkingIds;

  /// 连接到 SignalR Hub
  Future<bool> connect() async {
    if (_isConnected.value || _isConnecting.value) {
      return _isConnected.value;
    }

    _isConnecting.value = true;

    try {
      // 使用 MessageService 的 ChatHub（SignalR 需要直连，不经过 Gateway）
      final hubUrl = '${ApiConfig.messageServiceBaseUrl}/hubs/chat';
      log('🔌 正在连接 SignalR ChatHub (for Coworking): $hubUrl');

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .withAutomaticReconnect()
          .build();

      // 注册事件处理器
      _registerEventHandlers();

      // 建立连接
      await _hubConnection!.start();
      _isConnected.value = true;
      log('✅ SignalR ChatHub 连接成功 (for Coworking)');

      // 认证用户
      await _authenticate();

      return true;
    } catch (e) {
      log('❌ SignalR CoworkingHub 连接失败: $e');
      _errorController.add('连接失败: $e');
      return false;
    } finally {
      _isConnecting.value = false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      // 先取消所有订阅
      if (_subscribedCoworkingIds.isNotEmpty) {
        await unsubscribeAll();
      }

      await _hubConnection!.stop();
      _isConnected.value = false;
      log('🔌 SignalR CoworkingHub 已断开');
    }
  }

  /// 注册事件处理器
  void _registerEventHandlers() {
    // 认证成功
    _hubConnection!.on('Authenticated', (arguments) {
      log('✅ SignalR CoworkingHub 认证成功: $arguments');
    });

    // 认证失败
    _hubConnection!.on('AuthenticateFailed', (arguments) {
      final error = arguments?.firstOrNull?.toString() ?? '认证失败';
      log('❌ SignalR CoworkingHub 认证失败: $error');
      _errorController.add(error);
    });

    // 订阅成功
    _hubConnection!.on('SubscribedCoworking', (arguments) {
      log('✅ 订阅 Coworking 成功: $arguments');
    });

    // 批量订阅成功
    _hubConnection!.on('SubscribedCoworkings', (arguments) {
      log('✅ 批量订阅 Coworking 成功: $arguments');
    });

    // 取消订阅成功
    _hubConnection!.on('UnsubscribedCoworking', (arguments) {
      log('✅ 取消订阅 Coworking: $arguments');
    });

    // 取消所有订阅成功
    _hubConnection!.on('UnsubscribedAll', (arguments) {
      log('✅ 取消所有 Coworking 订阅');
    });

    // 验证人数更新
    _hubConnection!.on('VerificationVotesUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments.first as Map<String, dynamic>;
          final update = VerificationVotesUpdate(
            coworkingId: data['coworkingId'] as String,
            verificationVotes: data['verificationVotes'] as int,
            isVerified: data['isVerified'] as bool,
          );
          _verificationVotesController.add(update);
          log('📊 验证人数更新: CoworkingId=${update.coworkingId}, Votes=${update.verificationVotes}, IsVerified=${update.isVerified}');
        } catch (e) {
          log('❌ 解析验证人数更新失败: $e');
        }
      }
    });

    // 错误
    _hubConnection!.on('Error', (arguments) {
      final error = arguments?.firstOrNull?.toString() ?? '未知错误';
      log('❌ SignalR CoworkingHub 错误: $error');
      _errorController.add(error);
    });

    // 连接状态变化
    _hubConnection!.onclose(({error}) {
      _isConnected.value = false;
      log('🔌 SignalR CoworkingHub 连接关闭: $error');
    });

    _hubConnection!.onreconnecting(({error}) {
      log('🔄 SignalR CoworkingHub 正在重连: $error');
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected.value = true;
      log('✅ SignalR CoworkingHub 重连成功: $connectionId');

      // 重新认证并恢复订阅
      _authenticate().then((_) {
        if (_subscribedCoworkingIds.isNotEmpty) {
          subscribeCoworkings(_subscribedCoworkingIds.toList());
        }
      });
    });
  }

  /// 认证用户
  Future<void> _authenticate() async {
    final authController = Get.find<AuthStateController>();
    final user = authController.currentUser.value;

    if (user != null) {
      await _hubConnection!.invoke(
        'Authenticate',
        args: [user.id, user.name, user.avatar ?? ''],
      );
    }
  }

  /// 订阅单个 Coworking
  Future<void> subscribeCoworking(String coworkingId) async {
    if (!_isConnected.value) {
      final connected = await connect();
      if (!connected) return;
    }

    try {
      await _hubConnection!.invoke('SubscribeCoworking', args: [coworkingId]);
      _subscribedCoworkingIds.add(coworkingId);
      log('🔔 请求订阅 Coworking: $coworkingId');
    } catch (e) {
      log('❌ 订阅 Coworking 失败: $e');
      _errorController.add('订阅失败');
    }
  }

  /// 批量订阅 Coworking（用于列表页）
  Future<void> subscribeCoworkings(List<String> coworkingIds) async {
    if (coworkingIds.isEmpty) return;

    if (!_isConnected.value) {
      final connected = await connect();
      if (!connected) return;
    }

    try {
      await _hubConnection!.invoke('SubscribeCoworkings', args: [coworkingIds]);
      _subscribedCoworkingIds.addAll(coworkingIds);
      log('🔔 请求批量订阅 ${coworkingIds.length} 个 Coworking');
    } catch (e) {
      log('❌ 批量订阅 Coworking 失败: $e');
      _errorController.add('批量订阅失败');
    }
  }

  /// 取消订阅单个 Coworking
  Future<void> unsubscribeCoworking(String coworkingId) async {
    if (!_isConnected.value) return;

    try {
      await _hubConnection!.invoke('UnsubscribeCoworking', args: [coworkingId]);
      _subscribedCoworkingIds.remove(coworkingId);
      log('🔕 取消订阅 Coworking: $coworkingId');
    } catch (e) {
      log('❌ 取消订阅 Coworking 失败: $e');
    }
  }

  /// 取消所有订阅
  Future<void> unsubscribeAll() async {
    if (!_isConnected.value) return;

    try {
      await _hubConnection!.invoke('UnsubscribeAll', args: []);
      _subscribedCoworkingIds.clear();
      log('🔕 取消所有 Coworking 订阅');
    } catch (e) {
      log('❌ 取消所有订阅失败: $e');
    }
  }

  @override
  void onClose() {
    _verificationVotesController.close();
    _errorController.close();
    disconnect();
    super.onClose();
  }
}

/// 验证人数更新事件
class VerificationVotesUpdate {
  final String coworkingId;
  final int verificationVotes;
  final bool isVerified;

  VerificationVotesUpdate({
    required this.coworkingId,
    required this.verificationVotes,
    required this.isVerified,
  });
}
