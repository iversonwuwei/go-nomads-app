import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart' as models;
import '../widgets/skeleton_loader.dart';
import 'member_detail_page.dart';

class DirectChatPage extends StatelessWidget {
  final models.UserModel user;

  const DirectChatPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    // 创建一对一聊天室
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.joinDirectChat(
        user.name,
        user.avatarUrl,
        user.id,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: () {
            // 点击标题查看用户详情
            Get.to(() => MemberDetailPage(user: user));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  user.avatarUrl ?? 'https://i.pravatar.cc/150',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Color(0xFF1a1a1a),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user.currentCity != null)
                      Text(
                        user.currentCity!,
                        style: const TextStyle(
                          color: Color(0xFF6b7280),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // 更多选项
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1a1a1a)),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.to(() => MemberDetailPage(user: user));
                  break;
                case 'mute':
                  Get.snackbar(
                    'Muted',
                    'Notifications muted for ${user.name}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF10B981),
                    colorText: Colors.white,
                  );
                  break;
                case 'block':
                  _showBlockDialog(user.name);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Mute Notifications'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_outlined, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Block User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.messages);
        }

        return Column(
          children: [
            // Messages
            Expanded(
              child: controller.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe = message.userId == controller.currentUserId;
                        return _buildMessageBubble(message, isMe, controller);
                      },
                    ),
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
        );
      }),
    );
  }

  // 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: const Color(0xFF6b7280).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Start your conversation with ${user.name}',
            style: const TextStyle(
              color: Color(0xFF6b7280),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 消息气泡
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
                  Get.to(() => MemberDetailPage(user: user));
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    user.avatarUrl ?? 'https://i.pravatar.cc/150',
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
                        // Reply preview in message
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

                        // Message content
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe ? Colors.white : const Color(0xFF1a1a1a),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Timestamp
                        Text(
                          _formatTime(message.timestamp),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reply preview bar
  Widget _buildReplyPreview(ChatController controller) {
    final replyTo = controller.replyingTo.value!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyTo.userName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyTo.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6b7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => controller.cancelReply(),
          ),
        ],
      ),
    );
  }

  // Message input
  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Emoji button
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFF6b7280)),
              onPressed: () {
                // TODO: Show emoji picker
                Get.snackbar(
                  'Emoji',
                  'Emoji picker coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
              },
            ),

            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageInputController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9ca3af),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedBuilder(
              animation: controller.messageInputController,
              builder: (context, child) {
                final hasText = controller.messageInputController.text.trim().isNotEmpty;
                return Container(
                  decoration: BoxDecoration(
                    color: hasText
                        ? const Color(0xFFFF4458)
                        : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: hasText
                        ? () {
                            final text = controller.messageInputController.text;
                            if (text.trim().isNotEmpty) {
                              controller.sendMessage(text);
                              controller.messageInputController.clear();
                            }
                          }
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showBlockDialog(String userName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block $userName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous page
              Get.snackbar(
                'Blocked',
                '$userName has been blocked',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
