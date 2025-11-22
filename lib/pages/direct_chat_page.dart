import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../features/chat/domain/entities/chat.dart';
import '../features/chat/presentation/controllers/chat_state_controller.dart';
import '../features/user/domain/entities/user.dart' as models;
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';
import 'member_detail_page.dart';

/// 私聊页面 - Snapchat 风格设计
///
/// 设计理念:
/// - 年轻活力的配色(红色主题)
/// - 流畅的动画和手势交互
/// - 简洁直观的消息界面
/// - 支持滑动删除、长按操作等
class DirectChatPage extends StatefulWidget {
  final models.User user;

  const DirectChatPage({
    super.key,
    required this.user,
  });

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatStateController>();

    // Direct chat 功能暂不支持 (仅支持聊天室)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.joinDirectChat(widget.user.name, widget.user.avatarUrl, widget.user.id);
    // });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFC00),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: () {
            Get.to(() => MemberDetailPage(user: widget.user));
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (widget.user.avatarUrl != null &&
                            widget.user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.user.avatarUrl!)
                        : null,
                    child: (widget.user.avatarUrl == null ||
                            widget.user.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 24)
                        : null,
                  ),
                  // 在线状态指示器
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D856),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFFC00), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.user.currentCity ?? '在线',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black, size: 28),
            onPressed: () => AppToast.info('视频通话功能即将推出'),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black, size: 24),
            onPressed: () => AppToast.info('语音通话功能即将推出'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.to(() => MemberDetailPage(user: widget.user));
                  break;
                case 'mute':
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.success(
                    l10n.notificationsMuted,
                    title: l10n.muted,
                  );
                  break;
                case 'block':
                  _showBlockDialog(widget.user.name, context);
                  break;
              }
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.viewProfile),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_off_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.muteNotifications),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      const Icon(Icons.block_outlined,
                          size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(l10n.blockUser,
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const MessagesSkeleton();
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
                        final isMe = message.author.userId == widget.user.id;
                        return _buildMessageBubble(message, isMe, controller);
                      },
                    ),
            ),

            // Reply Preview
            Obx(() {
              if (controller.replyTo != null) {
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
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
                l10n.startConversation,
                style: const TextStyle(
                  color: Color(0xFF6b7280),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 消息气泡
  Widget _buildMessageBubble(
      ChatMessage message, bool isMe, ChatStateController controller) {
    return GestureDetector(
      onLongPress: () {
        if (!isMe) {
          controller.setReplyTo(message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => MemberDetailPage(user: widget.user));
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: (widget.user.avatarUrl != null &&
                          widget.user.avatarUrl!.isNotEmpty)
                      ? NetworkImage(widget.user.avatarUrl!)
                      : null,
                  child: (widget.user.avatarUrl == null ||
                          widget.user.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 20)
                      : null,
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5E62), Color(0xFFFF3838)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMe ? 20 : 4),
                        topRight: Radius.circular(isMe ? 4 : 20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isMe ? const Color(0xFFFF3838) : Colors.black)
                              .withValues(alpha: isMe ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply preview in message
                        if (message.replyTo?.message != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: (isMe
                                      ? Colors.white
                                      : const Color(0xFF666666))
                                  .withValues(alpha: isMe ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isMe
                                        ? Colors.white
                                        : const Color(0xFF666666))
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.replyTo!.userName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.replyTo!.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF666666),
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
                            fontSize: 16,
                            color:
                                isMe ? Colors.white : const Color(0xFF1a1a1a),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Timestamp
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              // 已读/未读状态
              Icon(
                Icons.check_circle,
                size: 16,
                color: const Color(0xFF00D856).withValues(alpha: 0.8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Reply preview bar
  Widget _buildReplyPreview(ChatStateController controller) {
    final replyTo = controller.replyTo!;
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
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
                      '${l10n.reply} ${replyTo.author.userName}',
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
                onPressed: () => controller.clearReplyTo(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Message input
  Widget _buildMessageInput(ChatStateController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 相机按钮
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFFC00), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.black, size: 24),
                    onPressed: () {
                      AppToast.info('拍摄功能即将推出');
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: l10n.typeMessage,
                              hintStyle: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                        // Emoji button
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              color: Color(0xFF999999), size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            AppToast.info('表情功能即将推出');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedBuilder(
                  animation: _messageController,
                  builder: (context, child) {
                    final hasText = _messageController.text.trim().isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        gradient: hasText
                            ? const LinearGradient(
                                colors: [Color(0xFFFF5E62), Color(0xFFFF3838)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: hasText ? null : const Color(0xFFE5E5E5),
                        shape: BoxShape.circle,
                        boxShadow: hasText
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF3838)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          hasText ? Icons.send_rounded : Icons.mic,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: hasText
                            ? () {
                                final text = _messageController.text;
                                if (text.trim().isNotEmpty) {
                                  controller.sendMessage(text);
                                  _messageController.clear();
                                }
                              }
                            : () {
                                AppToast.info('语音功能即将推出');
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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

  void _showBlockDialog(String userName, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Get.dialog(
      AlertDialog(
        title: Text(l10n.blockUser),
        content: Text(l10n.blockWarning),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous page
              AppToast.success(
                l10n.userBlocked,
                title: l10n.blockConfirm,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
  }
}
