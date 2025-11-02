import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../generated/app_localizations.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart' as models;
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';
import 'member_detail_page.dart';

class CityChatPage extends StatelessWidget {
  const CityChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentRoom.value == null) {
          return const ChatListSkeleton();
        }

        // Show chat rooms list if no room is selected
        if (controller.currentRoom.value == null) {
          return _buildChatRoomsList(context, controller, isMobile);
        }

        // Show chat room
        return _buildChatRoom(context, controller, isMobile);
      }),
    );
  }

  // Chat Rooms List
  Widget _buildChatRoomsList(
      BuildContext context, ChatController controller, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined,
                color: AppColors.backButtonDark),
            onPressed: () => Get.back(),
          ),
          iconTheme: const IconThemeData(color: AppColors.backButtonDark),
          title: Text(
            l10n.cityChats,
            style: const TextStyle(
              color: Color(0xFF1a1a1a),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final room = controller.chatRooms[index];
                return _buildChatRoomCard(room, controller, isMobile);
              },
              childCount: controller.chatRooms.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatRoomCard(
      ChatRoom room, ChatController controller, bool isMobile) {
    return InkWell(
      onTap: () => controller.joinRoom(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${room.city}, ${room.country}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${room.onlineUsers} online • ${room.totalMembers} members',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9ca3af),
                ),
              ],
            ),
            if (room.lastMessage != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (room.lastMessage!.userAvatar != null)
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          NetworkImage(room.lastMessage!.userAvatar!),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${room.lastMessage!.userName}: ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          TextSpan(
                            text: room.lastMessage!.message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6b7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(room.lastMessage!.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9ca3af),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Chat Room
  Widget _buildChatRoom(
      BuildContext context, ChatController controller, bool isMobile) {
    final room = controller.currentRoom.value!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonDark),
          onPressed: () {
            controller.currentRoom.value = null;
            controller.messages.clear();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${room.city}, ${room.country}',
              style: const TextStyle(
                color: Color(0xFF1a1a1a),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${room.onlineUsers} online',
              style: const TextStyle(
                color: Color(0xFF6b7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: Color(0xFF1a1a1a)),
            onPressed: () => _showOnlineUsers(controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const MessagesSkeleton();
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.userId == controller.currentUserId;
                  return _buildMessageBubble(message, isMe, controller);
                },
              );
            }),
          ),

          // Reply Preview
          Obx(() {
            if (controller.replyingTo.value != null) {
              return _buildReplyPreview(controller);
            }
            return const SizedBox.shrink();
          }),

          // Input
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, bool isMe, ChatController controller) {
    return GestureDetector(
      onLongPress: () {
        if (!isMe) {
          controller.setReplyTo(message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              GestureDetector(
                onTap: () {
                  // 点击头像查看成员详情
                  _showUserDetail(message);
                },
                child: Hero(
                  tag:
                      'message_avatar_${message.userId}_${message.timestamp.millisecondsSinceEpoch}',
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                        message.userAvatar ?? 'https://i.pravatar.cc/300'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        message.userName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF4458) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMe ? 16 : 4),
                        topRight: Radius.circular(isMe ? 4 : 16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.replyToMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: (isMe
                                      ? Colors.white
                                      : const Color(0xFFF3F4F6))
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.replyToUser!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF6b7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message.replyToMessage!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : const Color(0xFF9ca3af),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isMe ? Colors.white : const Color(0xFF1a1a1a),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9ca3af),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(ChatController controller) {
    final reply = controller.replyingTo.value!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 20, color: Color(0xFFFF4458)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${reply.userName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6b7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: controller.cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    final textController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFFFF4458)),
            onPressed: () => _showAttachmentOptions(controller),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4458),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  controller.sendMessage(textController.text);
                  textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    Get.bottomSheet(
      Container(
        constraints: const BoxConstraints(maxHeight: 450),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.sendAttachment,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildAttachmentOption(
                        icon: Icons.image_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBgColor:
                            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        title: l10n.photoVideo,
                        subtitle: l10n.sharePhotosAndVideos,
                        onTap: () {
                          Get.back();
                          _handleImageUpload(controller);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAttachmentOption(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor:
                            const Color(0xFFEF4444).withValues(alpha: 0.1),
                        title: l10n.location,
                        subtitle: l10n.shareYourLocation,
                        onTap: () {
                          Get.back();
                          _handleLocationShare(controller);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAttachmentOption(
                        icon: Icons.insert_drive_file_outlined,
                        iconColor: const Color(0xFF3B82F6),
                        iconBgColor:
                            const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        title: l10n.document,
                        subtitle: l10n.shareFilesAndDocuments,
                        onTap: () {
                          Get.back();
                          _handleDocumentUpload(controller);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAttachmentOption(
                        icon: Icons.contact_page_outlined,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor:
                            const Color(0xFF10B981).withValues(alpha: 0.1),
                        title: l10n.contact,
                        subtitle: l10n.shareContactInformation,
                        onTap: () {
                          Get.back();
                          _handleContactShare(controller);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageUpload(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    // TODO: 实现图片上传功能
    AppToast.info(
      l10n.imageUploadComingSoon,
      title: l10n.photoVideo,
    );
  }

  void _handleLocationShare(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    // TODO: 实现位置分享功能
    AppToast.info(
      l10n.locationSharingComingSoon,
      title: l10n.location,
    );
  }

  void _handleDocumentUpload(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    // TODO: 实现文档上传功能
    AppToast.info(
      l10n.documentUploadComingSoon,
      title: l10n.document,
    );
  }

  void _handleContactShare(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    // TODO: 实现联系人分享功能
    AppToast.info(
      l10n.contactSharingComingSoon,
      title: l10n.contact,
    );
  }

  void _showOnlineUsers(ChatController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    l10n.onlineMembers,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.onlineUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.onlineUsers[index];
                    return ListTile(
                      onTap: () {
                        // 转换 OnlineUser 到 UserModel 并跳转到详情页
                        Get.to(() => MemberDetailPage(
                              user: _convertToUserModel(user),
                            ));
                      },
                      leading: Hero(
                        tag: 'user_avatar_${user.id}',
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                  user.avatar ?? 'https://i.pravatar.cc/300'),
                            ),
                            if (user.isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        user.isOnline
                            ? l10n.online
                            : l10n.lastSeen(_formatTime(user.lastSeen!)),
                        style: TextStyle(
                          fontSize: 12,
                          color: user.isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF9ca3af),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[time.month - 1]} ${time.day}';
  }

  // 将 OnlineUser 转换为 UserModel 用于显示详情页
  models.UserModel _convertToUserModel(OnlineUser user) {
    return models.UserModel(
      id: user.id,
      name: user.name,
      username: user.name.toLowerCase().replaceAll(' ', '_'),
      bio: 'Digital nomad exploring the world 🌍\n\n'
          'I love working remotely from different cities and meeting amazing people along the way. '
          'Always up for coffee, coworking sessions, or exploring local spots!',
      avatarUrl: user.avatar ?? 'https://i.pravatar.cc/300',
      currentCity: 'Bangkok', // 默认值,实际应从API获取
      currentCountry: 'Thailand',
      skills: [
        models.UserSkillInfo(
          id: '1',
          skillId: '1',
          skillName: 'Flutter',
          icon: '💙',
          category: 'Programming',
          proficiencyLevel: 'Advanced',
          yearsOfExperience: 3,
        ),
        models.UserSkillInfo(
          id: '2',
          skillId: '2',
          skillName: 'Design',
          icon: '🎨',
          category: 'Design',
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: 2,
        ),
        models.UserSkillInfo(
          id: '3',
          skillId: '3',
          skillName: 'Marketing',
          icon: '📢',
          category: 'Business',
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: 2,
        ),
        models.UserSkillInfo(
          id: '4',
          skillId: '4',
          skillName: 'Photography',
          icon: '📷',
          category: 'Creative',
          proficiencyLevel: 'Advanced',
          yearsOfExperience: 4,
        ),
      ],
      interests: [
        models.UserInterestInfo(
          id: '1',
          interestId: '1',
          interestName: 'Travel',
          icon: '✈️',
          category: 'Travel',
          intensityLevel: 'Passionate',
        ),
        models.UserInterestInfo(
          id: '2',
          interestId: '2',
          interestName: 'Coding',
          icon: '💻',
          category: 'Technology',
          intensityLevel: 'Very Interested',
        ),
        models.UserInterestInfo(
          id: '3',
          interestId: '3',
          interestName: 'Coffee',
          icon: '☕',
          category: 'Lifestyle',
          intensityLevel: 'Very Interested',
        ),
        models.UserInterestInfo(
          id: '4',
          interestId: '4',
          interestName: 'Hiking',
          icon: '🥾',
          category: 'Outdoor',
          intensityLevel: 'Interested',
        ),
        models.UserInterestInfo(
          id: '5',
          interestId: '5',
          interestName: 'Photography',
          icon: '📸',
          category: 'Creative',
          intensityLevel: 'Passionate',
        ),
      ],
      socialLinks: {},
      badges: [
        models.Badge(
          id: '1',
          name: 'Early Adopter',
          icon: '🚀',
          description: 'One of the first users',
          earnedDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
        models.Badge(
          id: '2',
          name: 'Globetrotter',
          icon: '🌍',
          description: 'Visited 10+ countries',
          earnedDate: DateTime.now().subtract(const Duration(days: 60)),
        ),
        models.Badge(
          id: '3',
          name: 'Social Butterfly',
          icon: '🦋',
          description: 'Attended 20+ meetups',
          earnedDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      stats: models.TravelStats(
        countriesVisited: 15,
        citiesLived: 8,
        daysNomading: 365,
        meetupsAttended: 42,
        tripsCompleted: 12,
      ),
      travelHistory: [],
      joinedDate: DateTime.now().subtract(const Duration(days: 180)),
      isVerified: true,
    );
  }

  // 从消息对象查看用户详情
  void _showUserDetail(ChatMessage message) {
    // 从消息信息构建 UserModel
    final userModel = models.UserModel(
      id: message.userId,
      name: message.userName,
      username: message.userName.toLowerCase().replaceAll(' ', '_'),
      bio: 'Digital nomad exploring the world 🌍\n\n'
          'I love working remotely from different cities and meeting amazing people along the way. '
          'Always up for coffee, coworking sessions, or exploring local spots!',
      avatarUrl: message.userAvatar ?? 'https://i.pravatar.cc/300',
      currentCity: 'Bangkok', // 默认值,实际应从API获取
      currentCountry: 'Thailand',
      skills: [
        models.UserSkillInfo(
          id: '1',
          skillId: '1',
          skillName: 'Flutter',
          icon: '💙',
          category: 'Programming',
          proficiencyLevel: 'Advanced',
          yearsOfExperience: 3,
        ),
        models.UserSkillInfo(
          id: '2',
          skillId: '2',
          skillName: 'Design',
          icon: '🎨',
          category: 'Design',
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: 2,
        ),
        models.UserSkillInfo(
          id: '3',
          skillId: '3',
          skillName: 'Marketing',
          icon: '📢',
          category: 'Business',
          proficiencyLevel: 'Intermediate',
          yearsOfExperience: 2,
        ),
        models.UserSkillInfo(
          id: '4',
          skillId: '4',
          skillName: 'Photography',
          icon: '📷',
          category: 'Creative',
          proficiencyLevel: 'Advanced',
          yearsOfExperience: 4,
        ),
      ],
      interests: [
        models.UserInterestInfo(
          id: '1',
          interestId: '1',
          interestName: 'Travel',
          icon: '✈️',
          category: 'Travel',
          intensityLevel: 'Passionate',
        ),
        models.UserInterestInfo(
          id: '2',
          interestId: '2',
          interestName: 'Coding',
          icon: '💻',
          category: 'Technology',
          intensityLevel: 'Very Interested',
        ),
        models.UserInterestInfo(
          id: '3',
          interestId: '3',
          interestName: 'Coffee',
          icon: '☕',
          category: 'Lifestyle',
          intensityLevel: 'Very Interested',
        ),
        models.UserInterestInfo(
          id: '4',
          interestId: '4',
          interestName: 'Hiking',
          icon: '🥾',
          category: 'Outdoor',
          intensityLevel: 'Interested',
        ),
        models.UserInterestInfo(
          id: '5',
          interestId: '5',
          interestName: 'Photography',
          icon: '📸',
          category: 'Creative',
          intensityLevel: 'Passionate',
        ),
      ],
      socialLinks: {},
      badges: [
        models.Badge(
          id: '1',
          name: 'Early Adopter',
          icon: '🚀',
          description: 'One of the first users',
          earnedDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
        models.Badge(
          id: '2',
          name: 'Globetrotter',
          icon: '🌍',
          description: 'Visited 10+ countries',
          earnedDate: DateTime.now().subtract(const Duration(days: 60)),
        ),
        models.Badge(
          id: '3',
          name: 'Social Butterfly',
          icon: '🦋',
          description: 'Attended 20+ meetups',
          earnedDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      stats: models.TravelStats(
        countriesVisited: 15,
        citiesLived: 8,
        daysNomading: 365,
        meetupsAttended: 42,
        tripsCompleted: 12,
      ),
      travelHistory: [],
      joinedDate: DateTime.now().subtract(const Duration(days: 180)),
      isVerified: true,
    );

    // 跳转到成员详情页
    Get.to(() => MemberDetailPage(user: userModel));
  }
}
