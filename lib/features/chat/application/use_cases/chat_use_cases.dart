import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/domain/repositories/i_chat_repository.dart';

// ==================== 聊天室管理 Use Cases ====================

/// 获取聊天室列表 Use Case
class GetChatRoomsUseCase extends UseCase<List<ChatRoom>, NoParams> {
  final IChatRepository _chatRepository;

  GetChatRoomsUseCase(this._chatRepository);

  @override
  Future<Result<List<ChatRoom>>> execute(NoParams params) async {
    return await _chatRepository.getChatRooms();
  }
}

/// 获取聊天室详情 Use Case
class GetChatRoomByIdUseCase extends UseCase<ChatRoom, GetChatRoomByIdParams> {
  final IChatRepository _chatRepository;

  GetChatRoomByIdUseCase(this._chatRepository);

  @override
  Future<Result<ChatRoom>> execute(GetChatRoomByIdParams params) async {
    return await _chatRepository.getChatRoomById(params.roomId);
  }
}

/// 加入聊天室 Use Case
class JoinChatRoomUseCase extends UseCase<void, JoinChatRoomParams> {
  final IChatRepository _chatRepository;

  JoinChatRoomUseCase(this._chatRepository);

  @override
  Future<Result<void>> execute(JoinChatRoomParams params) async {
    return await _chatRepository.joinChatRoom(params.roomId);
  }
}

/// 离开聊天室 Use Case
class LeaveChatRoomUseCase extends UseCase<void, LeaveChatRoomParams> {
  final IChatRepository _chatRepository;

  LeaveChatRoomUseCase(this._chatRepository);

  @override
  Future<Result<void>> execute(LeaveChatRoomParams params) async {
    return await _chatRepository.leaveChatRoom(params.roomId);
  }
}

// ==================== 消息管理 Use Cases ====================

/// 获取消息列表 Use Case
class GetMessagesUseCase extends UseCase<List<ChatMessage>, GetMessagesParams> {
  final IChatRepository _chatRepository;

  GetMessagesUseCase(this._chatRepository);

  @override
  Future<Result<List<ChatMessage>>> execute(GetMessagesParams params) async {
    return await _chatRepository.getMessages(
      roomId: params.roomId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// 发送消息 Use Case
class SendMessageUseCase extends UseCase<ChatMessage, SendMessageParams> {
  final IChatRepository _chatRepository;

  SendMessageUseCase(this._chatRepository);

  @override
  Future<Result<ChatMessage>> execute(SendMessageParams params) async {
    return await _chatRepository.sendMessage(
      roomId: params.roomId,
      message: params.message,
      replyToId: params.replyToId,
      mentions: params.mentions,
    );
  }
}

/// 删除消息 Use Case
class DeleteMessageUseCase extends UseCase<void, DeleteMessageParams> {
  final IChatRepository _chatRepository;

  DeleteMessageUseCase(this._chatRepository);

  @override
  Future<Result<void>> execute(DeleteMessageParams params) async {
    return await _chatRepository.deleteMessage(
      roomId: params.roomId,
      messageId: params.messageId,
    );
  }
}

// ==================== 用户管理 Use Cases ====================

/// 获取在线用户列表 Use Case
class GetOnlineUsersUseCase
    extends UseCase<List<OnlineUser>, GetOnlineUsersParams> {
  final IChatRepository _chatRepository;

  GetOnlineUsersUseCase(this._chatRepository);

  @override
  Future<Result<List<OnlineUser>>> execute(GetOnlineUsersParams params) async {
    return await _chatRepository.getOnlineUsers(params.roomId);
  }
}

/// 获取聊天室成员列表 Use Case
class GetRoomMembersUseCase
    extends UseCase<List<OnlineUser>, GetRoomMembersParams> {
  final IChatRepository _chatRepository;

  GetRoomMembersUseCase(this._chatRepository);

  @override
  Future<Result<List<OnlineUser>>> execute(GetRoomMembersParams params) async {
    return await _chatRepository.getRoomMembers(
      roomId: params.roomId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

// ==================== 参数类 ====================

/// 获取聊天室详情参数
class GetChatRoomByIdParams {
  final String roomId;

  GetChatRoomByIdParams(this.roomId);
}

/// 加入聊天室参数
class JoinChatRoomParams {
  final String roomId;

  JoinChatRoomParams(this.roomId);
}

/// 离开聊天室参数
class LeaveChatRoomParams {
  final String roomId;

  LeaveChatRoomParams(this.roomId);
}

/// 获取消息参数
class GetMessagesParams {
  final String roomId;
  final int page;
  final int pageSize;

  GetMessagesParams({
    required this.roomId,
    this.page = 1,
    this.pageSize = 50,
  });
}

/// 发送消息参数
class SendMessageParams {
  final String roomId;
  final String message;
  final String? replyToId;
  final List<String>? mentions;
  final String? messageType;
  final Map<String, dynamic>? attachment;

  SendMessageParams({
    required this.roomId,
    required this.message,
    this.replyToId,
    this.mentions,
    this.messageType,
    this.attachment,
  });
}

/// 删除消息参数
class DeleteMessageParams {
  final String roomId;
  final String messageId;

  DeleteMessageParams({
    required this.roomId,
    required this.messageId,
  });
}

/// 获取在线用户参数
class GetOnlineUsersParams {
  final String roomId;

  GetOnlineUsersParams(this.roomId);
}

/// 获取聊天室成员参数
class GetRoomMembersParams {
  final String roomId;
  final int page;
  final int pageSize;

  GetRoomMembersParams({
    required this.roomId,
    this.page = 1,
    this.pageSize = 20,
  });
}
