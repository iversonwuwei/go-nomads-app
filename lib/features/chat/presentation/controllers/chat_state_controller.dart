import 'dart:async';

import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/chat/application/use_cases/chat_use_cases.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/infrastructure/services/signalr_chat_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// Chat State Controller
///
/// 职责:
/// - 管理聊天室列表和当前聊天室状态
/// - 管理消息列表和发送消息
/// - 管理在线用户列表
/// - 处理消息回复和提及
/// - 集成 SignalR 实时通信
/// - 提供响应式状态给 UI 层
class ChatStateController extends GetxController {
  // ==================== Use Cases ====================
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  final GetChatRoomByIdUseCase _getChatRoomByIdUseCase;
  final JoinChatRoomUseCase _joinChatRoomUseCase;
  final LeaveChatRoomUseCase _leaveChatRoomUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final GetOnlineUsersUseCase _getOnlineUsersUseCase;
  final GetRoomMembersUseCase _getRoomMembersUseCase;

  // ==================== SignalR 服务 ====================
  late final SignalRChatService _signalRService;
  final List<StreamSubscription> _subscriptions = [];

  ChatStateController(
    this._getChatRoomsUseCase,
    this._getChatRoomByIdUseCase,
    this._joinChatRoomUseCase,
    this._leaveChatRoomUseCase,
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._deleteMessageUseCase,
    this._getOnlineUsersUseCase,
    this._getRoomMembersUseCase,
  );

  // ==================== 响应式状态 ====================

  // 加载状态
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isSendingMessage = false.obs;
  bool get isSendingMessage => _isSendingMessage.value;

  final _isLoadingMessages = false.obs;
  bool get isLoadingMessages => _isLoadingMessages.value;

  // 聊天室状态
  final _chatRooms = <ChatRoom>[].obs;
  List<ChatRoom> get chatRooms => _chatRooms;

  final _currentRoom = Rx<ChatRoom?>(null);
  ChatRoom? get currentRoom => _currentRoom.value;

  final _currentRoomId = Rx<String?>(null);
  String? get currentRoomId => _currentRoomId.value;

  // 消息状态
  final _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages;

  final _replyTo = Rx<ChatMessage?>(null);
  ChatMessage? get replyTo => _replyTo.value;

  // 用户状态
  final _onlineUsers = <OnlineUser>[].obs;
  List<OnlineUser> get onlineUsers => _onlineUsers;

  final _roomMembers = <OnlineUser>[].obs;
  List<OnlineUser> get roomMembers => _roomMembers;

  // SignalR 连接状态
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  // 正在输入状态
  final _typingUsers = <String, String>{}.obs;
  Map<String, String> get typingUsers => _typingUsers;

  // 分页状态
  final _currentPage = 1.obs;
  int get currentPage => _currentPage.value;

  final _hasMoreMessages = true.obs;
  bool get hasMoreMessages => _hasMoreMessages.value;

  // 错误状态
  final _errorMessage = Rx<String?>(null);
  String? get errorMessage => _errorMessage.value;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _initSignalR();
  }

  /// 初始化 SignalR 服务
  void _initSignalR() {
    // 检查是否已注册 SignalR 服务
    if (Get.isRegistered<SignalRChatService>()) {
      _signalRService = Get.find<SignalRChatService>();
    } else {
      _signalRService = Get.put(SignalRChatService());
    }

    // 监听 SignalR 事件
    _subscriptions.add(
      _signalRService.onMessage.listen(_handleNewMessage),
    );

    _subscriptions.add(
      _signalRService.onUserJoined.listen(_handleUserJoined),
    );

    _subscriptions.add(
      _signalRService.onUserLeft.listen(_handleUserLeft),
    );

    _subscriptions.add(
      _signalRService.onUserTyping.listen(_handleUserTyping),
    );

    _subscriptions.add(
      _signalRService.onMessageDeleted.listen(_handleMessageDeleted),
    );

    _subscriptions.add(
      _signalRService.onError.listen(_handleError),
    );
  }

  /// 处理新消息
  void _handleNewMessage(ChatMessage message) {
    // 检查消息是否属于当前聊天室
    // 将新消息添加到列表顶部
    if (!_messages.any((m) => m.id == message.id)) {
      _messages.insert(0, message);
    }
  }

  /// 处理用户加入
  void _handleUserJoined(Map<String, dynamic> data) {
    final userId = data['userId']?.toString();
    final userName = data['userName']?.toString() ?? '';
    final userAvatar = data['userAvatar']?.toString();

    if (userId != null) {
      // 检查是否已存在
      final existingIndex = _onlineUsers.indexWhere((u) => u.id == userId);
      if (existingIndex == -1) {
        _onlineUsers.add(OnlineUser(
          id: userId,
          name: userName,
          avatar: userAvatar,
          isOnline: true,
        ));
      } else {
        _onlineUsers[existingIndex] = OnlineUser(
          id: userId,
          name: userName,
          avatar: userAvatar,
          isOnline: true,
        );
      }
    }
  }

  /// 处理用户离开
  void _handleUserLeft(Map<String, dynamic> data) {
    final userId = data['userId']?.toString();
    if (userId != null) {
      _onlineUsers.removeWhere((u) => u.id == userId);
    }
  }

  /// 处理用户正在输入
  void _handleUserTyping(Map<String, dynamic> data) {
    final userId = data['userId']?.toString();
    final userName = data['userName']?.toString();

    if (userId != null && userName != null) {
      _typingUsers[userId] = userName;

      // 3秒后移除正在输入状态
      Future.delayed(const Duration(seconds: 3), () {
        _typingUsers.remove(userId);
      });
    }
  }

  /// 处理消息删除
  void _handleMessageDeleted(Map<String, dynamic> data) {
    final messageId = data['messageId']?.toString();
    if (messageId != null) {
      _messages.removeWhere((m) => m.id == messageId);
    }
  }

  /// 处理错误
  void _handleError(String error) {
    _errorMessage.value = error;
    AppToast.error(error);
  }

  // ==================== 聊天室管理 ====================

  /// 加载聊天室列表
  Future<void> loadChatRooms() async {
    _isLoading.value = true;
    _errorMessage.value = null;

    final result = await _getChatRoomsUseCase(const NoParams());

    result.fold(
      onSuccess: (rooms) {
        _chatRooms.value = rooms;
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
        AppToast.error(exception.message);
      },
    );

    _isLoading.value = false;
  }

  /// 根据 meetupId 加入聊天室
  Future<void> joinMeetupRoom({
    required String meetupId,
    required String meetupTitle,
    String? meetupType,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    // 创建一个临时的 Meetup 聊天室对象
    final meetupRoom = ChatRoom(
      id: 'meetup_$meetupId',
      location: RoomLocation(
        city: meetupTitle,
        country: meetupType ?? 'Meetup',
      ),
      stats: RoomStats(onlineUsers: 0, totalMembers: 0),
      roomType: ChatRoomType.meetup,
      meetupId: meetupId,
      meetupTitle: meetupTitle,
    );

    // 设置当前聊天室
    _currentRoom.value = meetupRoom;
    _currentRoomId.value = meetupRoom.id;

    // 调用加入聊天室 API
    final joinResult = await _joinChatRoomUseCase(JoinChatRoomParams(meetupRoom.id));

    await joinResult.fold(
      onSuccess: (_) async {
        // 连接 SignalR 并加入聊天室
        await _signalRService.joinRoom(meetupRoom.id);
        _isConnected.value = _signalRService.isConnected;

        // 加载聊天室详情
        final detailResult = await _getChatRoomByIdUseCase(
          GetChatRoomByIdParams(meetupRoom.id),
        );

        detailResult.fold(
          onSuccess: (Object? roomDetail) {
            if (roomDetail != null) {
              _currentRoom.value = roomDetail as ChatRoom;
            }
          },
          onFailure: (exception) {
            // 详情加载失败，使用临时对象
            _errorMessage.value = exception.message;
          },
        );

        // 加载消息和在线用户
        await Future.wait([
          loadMessages(meetupRoom.id),
          loadOnlineUsers(meetupRoom.id),
        ]);
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
        AppToast.error('加入聊天室失败: ${exception.message}');
      },
    );

    _isLoading.value = false;
  }

  /// 加入聊天室
  Future<void> joinRoom(ChatRoom room) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    // 先设置当前聊天室
    _currentRoom.value = room;
    _currentRoomId.value = room.id;

    // 调用加入聊天室 API
    final joinResult = await _joinChatRoomUseCase(JoinChatRoomParams(room.id));

    await joinResult.fold(
      onSuccess: (_) async {
        // 连接 SignalR 并加入聊天室
        await _signalRService.joinRoom(room.id);
        _isConnected.value = _signalRService.isConnected;

        // 加载聊天室详情
        final detailResult = await _getChatRoomByIdUseCase(
          GetChatRoomByIdParams(room.id),
        );

        detailResult.fold(
          onSuccess: (Object? roomDetail) {
            _currentRoom.value = roomDetail as ChatRoom;
          },
          onFailure: (exception) {
            _errorMessage.value = exception.message;
          },
        );

        // 加载消息和在线用户
        await Future.wait([
          loadMessages(room.id),
          loadOnlineUsers(room.id),
        ]);
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
        AppToast.error('加入聊天室失败: ${exception.message}');
      },
    );

    _isLoading.value = false;
  }

  /// 离开聊天室
  Future<void> leaveRoom() async {
    if (_currentRoomId.value == null) return;

    final roomId = _currentRoomId.value!;
    
    // 先从 SignalR 离开
    await _signalRService.leaveRoom(roomId);
    
    final result = await _leaveChatRoomUseCase(LeaveChatRoomParams(roomId));

    result.fold(
      onSuccess: (_) {
        // 清空当前聊天室状态
        _currentRoom.value = null;
        _currentRoomId.value = null;
        _messages.clear();
        _onlineUsers.clear();
        _typingUsers.clear();
        _replyTo.value = null;
        _currentPage.value = 1;
        _hasMoreMessages.value = true;
      },
      onFailure: (exception) {
        AppToast.error('离开聊天室失败: ${exception.message}');
      },
    );
  }

  // ==================== 消息管理 ====================

  /// 加载消息列表
  Future<void> loadMessages(String roomId, {bool loadMore = false}) async {
    if (!loadMore) {
      _isLoadingMessages.value = true;
      _currentPage.value = 1;
      _hasMoreMessages.value = true;
    }

    if (!_hasMoreMessages.value) return;

    final result = await _getMessagesUseCase(
      GetMessagesParams(
        roomId: roomId,
        page: _currentPage.value,
        pageSize: 50,
      ),
    );

    result.fold(
      onSuccess: (newMessages) {
        if (newMessages.isEmpty) {
          _hasMoreMessages.value = false;
        } else {
          if (loadMore) {
            _messages.addAll(newMessages);
          } else {
            _messages.value = newMessages;
          }
          _currentPage.value++;
        }
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
        AppToast.error('加载消息失败: ${exception.message}');
      },
    );

    _isLoadingMessages.value = false;
  }

  /// 加载更多消息 (下拉刷新)
  Future<void> loadMoreMessages() async {
    if (_currentRoomId.value == null) return;
    await loadMessages(_currentRoomId.value!, loadMore: true);
  }

  /// 发送消息（优先使用 SignalR，降级为 REST API）
  Future<void> sendMessage(
    String message, {
    String? messageType,
    Map<String, dynamic>? attachment,
  }) async {
    if (_currentRoomId.value == null || message.trim().isEmpty) return;

    _isSendingMessage.value = true;

    // 如果 SignalR 已连接，使用 SignalR 发送（实时）
    if (_signalRService.isConnected) {
      await _signalRService.sendMessage(
        roomId: _currentRoomId.value!,
        message: message.trim(),
        messageType: messageType,
        replyToId: _replyTo.value?.id,
        mentions: _extractMentions(message),
        attachment: attachment,
      );

      // 清空回复状态
      clearReplyTo();
      _isSendingMessage.value = false;
      return;
    }

    // 降级为 REST API
    final result = await _sendMessageUseCase(
      SendMessageParams(
        roomId: _currentRoomId.value!,
        message: message.trim(),
        replyToId: _replyTo.value?.id,
        mentions: _extractMentions(message),
        messageType: messageType,
        attachment: attachment,
      ),
    );

    result.fold(
      onSuccess: (Object? sentMessage) {
        // 添加新消息到列表顶部
        _messages.insert(0, sentMessage as ChatMessage);

        // 清空回复状态
        clearReplyTo();
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
        AppToast.error('发送消息失败: ${exception.message}');
      },
    );

    _isSendingMessage.value = false;
  }

  /// 发送正在输入状态
  void sendTyping() {
    if (_currentRoomId.value != null && _signalRService.isConnected) {
      _signalRService.sendTyping(_currentRoomId.value!);
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    if (_currentRoomId.value == null) return;

    // 如果 SignalR 已连接，使用 SignalR 删除
    if (_signalRService.isConnected) {
      await _signalRService.deleteMessage(_currentRoomId.value!, messageId);
      return;
    }

    // 降级为 REST API
    final result = await _deleteMessageUseCase(
      DeleteMessageParams(
        roomId: _currentRoomId.value!,
        messageId: messageId,
      ),
    );

    result.fold(
      onSuccess: (_) {
        // 从列表中移除消息
        _messages.removeWhere((msg) => msg.id == messageId);
        AppToast.success('消息已删除');
      },
      onFailure: (exception) {
        AppToast.error('删除消息失败: ${exception.message}');
      },
    );
  }

  /// 设置回复消息
  void setReplyTo(ChatMessage message) {
    _replyTo.value = message;
  }

  /// 清空回复消息
  void clearReplyTo() {
    _replyTo.value = null;
  }

  /// 从消息文本中提取提及的用户ID
  List<String> _extractMentions(String message) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(message);
    return matches.map((m) => m.group(1)!).toList();
  }

  // ==================== 用户管理 ====================

  /// 加载在线用户列表
  Future<void> loadOnlineUsers(String roomId) async {
    final result = await _getOnlineUsersUseCase(
      GetOnlineUsersParams(roomId),
    );

    result.fold(
      onSuccess: (users) {
        _onlineUsers.value = users;
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
      },
    );
  }

  /// 加载聊天室成员列表
  Future<void> loadRoomMembers(String roomId, {int page = 1}) async {
    final result = await _getRoomMembersUseCase(
      GetRoomMembersParams(
        roomId: roomId,
        page: page,
        pageSize: 20,
      ),
    );

    result.fold(
      onSuccess: (users) {
        if (page == 1) {
          _roomMembers.value = users;
        } else {
          _roomMembers.addAll(users);
        }
      },
      onFailure: (exception) {
        _errorMessage.value = exception.message;
      },
    );
  }

  // ==================== 实用方法 ====================

  /// 刷新当前聊天室
  Future<void> refreshCurrentRoom() async {
    if (_currentRoomId.value == null) return;

    await Future.wait([
      loadMessages(_currentRoomId.value!),
      loadOnlineUsers(_currentRoomId.value!),
    ]);
  }

  /// 清空错误消息
  void clearError() {
    _errorMessage.value = null;
  }

  /// 手动连接 SignalR
  Future<bool> connectSignalR() async {
    final connected = await _signalRService.connect();
    _isConnected.value = connected;
    return connected;
  }

  /// 断开 SignalR 连接
  Future<void> disconnectSignalR() async {
    await _signalRService.disconnect();
    _isConnected.value = false;
  }

  @override
  void onClose() {
    // 取消所有订阅
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 离开当前聊天室(异步操作)
    if (_currentRoomId.value != null) {
      leaveRoom();
    }
    
    // 清空所有响应式变量
    _chatRooms.clear();
    _currentRoom.value = null;
    _currentRoomId.value = null;
    _messages.clear();
    _replyTo.value = null;
    _onlineUsers.clear();
    _roomMembers.clear();
    _typingUsers.clear();
    
    // 重置加载状态
    _isLoading.value = false;
    _isSendingMessage.value = false;
    _isLoadingMessages.value = false;
    _isConnected.value = false;
    
    // 重置分页状态
    _currentPage.value = 1;
    _hasMoreMessages.value = true;
    
    // 清空错误信息
    _errorMessage.value = null;
    
    super.onClose();
  }
}
