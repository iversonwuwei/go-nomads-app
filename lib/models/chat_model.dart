class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final DateTime timestamp;
  final String? replyToId;
  final String? replyToMessage;
  final String? replyToUser;
  final List<String> mentions;

  ChatMessage({
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      replyToId: json['replyToId'] as String?,
      replyToMessage: json['replyToMessage'] as String?,
      replyToUser: json['replyToUser'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'replyToId': replyToId,
      'replyToMessage': replyToMessage,
      'replyToUser': replyToUser,
      'mentions': mentions,
    };
  }
}

class ChatRoom {
  final String id;
  final String city;
  final String country;
  final int onlineUsers;
  final int totalMembers;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.city,
    required this.country,
    required this.onlineUsers,
    required this.totalMembers,
    this.lastMessage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      onlineUsers: json['onlineUsers'] as int,
      totalMembers: json['totalMembers'] as int,
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

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
}

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

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['isOnline'] as bool,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}
