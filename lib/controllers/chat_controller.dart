import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_model.dart';

class ChatController extends GetxController {
  final RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<OnlineUser> onlineUsers = <OnlineUser>[].obs;
  final Rx<ChatRoom?> currentRoom = Rx<ChatRoom?>(null);
  final RxBool isLoading = true.obs;
  final Rx<ChatMessage?> replyingTo = Rx<ChatMessage?>(null);
  
  // 消息输入控制器
  final messageInputController = TextEditingController();

  final String currentUserId = 'user_001';
  final String currentUserName = 'Alex Chen';
  final String currentUserAvatar = 'https://i.pravatar.cc/300?img=33';

  @override
  void onInit() {
    super.onInit();
    
    // 检查是否从其他页面传递了参数
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      // 一对一聊天
      final isDirect = arguments['isDirect'] as bool?;
      if (isDirect == true) {
        final userName = arguments['userName'] as String?;
        final userAvatar = arguments['userAvatar'] as String?;
        final userId = arguments['userId'] as String?;
        if (userName != null) {
          joinDirectChat(userName, userAvatar, userId);
          return;
        }
      }

      // 群聊
      final city = arguments['city'] as String?;
      final country = arguments['country'] as String?;
      if (city != null && country != null) {
        // 直接加入指定城市的聊天室
        joinRoomByCity(city, country);
        return;
      }
    }
    
    loadChatRooms();
  }
  
  // 加入一对一聊天
  void joinDirectChat(String userName, String? userAvatar, String? userId) {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      // 创建一对一聊天室
      final room = ChatRoom(
        id: 'direct_${userId ?? userName.toLowerCase().replaceAll(' ', '_')}',
        city: userName,
        country: 'Direct Message',
        onlineUsers: 1,
        totalMembers: 2,
        lastMessage: null,
      );

      currentRoom.value = room;
      messages.value = _generateDirectMessages(userName, userAvatar);
      isLoading.value = false;
    });
  }

  // 加载聊天室列表
  void loadChatRooms() {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      chatRooms.value = _generateMockChatRooms();
      isLoading.value = false;
    });
  }
  
  // 根据城市名称加入聊天室
  void joinRoomByCity(String city, String country) {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      // 创建或查找该城市的聊天室
      final existingRoom = chatRooms.firstWhereOrNull(
        (room) => room.city.toLowerCase() == city.toLowerCase(),
      );

      final room = existingRoom ??
          ChatRoom(
            id: 'room_${city.toLowerCase().replaceAll(' ', '_')}',
            city: city,
            country: country,
            onlineUsers: 12,
            totalMembers: 234,
            lastMessage: null,
          );

      // 如果是新房间，添加到列表
      if (existingRoom == null) {
        chatRooms.insert(0, room);
      }

      // 加入聊天室
      joinRoom(room);
    });
  }

  // 加载聊天室消息
  void joinRoom(ChatRoom room) {
    currentRoom.value = room;
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      messages.value = _generateMockMessages(room.city);
      onlineUsers.value = _generateOnlineUsers();
      isLoading.value = false;
    });
  }

  // 发送消息
  void sendMessage(String text) {
    if (text.trim().isEmpty || currentRoom.value == null) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      message: text.trim(),
      timestamp: DateTime.now(),
      replyToId: replyingTo.value?.id,
      replyToMessage: replyingTo.value?.message,
      replyToUser: replyingTo.value?.userName,
      mentions: _extractMentions(text),
    );

    messages.insert(0, newMessage);
    replyingTo.value = null;

    // 更新聊天室的最后一条消息
    final roomIndex = chatRooms.indexWhere((r) => r.id == currentRoom.value!.id);
    if (roomIndex != -1) {
      chatRooms[roomIndex] = ChatRoom(
        id: chatRooms[roomIndex].id,
        city: chatRooms[roomIndex].city,
        country: chatRooms[roomIndex].country,
        onlineUsers: chatRooms[roomIndex].onlineUsers,
        totalMembers: chatRooms[roomIndex].totalMembers,
        lastMessage: newMessage,
      );
      chatRooms.refresh();
    }
  }

  // 设置回复
  void setReplyTo(ChatMessage message) {
    replyingTo.value = message;
  }

  // 取消回复
  void cancelReply() {
    replyingTo.value = null;
  }

  // 提取@提及
  List<String> _extractMentions(String text) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  // 生成示例聊天室
  List<ChatRoom> _generateMockChatRooms() {
    return [
      ChatRoom(
        id: 'room_bangkok',
        city: 'Bangkok',
        country: 'Thailand',
        onlineUsers: 45,
        totalMembers: 1234,
        lastMessage: ChatMessage(
          id: 'msg_1',
          userId: 'user_002',
          userName: 'Sarah Kim',
          userAvatar: 'https://i.pravatar.cc/300?img=5',
          message: 'Anyone knows a good coworking space in Sukhumvit?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ),
      ChatRoom(
        id: 'room_chiangmai',
        city: 'Chiang Mai',
        country: 'Thailand',
        onlineUsers: 32,
        totalMembers: 876,
        lastMessage: ChatMessage(
          id: 'msg_2',
          userId: 'user_003',
          userName: 'Mike Johnson',
          userAvatar: 'https://i.pravatar.cc/300?img=12',
          message: 'The night market is amazing! 🌮',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ),
      ChatRoom(
        id: 'room_bali',
        city: 'Bali',
        country: 'Indonesia',
        onlineUsers: 28,
        totalMembers: 654,
        lastMessage: ChatMessage(
          id: 'msg_3',
          userId: 'user_004',
          userName: 'Emma Davis',
          userAvatar: 'https://i.pravatar.cc/300?img=9',
          message: 'Surf lessons at Canggu tomorrow, who\'s in?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ),
      ChatRoom(
        id: 'room_lisbon',
        city: 'Lisbon',
        country: 'Portugal',
        onlineUsers: 18,
        totalMembers: 432,
        lastMessage: ChatMessage(
          id: 'msg_4',
          userId: 'user_005',
          userName: 'Carlos Silva',
          userAvatar: 'https://i.pravatar.cc/300?img=14',
          message: 'Best pastel de nata in Belém!',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ),
    ];
  }

  // 生成示例消息
  List<ChatMessage> _generateMockMessages(String city) {
    return [
      ChatMessage(
        id: 'msg_10',
        userId: 'user_002',
        userName: 'Sarah Kim',
        userAvatar: 'https://i.pravatar.cc/300?img=5',
        message: 'Anyone knows a good coworking space in $city?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ChatMessage(
        id: 'msg_11',
        userId: 'user_003',
        userName: 'Mike Johnson',
        userAvatar: 'https://i.pravatar.cc/300?img=12',
        message: '@SarahKim I recommend Hubba! Great atmosphere and fast WiFi',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        mentions: ['SarahKim'],
      ),
      ChatMessage(
        id: 'msg_12',
        userId: 'user_004',
        userName: 'Emma Davis',
        userAvatar: 'https://i.pravatar.cc/300?img=9',
        message: 'Just arrived yesterday! Where\'s the best coffee?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        id: 'msg_13',
        userId: 'user_005',
        userName: 'Carlos Silva',
        userAvatar: 'https://i.pravatar.cc/300?img=14',
        message: 'Welcome! Try the café near the old town',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        replyToId: 'msg_12',
        replyToMessage: 'Just arrived yesterday! Where\'s the best coffee?',
        replyToUser: 'Emma Davis',
      ),
      ChatMessage(
        id: 'msg_14',
        userId: 'user_006',
        userName: 'Lisa Chen',
        userAvatar: 'https://i.pravatar.cc/300?img=20',
        message: 'Anyone want to join for dinner tonight? 🍜',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'msg_15',
        userId: currentUserId,
        userName: currentUserName,
        userAvatar: currentUserAvatar,
        message: '@LisaChen Count me in! What time?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        mentions: ['LisaChen'],
      ),
    ];
  }

  // 生成一对一聊天消息
  List<ChatMessage> _generateDirectMessages(
      String userName, String? userAvatar) {
    final avatar = userAvatar ?? 'https://i.pravatar.cc/300?img=10';
    return [
      ChatMessage(
        id: 'dm_1',
        userId: 'other_user',
        userName: userName,
        userAvatar: avatar,
        message: 'Hey! How are you doing?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: 'dm_2',
        userId: currentUserId,
        userName: currentUserName,
        userAvatar: currentUserAvatar,
        message: 'Hi! I\'m good, thanks! How about you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'dm_3',
        userId: 'other_user',
        userName: userName,
        userAvatar: avatar,
        message: 'Doing great! Are you still in town?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  // 生成在线用户
  List<OnlineUser> _generateOnlineUsers() {
    return [
      OnlineUser(
        id: 'user_002',
        name: 'Sarah Kim',
        avatar: 'https://i.pravatar.cc/300?img=5',
        isOnline: true,
      ),
      OnlineUser(
        id: 'user_003',
        name: 'Mike Johnson',
        avatar: 'https://i.pravatar.cc/300?img=12',
        isOnline: true,
      ),
      OnlineUser(
        id: 'user_004',
        name: 'Emma Davis',
        avatar: 'https://i.pravatar.cc/300?img=9',
        isOnline: true,
      ),
      OnlineUser(
        id: 'user_005',
        name: 'Carlos Silva',
        avatar: 'https://i.pravatar.cc/300?img=14',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      OnlineUser(
        id: 'user_006',
        name: 'Lisa Chen',
        avatar: 'https://i.pravatar.cc/300?img=20',
        isOnline: true,
      ),
    ];
  }
}
