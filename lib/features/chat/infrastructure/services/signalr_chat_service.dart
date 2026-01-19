import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// SignalR 聊天服务
/// 负责与后端 ChatHub 建立实时通信连接
class SignalRChatService extends GetxService {
  HubConnection? _hubConnection;
  final _isConnected = false.obs;
  final _isConnecting = false.obs;

  bool get isConnected => _isConnected.value;
  bool get isConnecting => _isConnecting.value;

  // 事件流控制器
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _userJoinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _userLeftController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // 公开的事件流
  Stream<ChatMessage> get onMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onUserJoined => _userJoinedController.stream;
  Stream<Map<String, dynamic>> get onUserLeft => _userLeftController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _messageDeletedController.stream;
  Stream<Map<String, dynamic>> get onOnlineStatusUpdated => _onlineStatusController.stream;
  Stream<String> get onError => _errorController.stream;

  // 当前加入的聊天室
  final _currentRoomId = Rx<String?>(null);
  String? get currentRoomId => _currentRoomId.value;

  /// 连接到 SignalR Hub
  Future<bool> connect() async {
    if (_isConnected.value || _isConnecting.value) {
      return _isConnected.value;
    }

    _isConnecting.value = true;

    try {
      // 使用 MessageService 直连地址（SignalR 需要直连，不经过 Gateway）
      final hubUrl = '${ApiConfig.messageServiceBaseUrl}/hubs/chat';
      log('🔌 正在连接 SignalR ChatHub: $hubUrl');

      // 配置 SignalR 连接选项
      final httpConnectionOptions = HttpConnectionOptions(
        requestTimeout: 60000, // 请求超时 60 秒
      );

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl, options: httpConnectionOptions)
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000]) // 重连延迟
          .build();

      // 设置服务器超时和保持连接间隔
      _hubConnection!.serverTimeoutInMilliseconds = 60000; // 服务器超时 60 秒
      _hubConnection!.keepAliveIntervalInMilliseconds = 15000; // 保持连接间隔 15 秒

      // 注册事件处理器
      _registerEventHandlers();

      // 建立连接
      await _hubConnection!.start();
      _isConnected.value = true;
      log('✅ SignalR ChatHub 连接成功');

      // 认证用户
      await _authenticate();

      return true;
    } catch (e) {
      log('❌ SignalR 连接失败: $e');
      _errorController.add('连接失败: $e');
      return false;
    } finally {
      _isConnecting.value = false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      // 先离开当前聊天室
      if (_currentRoomId.value != null) {
        await leaveRoom(_currentRoomId.value!);
      }

      await _hubConnection!.stop();
      _isConnected.value = false;
      log('🔌 SignalR ChatHub 已断开');
    }
  }

  /// 注册事件处理器
  void _registerEventHandlers() {
    // 认证成功
    _hubConnection!.on('Authenticated', (arguments) {
      log('✅ SignalR 认证成功: $arguments');
    });

    // 认证失败
    _hubConnection!.on('AuthenticateFailed', (arguments) {
      final error = arguments?.firstOrNull?.toString() ?? '认证失败';
      log('❌ SignalR 认证失败: $error');
      _errorController.add(error);
    });

    // 加入聊天室成功
    _hubConnection!.on('JoinedRoom', (arguments) {
      log('✅ 加入聊天室成功: $arguments');
    });

    // 离开聊天室成功
    _hubConnection!.on('LeftRoom', (arguments) {
      log('✅ 离开聊天室: $arguments');
    });

    // 收到新消息
    _hubConnection!.on('NewMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments.first as Map<String, dynamic>;
          final message = _parseMessage(data);
          _messageController.add(message);
          log('📩 收到新消息: ${message.message}');
        } catch (e) {
          log('❌ 解析消息失败: $e');
        }
      }
    });

    // 用户加入
    _hubConnection!.on('UserJoined', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        _userJoinedController.add(data);
        log('👤 用户加入: ${data['userName']}');
      }
    });

    // 用户离开
    _hubConnection!.on('UserLeft', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        _userLeftController.add(data);
        log('👤 用户离开: ${data['userName']}');
      }
    });

    // 用户正在输入
    _hubConnection!.on('UserTyping', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        _typingController.add(data);
      }
    });

    // 消息被删除
    _hubConnection!.on('MessageDeleted', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        _messageDeletedController.add(data);
        log('🗑️ 消息被删除: ${data['messageId']}');
      }
    });

    // 在线状态更新（来自 RabbitMQ）
    _hubConnection!.on('OnlineStatusUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments.first as Map<String, dynamic>;
        _onlineStatusController.add(data);
        log('👥 在线状态更新: RoomId=${data['roomId']}, OnlineCount=${data['onlineCount']}');
      }
    });

    // 错误
    _hubConnection!.on('Error', (arguments) {
      final error = arguments?.firstOrNull?.toString() ?? '未知错误';
      log('❌ SignalR 错误: $error');
      _errorController.add(error);
    });

    // 连接状态变化
    _hubConnection!.onclose(({error}) {
      _isConnected.value = false;
      log('🔌 SignalR 连接关闭: $error');
    });

    _hubConnection!.onreconnecting(({error}) {
      log('🔄 SignalR 正在重连: $error');
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected.value = true;
      log('✅ SignalR 重连成功: $connectionId');

      // 重新认证并加入之前的聊天室
      _authenticate().then((_) {
        if (_currentRoomId.value != null) {
          joinRoom(_currentRoomId.value!);
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

  /// 加入聊天室
  Future<void> joinRoom(String roomId) async {
    if (!_isConnected.value) {
      final connected = await connect();
      if (!connected) return;
    }

    try {
      await _hubConnection!.invoke('JoinRoom', args: [roomId]);
      _currentRoomId.value = roomId;
      log('🚪 请求加入聊天室: $roomId');
    } catch (e) {
      log('❌ 加入聊天室失败: $e');
      _errorController.add('加入聊天室失败');
    }
  }

  /// 离开聊天室
  Future<void> leaveRoom(String roomId) async {
    if (!_isConnected.value) return;

    try {
      await _hubConnection!.invoke('LeaveRoom', args: [roomId]);
      if (_currentRoomId.value == roomId) {
        _currentRoomId.value = null;
      }
      log('🚪 离开聊天室: $roomId');
    } catch (e) {
      log('❌ 离开聊天室失败: $e');
    }
  }

  /// 发送消息
  Future<void> sendMessage({
    required String roomId,
    required String message,
    String? messageType,
    String? replyToId,
    List<String>? mentions,
    Map<String, dynamic>? attachment,
  }) async {
    if (!_isConnected.value) {
      _errorController.add('未连接到服务器');
      return;
    }

    try {
      await _hubConnection!.invoke('SendMessage', args: [
        {
          'roomId': roomId,
          'message': message,
          'messageType': messageType ?? 'text',
          'replyToId': replyToId,
          'mentions': mentions ?? [],
          'attachment': attachment,
        }
      ]);
    } catch (e) {
      log('❌ 发送消息失败: $e');
      _errorController.add('发送消息失败');
    }
  }

  /// 发送正在输入状态
  Future<void> sendTyping(String roomId) async {
    if (!_isConnected.value) return;

    try {
      await _hubConnection!.invoke('SendTyping', args: [roomId]);
    } catch (e) {
      // 忽略 typing 错误
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String roomId, String messageId) async {
    if (!_isConnected.value) return;

    try {
      await _hubConnection!.invoke('DeleteMessage', args: [roomId, messageId]);
    } catch (e) {
      log('❌ 删除消息失败: $e');
      _errorController.add('删除消息失败');
    }
  }

  /// 解析消息数据
  ChatMessage _parseMessage(Map<String, dynamic> data) {
    final author = data['author'] as Map<String, dynamic>?;
    final replyTo = data['replyTo'] as Map<String, dynamic>?;
    final mentions = (data['mentions'] as List<dynamic>?)?.cast<String>() ?? [];
    final attachment = data['attachment'] as Map<String, dynamic>?;
    final roomId = data['roomId']?.toString();

    MessageType messageType;
    switch (data['messageType']) {
      case 'image':
        messageType = MessageType.image;
        break;
      case 'file':
        messageType = MessageType.file;
        break;
      case 'location':
        messageType = MessageType.location;
        break;
      case 'voice':
        messageType = MessageType.voice;
        break;
      case 'video':
        messageType = MessageType.video;
        break;
      default:
        messageType = MessageType.text;
    }

    return ChatMessage(
      id: data['id']?.toString() ?? '',
      roomId: roomId,
      author: MessageAuthor(
        userId: author?['userId']?.toString() ?? '',
        userName: author?['userName']?.toString() ?? '',
        userAvatar: author?['userAvatar']?.toString(),
      ),
      message: data['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
      type: messageType,
      mentions: mentions,
      replyTo: replyTo != null
          ? MessageReply(
              messageId: replyTo['messageId']?.toString() ?? '',
              message: replyTo['message']?.toString() ?? '',
              userName: replyTo['userName']?.toString() ?? '',
            )
          : null,
      attachment: attachment != null
          ? MessageAttachment(
              url: attachment['url']?.toString() ?? '',
              fileName: attachment['fileName']?.toString(),
              fileSize: attachment['fileSize'] as int?,
              mimeType: attachment['mimeType']?.toString(),
              latitude: (attachment['latitude'] as num?)?.toDouble(),
              longitude: (attachment['longitude'] as num?)?.toDouble(),
              locationName: attachment['locationName']?.toString(),
              duration: attachment['duration'] as int?,
              width: attachment['width'] as int?,
              height: attachment['height'] as int?,
            )
          : null,
    );
  }

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    _userJoinedController.close();
    _userLeftController.close();
    _typingController.close();
    _messageDeletedController.close();
    _onlineStatusController.close();
    _errorController.close();
    super.onClose();
  }
}
