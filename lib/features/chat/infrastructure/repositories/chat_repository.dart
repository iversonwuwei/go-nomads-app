import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:df_admin_mobile/features/chat/infrastructure/models/chat_dto.dart';
import 'package:df_admin_mobile/services/http_service.dart';

/// Chat Repository 实现
///
/// 职责:
/// - 调用后端 API 获取聊天数据
/// - 将 DTO 转换为 Domain Entity
/// - 处理错误并返回 Result 对象
class ChatRepository implements IChatRepository {
  final HttpService _httpService;

  ChatRepository(this._httpService);

  /// 将 HttpException 转换为 DomainException
  DomainException _convertHttpException(HttpException e) {
    if (e.statusCode == null) {
      return NetworkException(e.message);
    }

    switch (e.statusCode!) {
      case 400:
        return ValidationException(e.message, details: e.errors);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case >= 500:
        return ServerException(e.message);
      default:
        return NetworkException(e.message, code: e.statusCode.toString());
    }
  }

  // ==================== 聊天室管理 ====================

  @override
  Future<Result<List<ChatRoom>>> getChatRooms() async {
    try {
      final response = await _httpService.get(
        ApiConfig.chatsEndpoint,
      );

      final List<dynamic> data = response.data;
      final rooms = data.map((json) => ChatRoomDto.fromJson(json).toDomain()).toList();

      return Success(rooms);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取聊天室列表异常: $e'));
    }
  }

  @override
  Future<Result<ChatRoom>> getChatRoomById(String roomId) async {
    try {
      final endpoint = ApiConfig.chatDetailEndpoint.replaceAll('{id}', roomId);
      final response = await _httpService.get(endpoint);

      final room = ChatRoomDto.fromJson(response.data).toDomain();
      return Success(room);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取聊天室详情异常: $e'));
    }
  }

  @override
  Future<Result<void>> joinChatRoom(String roomId) async {
    try {
      final endpoint = ApiConfig.chatDetailEndpoint.replaceAll('{id}', roomId);
      await _httpService.post(
        '$endpoint/join',
        data: {},
      );

      return Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('加入聊天室异常: $e'));
    }
  }

  @override
  Future<Result<void>> leaveChatRoom(String roomId) async {
    try {
      final endpoint = ApiConfig.chatDetailEndpoint.replaceAll('{id}', roomId);
      await _httpService.post(
        '$endpoint/leave',
        data: {},
      );

      return Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('离开聊天室异常: $e'));
    }
  }

  @override
  Future<Result<ChatRoom>> getOrCreateMeetupChatRoom({
    required String meetupId,
    required String meetupTitle,
    String? meetupType,
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.chatMeetupEndpoint,
        data: {
          'meetupId': meetupId,
          'meetupTitle': meetupTitle,
          if (meetupType != null) 'meetupType': meetupType,
        },
      );

      final room = ChatRoomDto.fromJson(response.data).toDomain();
      return Success(room);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('创建 Meetup 聊天室异常: $e'));
    }
  }

  // ==================== 消息管理 ====================

  @override
  Future<Result<List<ChatMessage>>> getMessages({
    required String roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final endpoint = ApiConfig.chatMessagesEndpoint.replaceAll('{id}', roomId);
      final response = await _httpService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final List<dynamic> data = response.data;
      final messages = data.map((json) => ChatMessageDto.fromJson(json).toDomain()).toList();

      return Success(messages);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取消息列表异常: $e'));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String roomId,
    required String message,
    String? replyToId,
    List<String>? mentions,
  }) async {
    try {
      final endpoint = ApiConfig.chatSendMessageEndpoint.replaceAll('{id}', roomId);
      final response = await _httpService.post(
        endpoint,
        data: {
          'message': message,
          if (replyToId != null) 'replyToId': replyToId,
          if (mentions != null && mentions.isNotEmpty) 'mentions': mentions,
        },
      );

      final sentMessage = ChatMessageDto.fromJson(response.data).toDomain();
      return Success(sentMessage);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('发送消息异常: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    try {
      final endpoint = '${ApiConfig.chatMessagesEndpoint.replaceAll('{id}', roomId)}/$messageId';
      await _httpService.delete(endpoint);

      return Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('删除消息异常: $e'));
    }
  }

  // ==================== 用户管理 ====================

  @override
  Future<Result<List<OnlineUser>>> getOnlineUsers(String roomId) async {
    try {
      final endpoint = ApiConfig.chatParticipantsEndpoint.replaceAll('{id}', roomId);
      final response = await _httpService.get(
        endpoint,
        queryParameters: {'onlineOnly': true},
      );

      final List<dynamic> data = response.data;
      final users = data.map((json) => OnlineUserDto.fromJson(json).toDomain()).toList();

      return Success(users);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取在线用户异常: $e'));
    }
  }

  @override
  Future<Result<List<OnlineUser>>> getRoomMembers({
    required String roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final endpoint = ApiConfig.chatParticipantsEndpoint.replaceAll('{id}', roomId);
      final response = await _httpService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final List<dynamic> data = response.data;
      final users = data.map((json) => OnlineUserDto.fromJson(json).toDomain()).toList();

      return Success(users);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取聊天室成员异常: $e'));
    }
  }

  // ==================== 实时通信 (WebSocket/SSE) ====================

  @override
  Stream<ChatMessage> subscribeToMessages({
    required String roomId,
    Function(ChatMessage message)? onMessage,
    Function(String error)? onError,
  }) {
    // TODO: 实现 WebSocket/SSE 消息订阅
    // 当后端提供 WebSocket API 时实现此方法
    return Stream.empty();
  }

  @override
  Stream<OnlineUser> subscribeToUserStatus({
    required String roomId,
    Function(OnlineUser user)? onUserJoined,
    Function(String userId)? onUserLeft,
  }) {
    // TODO: 实现 WebSocket/SSE 用户状态订阅
    // 当后端提供 WebSocket API 时实现此方法
    return Stream.empty();
  }
}
