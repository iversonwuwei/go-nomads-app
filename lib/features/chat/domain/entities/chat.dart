/// ChatMessage 领域实体
/// 聊天消息实体
class ChatMessage {
  final String id;
  final String? roomId; // 消息所属房间ID，用于私聊消息过滤
  final MessageAuthor author;
  final String message;
  final DateTime timestamp;
  final MessageReply? replyTo;
  final List<String> mentions;
  final MessageType type;
  final MessageAttachment? attachment;

  ChatMessage({
    required this.id,
    this.roomId,
    required this.author,
    required this.message,
    required this.timestamp,
    this.replyTo,
    this.mentions = const [],
    this.type = MessageType.text,
    this.attachment,
  });

  // === 业务逻辑方法 ===

  /// 是否是回复消息
  bool get isReply => replyTo != null;

  /// 是否提及了用户
  bool mentionsUser(String userId) => mentions.contains(userId);

  /// 是否是最近的消息 (5分钟内)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  /// 是否是今天的消息
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day;
  }

  /// 获取格式化的时间戳
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 消息长度
  int get messageLength => message.length;

  /// 是否是长消息 (>500字符)
  bool get isLongMessage => messageLength > 500;
}

/// MessageAuthor 值对象
class MessageAuthor {
  final String userId;
  final String userName;
  final String? userAvatar;

  MessageAuthor({
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  bool get hasAvatar => userAvatar != null && userAvatar!.isNotEmpty;
}

/// MessageReply 值对象
class MessageReply {
  final String messageId;
  final String message;
  final String userName;

  MessageReply({
    required this.messageId,
    required this.message,
    required this.userName,
  });
}

/// 消息类型枚举
enum MessageType {
  text,
  image,
  file,
  location,
  voice,
  video,
}

/// 消息附件
class MessageAttachment {
  final String url;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int? duration; // 语音/视频时长(秒)
  final int? width;
  final int? height;

  MessageAttachment({
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

  /// 是否是位置消息
  bool get isLocation => latitude != null && longitude != null;

  /// 是否是图片
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// 是否是视频
  bool get isVideo => mimeType?.startsWith('video/') ?? false;

  /// 格式化文件大小
  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 聊天室类型
enum ChatRoomType {
  city, // 城市聊天室
  meetup, // 聚会活动聊天室
  direct, // 私聊
}

/// ChatRoom 聚合根
/// 聊天室聚合根
class ChatRoom {
  final String id;
  final RoomLocation location;
  final RoomStats stats;
  final ChatMessage? lastMessage;
  final ChatRoomType roomType;
  final String? meetupId;
  final String? meetupTitle;

  ChatRoom({
    required this.id,
    required this.location,
    required this.stats,
    this.lastMessage,
    this.roomType = ChatRoomType.city,
    this.meetupId,
    this.meetupTitle,
  });

  // === 业务逻辑方法 ===

  /// 是否是 Meetup 聊天室
  bool get isMeetupRoom => roomType == ChatRoomType.meetup;

  /// 是否有活跃用户
  bool get hasActiveUsers => stats.onlineUsers > 0;

  /// 在线率
  double get onlineRate {
    if (stats.totalMembers == 0) return 0;
    return stats.onlineUsers / stats.totalMembers;
  }

  /// 是否是热门房间 (在线率>30%)
  bool get isPopular => onlineRate > 0.3;

  /// 是否是大型房间 (>100成员)
  bool get isLargeRoom => stats.totalMembers > 100;

  /// 房间显示名称
  String get displayName {
    if (isMeetupRoom && meetupTitle != null) {
      return meetupTitle!;
    }
    return '${location.city}, ${location.country}';
  }

  /// 是否有最近消息
  bool get hasRecentActivity => lastMessage != null && lastMessage!.isRecent;
}

/// RoomLocation 值对象
class RoomLocation {
  final String city;
  final String country;

  RoomLocation({
    required this.city,
    required this.country,
  });

  String get fullLocation => '$city, $country';
}

/// RoomStats 值对象
class RoomStats {
  final int onlineUsers;
  final int totalMembers;

  RoomStats({
    required this.onlineUsers,
    required this.totalMembers,
  });

  bool get hasMembers => totalMembers > 0;
  bool get isEmpty => totalMembers == 0;
}

/// OnlineUser 实体
/// 在线用户实体
class OnlineUser {
  final String id;
  final String name;
  final String? avatar;
  final String role; // 角色: owner, admin, member
  final bool isOnline;
  final DateTime? lastSeen;

  OnlineUser({
    required this.id,
    required this.name,
    this.avatar,
    this.role = 'member',
    required this.isOnline,
    this.lastSeen,
  });

  // === 业务逻辑方法 ===

  /// 是否是创建者/群主（兼容 owner 和 organizer 角色）
  bool get isOwner => role == 'owner' || role == 'organizer';

  /// 是否是管理员
  bool get isAdmin => role == 'admin' || isOwner;

  /// 是否有头像
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// 是否最近在线 (1小时内)
  bool get wasRecentlyOnline {
    if (isOnline) return true;
    if (lastSeen == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    return difference.inHours <= 1;
  }

  /// 获取在线状态文本
  String get statusText {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
