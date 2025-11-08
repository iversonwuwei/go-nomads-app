import '../../domain/entities/chat.dart';

/// ChatMessage DTO - 基础设施层数据传输对象
class ChatMessageDto {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final String timestamp;
  final String? replyToId;
  final String? replyToMessage;
  final String? replyToUser;
  final List<String> mentions;

  ChatMessageDto({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    required this.timestamp,
    this.replyToId,
    this.replyToMessage,
    this.replyToUser,
    this.mentions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'message': message,
      'timestamp': timestamp,
      'replyToId': replyToId,
      'replyToMessage': replyToMessage,
      'replyToUser': replyToUser,
      'mentions': mentions,
    };
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      replyToId: json['replyToId'] as String?,
      replyToMessage: json['replyToMessage'] as String?,
      replyToUser: json['replyToUser'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// 转换为领域实体
  ChatMessage toDomain() {
    MessageReply? reply;
    if (replyToId != null && replyToMessage != null && replyToUser != null) {
      reply = MessageReply(
        messageId: replyToId!,
        message: replyToMessage!,
        userName: replyToUser!,
      );
    }

    return ChatMessage(
      id: id,
      author: MessageAuthor(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      ),
      message: message,
      timestamp: DateTime.parse(timestamp),
      replyTo: reply,
      mentions: mentions,
    );
  }
}

/// ChatRoom DTO
class ChatRoomDto {
  final String id;
  final String city;
  final String country;
  final int onlineUsers;
  final int totalMembers;
  final ChatMessageDto? lastMessage;

  ChatRoomDto({
    required this.id,
    required this.city,
    required this.country,
    required this.onlineUsers,
    required this.totalMembers,
    this.lastMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'country': country,
      'onlineUsers': onlineUsers,
      'totalMembers': totalMembers,
      'lastMessage': lastMessage?.toJson(),
    };
  }

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) {
    return ChatRoomDto(
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      onlineUsers: json['onlineUsers'] as int,
      totalMembers: json['totalMembers'] as int,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageDto.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为领域实体
  ChatRoom toDomain() {
    return ChatRoom(
      id: id,
      location: RoomLocation(
        city: city,
        country: country,
      ),
      stats: RoomStats(
        onlineUsers: onlineUsers,
        totalMembers: totalMembers,
      ),
      lastMessage: lastMessage?.toDomain(),
    );
  }
}

/// OnlineUser DTO
class OnlineUserDto {
  final String id;
  final String name;
  final String? avatar;
  final bool isOnline;
  final String? lastSeen;

  OnlineUserDto({
    required this.id,
    required this.name,
    this.avatar,
    required this.isOnline,
    this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }

  factory OnlineUserDto.fromJson(Map<String, dynamic> json) {
    return OnlineUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['isOnline'] as bool,
      lastSeen: json['lastSeen'] as String?,
    );
  }

  /// 转换为领域实体
  OnlineUser toDomain() {
    return OnlineUser(
      id: id,
      name: name,
      avatar: avatar,
      isOnline: isOnline,
      lastSeen: lastSeen != null ? DateTime.parse(lastSeen!) : null,
    );
  }
}
