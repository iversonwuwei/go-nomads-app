import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';

/// Chat Repository 接口
///
/// 职责:
/// - 管理聊天室列表
/// - 加载和发送聊天消息
/// - 获取在线用户列表
/// - 管理消息回复和提及
abstract class IChatRepository {
  // ==================== 聊天室管理 ====================

  /// 获取所有聊天室列表
  ///
  /// 返回: Result<List<ChatRoom>>
  Future<Result<List<ChatRoom>>> getChatRooms();

  /// 根据ID获取聊天室详情
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: Result<ChatRoom>
  Future<Result<ChatRoom>> getChatRoomById(String roomId);

  /// 加入聊天室
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: Result<void>
  Future<Result<void>> joinChatRoom(String roomId);

  /// 离开聊天室
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: Result<void>
  Future<Result<void>> leaveChatRoom(String roomId);

  /// 获取或创建 Meetup 聊天室
  ///
  /// 参数:
  /// - [meetupId]: Meetup ID
  /// - [meetupTitle]: Meetup 标题
  /// - [meetupType]: Meetup 类型（可选）
  ///
  /// 返回: Result<ChatRoom>
  /// 说明: 创建聊天室时会自动将当前用户加入群聊
  Future<Result<ChatRoom>> getOrCreateMeetupChatRoom({
    required String meetupId,
    required String meetupTitle,
    String? meetupType,
  });

  // ==================== 消息管理 ====================

  /// 获取聊天室消息列表
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认50)
  ///
  /// 返回: Result<List<ChatMessage>>
  Future<Result<List<ChatMessage>>> getMessages({
    required String roomId,
    int page = 1,
    int pageSize = 50,
  });

  /// 发送消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [message]: 消息内容
  /// - [replyToId]: 回复的消息ID (可选)
  /// - [mentions]: 提及的用户ID列表 (可选)
  ///
  /// 返回: Result<ChatMessage>
  Future<Result<ChatMessage>> sendMessage({
    required String roomId,
    required String message,
    String? replyToId,
    List<String>? mentions,
  });

  /// 删除消息
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [messageId]: 消息ID
  ///
  /// 返回: Result<void>
  Future<Result<void>> deleteMessage({
    required String roomId,
    required String messageId,
  });

  // ==================== 用户管理 ====================

  /// 获取聊天室在线用户列表
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  ///
  /// 返回: Result<List<OnlineUser>>
  Future<Result<List<OnlineUser>>> getOnlineUsers(String roomId);

  /// 获取聊天室所有成员
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [page]: 页码 (默认1)
  /// - [pageSize]: 每页数量 (默认20)
  ///
  /// 返回: Result<List<OnlineUser>>
  Future<Result<List<OnlineUser>>> getRoomMembers({
    required String roomId,
    int page = 1,
    int pageSize = 20,
  });

  // ==================== 实时更新 (WebSocket/SSE) ====================

  /// 订阅聊天室消息 (实时)
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [onMessage]: 收到新消息回调
  /// - [onError]: 错误回调
  ///
  /// 返回: Stream<ChatMessage>
  Stream<ChatMessage> subscribeToMessages({
    required String roomId,
    Function(ChatMessage message)? onMessage,
    Function(String error)? onError,
  });

  /// 订阅用户在线状态变化 (实时)
  ///
  /// 参数:
  /// - [roomId]: 聊天室ID
  /// - [onUserJoined]: 用户加入回调
  /// - [onUserLeft]: 用户离开回调
  ///
  /// 返回: Stream<OnlineUser>
  Stream<OnlineUser> subscribeToUserStatus({
    required String roomId,
    Function(OnlineUser user)? onUserJoined,
    Function(String userId)? onUserLeft,
  });
}
