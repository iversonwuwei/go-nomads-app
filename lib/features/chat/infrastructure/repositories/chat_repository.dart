import 'dart:developer';

import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';
import 'package:go_nomads_app/features/chat/domain/repositories/i_chat_local_repository.dart';
import 'package:go_nomads_app/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:go_nomads_app/features/chat/infrastructure/models/chat_dto.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/chat_file_storage_service.dart';
import 'package:go_nomads_app/services/http_service.dart';

/// Chat Repository 实现
///
/// 职责:
/// - 调用后端 API 获取聊天数据
/// - 将 DTO 转换为 Domain Entity
/// - 处理错误并返回 Result 对象
/// - 集成文件存储实现聊天记录持久化和搜索
/// - 集成本地缓存实现离线访问
class ChatRepository implements IChatRepository {
  final HttpService _httpService;
  final IChatLocalRepository? _localRepository;
  final ChatFileStorageService? _fileStorageService;

  ChatRepository(this._httpService, [this._localRepository, this._fileStorageService]);

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

  List<dynamic> _extractListData(dynamic data, {String? listKey}) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (listKey != null && data[listKey] is List<dynamic>) {
        return data[listKey] as List<dynamic>;
      }

      if (data['items'] is List<dynamic>) {
        return data['items'] as List<dynamic>;
      }

      if (data['data'] is List<dynamic>) {
        return data['data'] as List<dynamic>;
      }
    }

    return const [];
  }

  // ==================== 聊天室管理 ====================

  @override
  Future<Result<List<ChatRoom>>> getChatRooms() async {
    try {
      final response = await _httpService.get(
        ApiConfig.chatsEndpoint,
      );

      final List<dynamic> data = _extractListData(response.data);
      final rooms = data.map((json) => ChatRoomDto.fromJson(json).toDomain()).toList();

      // 保存到本地缓存
      if (_localRepository != null && rooms.isNotEmpty) {
        await _localRepository.saveChatRooms(rooms);
        log('💾 聊天室列表已缓存到本地');
      }

      return Success(rooms);
    } on HttpException catch (e) {
      // 网络错误时尝试从本地缓存获取
      if (_localRepository != null) {
        final localRooms = await _localRepository.getLocalChatRooms();
        if (localRooms.isNotEmpty) {
          log('📱 使用本地缓存的聊天室列表');
          return Success(localRooms);
        }
      }
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

  @override
  Future<Result<ChatRoom>> getOrCreateDirectChat({
    required String targetUserId,
    required String targetUserName,
    String? targetUserAvatar,
  }) async {
    try {
      final response = await _httpService.post(
        '${ApiConfig.chatsEndpoint}/direct',
        data: {
          'targetUserId': targetUserId,
          'targetUserName': targetUserName,
          if (targetUserAvatar != null) 'targetUserAvatar': targetUserAvatar,
        },
      );

      final room = ChatRoomDto.fromJson(response.data).toDomain();
      return Success(room);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('创建私聊异常: $e'));
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

      final List<dynamic> data = _extractListData(response.data, listKey: 'messages');
      final messages = data.map((json) => ChatMessageDto.fromJson(json).toDomain()).toList();

      // 保存到文件存储（按天分文件）
      if (_fileStorageService != null && messages.isNotEmpty) {
        await _fileStorageService.saveMessages(messages, roomId);
        log('💾 ${messages.length} 条消息已保存到文件');
      }

      // 同时保存到 SQLite 本地缓存
      if (_localRepository != null && messages.isNotEmpty) {
        await _localRepository.saveMessages(roomId, messages);
        log('💾 ${messages.length} 条消息已缓存到本地');
      }

      return Success(messages);
    } on HttpException catch (e) {
      // 网络错误时尝试从本地缓存获取
      if (_localRepository != null) {
        final localMessages = await _localRepository.getLocalMessages(
          roomId: roomId,
          page: page,
          pageSize: pageSize,
        );
        if (localMessages.isNotEmpty) {
          log('📱 使用本地缓存的消息列表');
          return Success(localMessages);
        }
      }
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

      // 保存到文件存储（按天分文件）
      if (_fileStorageService != null) {
        await _fileStorageService.saveMessage(sentMessage, roomId);
        log('💾 发送的消息已保存到文件');
      }

      // 同时保存到 SQLite 本地缓存
      if (_localRepository != null) {
        await _localRepository.saveMessage(roomId, sentMessage);
        await _localRepository.updateLastMessage(roomId, sentMessage);
        log('💾 发送的消息已缓存到本地');
      }

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

      final List<dynamic> data = _extractListData(response.data, listKey: 'members');
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

      final List<dynamic> data = _extractListData(response.data, listKey: 'members');
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

  // ==================== 消息搜索 (基于文件存储) ====================

  @override
  Future<Result<List<ChatMessage>>> searchMessages({
    required String keyword,
    String? roomId,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 优先使用文件存储服务搜索（聊天记录按天保存为JSON文件）
    if (_fileStorageService != null) {
      try {
        final results = await _fileStorageService.searchMessages(
          keyword: keyword,
          roomId: roomId,
          page: page,
          pageSize: pageSize,
        );

        log('🔍 文件搜索找到 ${results.length} 条消息');
        return Success(results);
      } catch (e) {
        log('⚠️ 文件搜索失败: $e，尝试本地数据库搜索');
      }
    }

    // 回退到 SQLite 本地数据库搜索
    if (_localRepository != null) {
      try {
        final localResults = await _localRepository.searchMessages(
          keyword: keyword,
          roomId: roomId,
          page: page,
          pageSize: pageSize,
        );

        if (localResults.isNotEmpty) {
          log('🔍 SQLite搜索找到 ${localResults.length} 条消息');
          return Success(localResults);
        }
      } catch (e) {
        log('⚠️ SQLite搜索失败: $e');
      }
    }

    // 都没有结果
    return Success([]);
  }

  @override
  Future<Result<int>> getSearchCount({
    required String keyword,
    String? roomId,
  }) async {
    // 优先使用文件存储服务获取数量
    if (_fileStorageService != null) {
      try {
        final count = await _fileStorageService.searchMessagesCount(
          keyword: keyword,
          roomId: roomId,
        );
        return Success(count);
      } catch (e) {
        log('⚠️ 文件搜索计数失败: $e');
      }
    }

    // 回退到 SQLite 本地数据库获取数量
    if (_localRepository != null) {
      try {
        final count = await _localRepository.searchMessagesCount(
          keyword: keyword,
          roomId: roomId,
        );
        return Success(count);
      } catch (e) {
        log('⚠️ SQLite搜索计数失败: $e');
      }
    }

    return Success(0);
  }
}
