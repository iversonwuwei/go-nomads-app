import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:get/get.dart';

import '../../application/use_cases/chat_use_cases.dart';
import '../../domain/entities/chat.dart';

/// Chat State Controller
///
/// 职责:
/// - 管理聊天室列表和当前聊天室状态
/// - 管理消息列表和发送消息
/// - 管理在线用户列表
/// - 处理消息回复和提及
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

  // 分页状态
  final _currentPage = 1.obs;
  int get currentPage => _currentPage.value;

  final _hasMoreMessages = true.obs;
  bool get hasMoreMessages => _hasMoreMessages.value;

  // 错误状态
  final _errorMessage = Rx<String?>(null);
  String? get errorMessage => _errorMessage.value;

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
        Get.snackbar('错误', exception.message);
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
        Get.snackbar('错误', '加入聊天室失败: ${exception.message}');
      },
    );

    _isLoading.value = false;
  }

  /// 离开聊天室
  Future<void> leaveRoom() async {
    if (_currentRoomId.value == null) return;

    final roomId = _currentRoomId.value!;
    final result = await _leaveChatRoomUseCase(LeaveChatRoomParams(roomId));

    result.fold(
      onSuccess: (_) {
        // 清空当前聊天室状态
        _currentRoom.value = null;
        _currentRoomId.value = null;
        _messages.clear();
        _onlineUsers.clear();
        _replyTo.value = null;
        _currentPage.value = 1;
        _hasMoreMessages.value = true;
      },
      onFailure: (exception) {
        Get.snackbar('错误', '离开聊天室失败: ${exception.message}');
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
        Get.snackbar('错误', '加载消息失败: ${exception.message}');
      },
    );

    _isLoadingMessages.value = false;
  }

  /// 加载更多消息 (下拉刷新)
  Future<void> loadMoreMessages() async {
    if (_currentRoomId.value == null) return;
    await loadMessages(_currentRoomId.value!, loadMore: true);
  }

  /// 发送消息
  Future<void> sendMessage(String message) async {
    if (_currentRoomId.value == null || message.trim().isEmpty) return;

    _isSendingMessage.value = true;

    final result = await _sendMessageUseCase(
      SendMessageParams(
        roomId: _currentRoomId.value!,
        message: message.trim(),
        replyToId: _replyTo.value?.id,
        mentions: _extractMentions(message),
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
        Get.snackbar('错误', '发送消息失败: ${exception.message}');
      },
    );

    _isSendingMessage.value = false;
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    if (_currentRoomId.value == null) return;

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
        Get.snackbar('成功', '消息已删除');
      },
      onFailure: (exception) {
        Get.snackbar('错误', '删除消息失败: ${exception.message}');
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

  @override
  void onClose() {
    // 离开当前聊天室
    if (_currentRoomId.value != null) {
      leaveRoom();
    }
    super.onClose();
  }
}
