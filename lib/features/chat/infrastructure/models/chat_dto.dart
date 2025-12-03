import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';

/// AuthorDto - 消息作者 DTO
class AuthorDto {
  final String userId;
  final String userName;
  final String? userAvatar;

  AuthorDto({
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory AuthorDto.fromJson(Map<String, dynamic> json) {
    return AuthorDto(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
    };
  }
}

/// ReplyDto - 回复消息 DTO
class ReplyDto {
  final String messageId;
  final String message;
  final String userName;

  ReplyDto({
    required this.messageId,
    required this.message,
    required this.userName,
  });

  factory ReplyDto.fromJson(Map<String, dynamic> json) {
    return ReplyDto(
      messageId: json['messageId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'message': message,
      'userName': userName,
    };
  }
}

/// AttachmentDto - 附件 DTO
class AttachmentDto {
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int? duration;
  final int? width;
  final int? height;

  AttachmentDto({
    required this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.latitude,
    this.longitude,
    this.locationName,
    this.duration,
    this.width,
    this.height,
  });

  factory AttachmentDto.fromJson(Map<String, dynamic> json) {
    return AttachmentDto(
      url: json['url'] as String? ?? '',
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'duration': duration,
      'width': width,
      'height': height,
    };
  }

  MessageAttachment toDomain() {
    return MessageAttachment(
      url: url,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      duration: duration,
      width: width,
      height: height,
    );
  }
}

/// ChatMessage DTO - 基础设施层数据传输对象
class ChatMessageDto {
  final String id;
  final AuthorDto author;
  final String message;
  final String messageType;
  final ReplyDto? replyTo;
  final List<String> mentions;
  final AttachmentDto? attachment;
  final String timestamp;

  ChatMessageDto({
    required this.id,
    required this.author,
    required this.message,
    this.messageType = 'text',
    this.replyTo,
    this.mentions = const [],
    this.attachment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'message': message,
      'messageType': messageType,
      'replyTo': replyTo?.toJson(),
      'mentions': mentions,
      'attachment': attachment?.toJson(),
      'timestamp': timestamp,
    };
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String? ?? '',
      author: json['author'] != null
          ? AuthorDto.fromJson(json['author'] as Map<String, dynamic>)
          : AuthorDto(userId: '', userName: ''),
      message: json['message'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'text',
      replyTo: json['replyTo'] != null ? ReplyDto.fromJson(json['replyTo'] as Map<String, dynamic>) : null,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      attachment:
          json['attachment'] != null ? AttachmentDto.fromJson(json['attachment'] as Map<String, dynamic>) : null,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// 转换为领域实体
  ChatMessage toDomain() {
    MessageReply? reply;
    if (replyTo != null) {
      reply = MessageReply(
        messageId: replyTo!.messageId,
        message: replyTo!.message,
        userName: replyTo!.userName,
      );
    }

    // 解析消息类型
    MessageType type;
    switch (messageType) {
      case 'image':
        type = MessageType.image;
        break;
      case 'file':
        type = MessageType.file;
        break;
      case 'location':
        type = MessageType.location;
        break;
      case 'voice':
        type = MessageType.voice;
        break;
      case 'video':
        type = MessageType.video;
        break;
      default:
        type = MessageType.text;
    }

    return ChatMessage(
      id: id,
      author: MessageAuthor(
        userId: author.userId,
        userName: author.userName,
        userAvatar: author.userAvatar,
      ),
      message: message,
      type: type,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
      replyTo: reply,
      mentions: mentions,
      attachment: attachment?.toDomain(),
    );
  }
}

/// ChatRoom DTO
class ChatRoomDto {
  final String id;
  final String roomType;
  final String? meetupId;
  final String name;
  final String? description;
  final String? city;
  final String? country;
  final String? imageUrl;
  final int totalMembers;
  final int onlineUsers;
  final ChatMessageDto? lastMessage;
  final String? createdAt;

  ChatRoomDto({
    required this.id,
    this.roomType = 'city',
    this.meetupId,
    required this.name,
    this.description,
    this.city,
    this.country,
    this.imageUrl,
    this.totalMembers = 0,
    this.onlineUsers = 0,
    this.lastMessage,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomType': roomType,
      'meetupId': meetupId,
      'name': name,
      'description': description,
      'city': city,
      'country': country,
      'imageUrl': imageUrl,
      'totalMembers': totalMembers,
      'onlineUsers': onlineUsers,
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt,
    };
  }

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) {
    return ChatRoomDto(
      id: json['id'] as String? ?? '',
      roomType: json['roomType'] as String? ?? 'city',
      meetupId: json['meetupId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      imageUrl: json['imageUrl'] as String?,
      totalMembers: json['totalMembers'] as int? ?? 0,
      onlineUsers: json['onlineUsers'] as int? ?? 0,
      lastMessage:
          json['lastMessage'] != null ? ChatMessageDto.fromJson(json['lastMessage'] as Map<String, dynamic>) : null,
      createdAt: json['createdAt'] as String?,
    );
  }

  /// 转换为领域实体
  ChatRoom toDomain() {
    return ChatRoom(
      id: id,
      roomType: roomType == 'meetup' ? ChatRoomType.meetup : ChatRoomType.city,
      meetupId: meetupId,
      meetupTitle: roomType == 'meetup' ? name : null,
      location: RoomLocation(
        city: city ?? name,
        country: country ?? description ?? '',
      ),
      stats: RoomStats(
        onlineUsers: onlineUsers,
        totalMembers: totalMembers,
      ),
      lastMessage: lastMessage?.toDomain(),
    );
  }
}

/// OnlineUser DTO (对应后端 MemberDto)
class OnlineUserDto {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String role;
  final bool isOnline;
  final String? lastSeenAt;

  OnlineUserDto({
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.role = 'member',
    required this.isOnline,
    this.lastSeenAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'role': role,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt,
    };
  }

  factory OnlineUserDto.fromJson(Map<String, dynamic> json) {
    return OnlineUserDto(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      role: json['role'] as String? ?? 'member',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] as String?,
    );
  }

  /// 转换为领域实体
  OnlineUser toDomain() {
    return OnlineUser(
      id: userId,
      name: userName,
      avatar: userAvatar,
      role: role,
      isOnline: isOnline,
      lastSeen: lastSeenAt != null ? DateTime.tryParse(lastSeenAt!) : null,
    );
  }
}
