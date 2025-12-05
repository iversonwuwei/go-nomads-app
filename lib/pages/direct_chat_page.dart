import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as models;
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
  late final ChatStateController _chatController;
  bool _isConnecting = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatStateController>();
    _initDirectChat();
  }

  /// 初始化私聊房间
  Future<void> _initDirectChat() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _chatController.joinDirectChat(
      targetUserId: widget.user.id,
      targetUserName: widget.user.name,
      targetUserAvatar: widget.user.avatarUrl,
    );

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    // 离开聊天室
    _chatController.leaveRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 显示连接动画
    if (_isConnecting) {
      return _DirectChatLoadingView(
        userName: widget.user.name,
        userAvatar: widget.user.avatarUrl,
        onBack: () => Get.back(),
      );
    }

    // 显示聊天视图
    return _DirectChatView(
      user: widget.user,
      controller: _chatController,
    );
  }
}

// ==================== 加载动画视图 ====================

/// 私聊加载动画视图
class _DirectChatLoadingView extends StatefulWidget {
  final String userName;
  final String? userAvatar;
  final VoidCallback onBack;

  const _DirectChatLoadingView({
    required this.userName,
    this.userAvatar,
    required this.onBack,
  });

  @override
  State<_DirectChatLoadingView> createState() => _DirectChatLoadingViewState();
}

class _DirectChatLoadingViewState extends State<_DirectChatLoadingView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bubbleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  // 漂浮气泡数据
  final List<_FloatingBubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateBubbles();
  }

  void _initAnimations() {
    // 脉冲动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 气泡漂浮动画
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );
  }

  void _generateBubbles() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 8; i++) {
      _bubbles.add(_FloatingBubble(
        x: ((random + i * 137) % 100) / 100,
        y: ((random + i * 251) % 100) / 100,
        size: 20 + ((random + i * 73) % 30).toDouble(),
        speed: 0.3 + ((random + i * 41) % 50) / 100,
        icon: _chatIcons[i % _chatIcons.length],
      ));
    }
  }

  static const List<IconData> _chatIcons = [
    FontAwesomeIcons.heart,
    FontAwesomeIcons.message,
    FontAwesomeIcons.faceSmile,
    FontAwesomeIcons.star,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.fire,
    FontAwesomeIcons.handPeace,
    FontAwesomeIcons.paperPlane,
  ];

  @override
  void dispose() {
    _pulseController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFC00), // 黄色主题（Snapchat 风格）
              Color(0xFFFFE600),
              Color(0xFFFFD700),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 漂浮气泡背景
              ..._buildFloatingBubbles(),

              // 返回按钮
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                  onPressed: widget.onBack,
                ),
              ),

              // 中心加载动画
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 脉冲圆环动画 + 用户头像
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.2),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // 旋转光环
                                      Transform.rotate(
                                        angle: _rotationAnimation.value,
                                        child: Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: SweepGradient(
                                              colors: [
                                                Colors.black.withValues(alpha: 0.3),
                                                Colors.black.withValues(alpha: 0.05),
                                                Colors.black.withValues(alpha: 0.3),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 用户头像
                                      SafeCircleAvatar(
                                        imageUrl: widget.userAvatar,
                                        radius: 45,
                                        backgroundColor: Colors.white,
                                        errorWidget: const Icon(
                                          FontAwesomeIcons.user,
                                          color: Colors.black54,
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 用户名称
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 加载文字动画
                    _buildLoadingText(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingBubbles() {
    return _bubbles.map((bubble) {
      return AnimatedBuilder(
        animation: _bubbleController,
        builder: (context, child) {
          final progress = (_bubbleController.value + bubble.speed) % 1.0;
          final yOffset = progress * 200 - 100;
          final xWave = 20 * (0.5 - (progress - 0.5).abs());

          return Positioned(
            left: bubble.x * MediaQuery.of(context).size.width + xWave,
            top: bubble.y * MediaQuery.of(context).size.height + yOffset,
            child: Opacity(
              opacity: 0.3 + 0.3 * (1 - (progress - 0.5).abs() * 2),
              child: Icon(
                bubble.icon,
                color: Colors.black54,
                size: bubble.size,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final dotCount = (_pulseController.value * 3).floor() + 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '正在连接',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '.' * dotCount,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 漂浮气泡数据类
class _FloatingBubble {
  final double x;
  final double y;
  final double size;
  final double speed;
  final IconData icon;

  _FloatingBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.icon,
  });
}

// ==================== 聊天视图 ====================

/// 私聊视图
class _DirectChatView extends StatefulWidget {
  final models.User user;
  final ChatStateController controller;

  const _DirectChatView({
    required this.user,
    required this.controller,
  });

  @override
  State<_DirectChatView> createState() => _DirectChatViewState();
}

class _DirectChatViewState extends State<_DirectChatView> {
  final _messageController = TextEditingController();

  /// 获取当前用户 ID
  String? get _currentUserId {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.currentUser.value?.id;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFC00),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const AppBackButton(color: Colors.black),
        title: GestureDetector(
          onTap: () {
            Get.to(() => MemberDetailPage(user: widget.user));
          },
          child: Row(
            children: [
              Stack(
                children: [
                  SafeCircleAvatar(
                    imageUrl: widget.user.avatarUrl,
                    radius: 20,
                    backgroundColor: Colors.grey[200],
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
                        border: Border.all(color: const Color(0xFFFFFC00), width: 2),
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
            icon: const Icon(FontAwesomeIcons.video, color: Colors.black, size: 28),
            onPressed: () => AppToast.info('视频通话功能即将推出'),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.phone, color: Colors.black, size: 24),
            onPressed: () => AppToast.info('语音通话功能即将推出'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Colors.black),
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
                      const Icon(FontAwesomeIcons.user, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.viewProfile),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.bellSlash, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.muteNotifications),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.ban, size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(l10n.blockUser, style: const TextStyle(color: Colors.red)),
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

        final currentUserId = _currentUserId;

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
                        final isMe = currentUserId != null && message.author.userId == currentUserId;
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
                FontAwesomeIcons.message,
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
  Widget _buildMessageBubble(ChatMessage message, bool isMe, ChatStateController controller) {
    return GestureDetector(
      onLongPress: () {
        if (!isMe) {
          controller.setReplyTo(message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              GestureDetector(
                onTap: () {
                  Get.to(() => MemberDetailPage(user: widget.user));
                },
                child: SafeCircleAvatar(
                  imageUrl: widget.user.avatarUrl,
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: (isMe ? const Color(0xFFFF3838) : Colors.black).withValues(alpha: isMe ? 0.2 : 0.05),
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
                              color:
                                  (isMe ? Colors.white : const Color(0xFF666666)).withValues(alpha: isMe ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isMe ? Colors.white : const Color(0xFF666666)).withValues(alpha: 0.3),
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
                                    color: isMe ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.replyTo!.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF666666),
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
                            color: isMe ? Colors.white : const Color(0xFF1a1a1a),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Timestamp
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF999999),
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
                FontAwesomeIcons.circleCheck,
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
                icon: const Icon(FontAwesomeIcons.xmark, size: 20),
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
                    icon: const Icon(FontAwesomeIcons.camera, color: Colors.black, size: 24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          icon: const Icon(FontAwesomeIcons.faceSmile, color: Color(0xFF999999), size: 24),
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
                                  color: const Color(0xFFFF3838).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          hasText ? FontAwesomeIcons.paperPlane : FontAwesomeIcons.microphone,
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
