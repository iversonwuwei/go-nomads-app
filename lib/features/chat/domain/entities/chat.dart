/// ChatMessage 领域实体
/// 聊天消息实体
class ChatMessage {
  final String id;
  final MessageAuthor author;
  final String message;
  final DateTime timestamp;
  final MessageReply? replyTo;
  final List<String> mentions;

  ChatMessage({
    required this.id,
    required this.author,
    required this.message,
    required this.timestamp,
    this.replyTo,
    this.mentions = const [],
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
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
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

/// ChatRoom 聚合根
/// 聊天室聚合根
class ChatRoom {
  final String id;
  final RoomLocation location;
  final RoomStats stats;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.location,
    required this.stats,
    this.lastMessage,
  });

  // === 业务逻辑方法 ===

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
  String get displayName => '${location.city}, ${location.country}';

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
  final bool isOnline;
  final DateTime? lastSeen;

  OnlineUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.isOnline,
    this.lastSeen,
  });

  // === 业务逻辑方法 ===

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
