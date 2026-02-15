// ignore_for_file: unused_element_parameter
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/chat/domain/entities/chat.dart';
import 'package:go_nomads_app/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/flutter_map_picker_page.dart';
import 'package:go_nomads_app/services/image_upload_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/chat_more_options_sheet.dart';
import 'package:go_nomads_app/widgets/chat_voice.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// 上传中的图片信息
class _UploadingImage {
  final String id;
  final String localPath;
  double progress;
  String? errorMessage;

  _UploadingImage({
    required this.id,
    required this.localPath,
    this.progress = 0,
    this.errorMessage,
  });
}

class _DirectChatViewState extends State<_DirectChatView> {
  final _messageController = TextEditingController();
  final _inputFocusNode = FocusNode();
  bool _showEmojiPanel = false;

  // 语音输入模式状态
  bool _isVoiceMode = false;

  /// 正在上传的图片列表
  final List<_UploadingImage> _uploadingImages = [];

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
    _inputFocusNode.dispose();
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
          // TODO: 暂时隐藏视频通话按钮，功能待完善后启用
          // IconButton(
          //   icon: const Icon(FontAwesomeIcons.video, color: Colors.black, size: 28),
          //   onPressed: () => AppToast.info('视频通话功能即将推出'),
          // ),
          // TODO: 暂时隐藏语音通话按钮，功能待完善后启用
          // IconButton(
          //   icon: const Icon(FontAwesomeIcons.phone, color: Colors.black, size: 24),
          //   onPressed: () => AppToast.info('语音通话功能即将推出'),
          // ),
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
                case 'report':
                  ReportDialog.show(
                    context: context,
                    contentType: ReportContentType.user,
                    targetId: widget.user.id,
                    targetName: widget.user.name,
                  );
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
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.circleExclamation, size: 20, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(l10n.reportUser, style: const TextStyle(color: Colors.orange)),
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
              child: controller.messages.isEmpty && _uploadingImages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length + _uploadingImages.length,
                      itemBuilder: (context, index) {
                        // 先显示上传中的图片（在最底部/最新位置）
                        if (index < _uploadingImages.length) {
                          final uploadingImage = _uploadingImages[_uploadingImages.length - 1 - index];
                          return _buildUploadingImageBubble(uploadingImage);
                        }
                        // 然后显示已发送的消息
                        final messageIndex = index - _uploadingImages.length;
                        final message = controller.messages[messageIndex];
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

            // Emoji Panel
            if (_showEmojiPanel) _buildEmojiPanel(),
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
                        _buildMessageContent(message, isMe),

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

  /// 构建上传中图片的气泡
  Widget _buildUploadingImageBubble(_UploadingImage uploadingImage) {
    final hasError = uploadingImage.errorMessage != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3838).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // 本地图片预览
                        Image.file(
                          File(uploadingImage.localPath),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),

                        // 上传进度遮罩
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: hasError ? 0.6 : 0.4),
                            child: Center(
                              child: hasError
                                  ? _buildUploadErrorOverlay(uploadingImage)
                                  : _buildUploadProgressOverlay(uploadingImage),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // 状态文字
                Text(
                  hasError ? uploadingImage.errorMessage! : '上传中...',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasError ? const Color(0xFFFF3838) : const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 上传状态图标
          Icon(
            hasError ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.cloudArrowUp,
            size: 16,
            color: hasError
                ? const Color(0xFFFF3838).withValues(alpha: 0.8)
                : const Color(0xFFFF3838).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// 构建上传进度遮罩
  Widget _buildUploadProgressOverlay(_UploadingImage uploadingImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: uploadingImage.progress,
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              Text(
                '${(uploadingImage.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建上传错误遮罩
  Widget _buildUploadErrorOverlay(_UploadingImage uploadingImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          FontAwesomeIcons.circleExclamation,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 重试按钮
            GestureDetector(
              onTap: () => _retryUpload(uploadingImage),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.arrowRotateRight, size: 12, color: Color(0xFFFF3838)),
                    SizedBox(width: 4),
                    Text('重试', style: TextStyle(fontSize: 12, color: Color(0xFFFF3838))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 取消按钮
            GestureDetector(
              onTap: () => _removeUploadingImage(uploadingImage.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.xmark, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('取消', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F7),
            border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 语音/键盘切换按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVoiceMode = !_isVoiceMode;
                      if (_isVoiceMode) {
                        _inputFocusNode.unfocus();
                        _showEmojiPanel = false;
                      }
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _isVoiceMode ? const Color(0xFFFF3838) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _isVoiceMode ? FontAwesomeIcons.keyboard : FontAwesomeIcons.microphone,
                      color: _isVoiceMode ? Colors.white : const Color(0xFF666666),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 输入框或录音按钮
                Expanded(
                  child: _isVoiceMode
                      ? ChatVoiceRecorderButton(
                          onSendVoice: (path, duration) => _sendVoiceMessage(path, duration),
                          config: VoiceRecorderConfig.snapchat,
                        )
                      : _buildTextInputField(l10n, controller),
                ),
                const SizedBox(width: 8),
                // 表情按钮（非语音模式且无文字时显示）
                if (!_isVoiceMode && _messageController.text.trim().isEmpty) ...[
                  GestureDetector(
                    onTap: _toggleEmojiPanel,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _showEmojiPanel ? FontAwesomeIcons.keyboard : FontAwesomeIcons.faceSmile,
                        color: const Color(0xFF666666),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // 发送按钮或更多按钮
                if (!_isVoiceMode && _messageController.text.trim().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final text = _messageController.text;
                      if (text.trim().isNotEmpty) {
                        controller.sendMessage(text);
                        _messageController.clear();
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3838),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.paperPlane,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => ChatMoreOptionsSheet.show(
                      config: ChatMoreOptionsConfig(
                        onImagePicked: _sendImage,
                        onLocationPicked: _pickLocation,
                        onFilePicked: _sendFile,
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.plus,
                        color: Color(0xFF666666),
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建文字输入框
  Widget _buildTextInputField(AppLocalizations l10n, ChatStateController controller) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: _messageController,
        focusNode: _inputFocusNode,
        onTap: () {
          if (_showEmojiPanel) {
            setState(() => _showEmojiPanel = false);
          }
        },
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: l10n.typeMessage,
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 15,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        maxLines: 1,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 15),
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

  /// 选择位置
  Future<void> _pickLocation() async {
    try {
      final result = await Get.to<Map<String, dynamic>>(
        () => const FlutterMapPickerPage(),
      );
      if (result != null) {
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        final address = result['address'] as String?;
        if (lat != null && lng != null) {
          widget.controller.sendMessage(
            address ?? '位置',
            messageType: 'location',
            attachment: {
              'latitude': lat,
              'longitude': lng,
              'locationName': address ?? '位置',
            },
          );
        }
      }
    } catch (e) {
      AppToast.error('选择位置失败: $e');
    }
  }

  /// 发送文件消息
  Future<void> _sendFile(PlatformFile platformFile) async {
    try {
      final file = File(platformFile.path!);
      final imageUploadService = ImageUploadService();

      final fileUrl = await imageUploadService.uploadFile(
        file: file,
        bucket: 'user-uploads',
        folder: 'chat-files/direct-chat',
        fileName: platformFile.name,
      );

      widget.controller.sendMessage(
        platformFile.name,
        messageType: 'file',
        attachment: {
          'url': fileUrl,
          'fileName': platformFile.name,
          'fileSize': platformFile.size,
          'mimeType': _getMimeType(platformFile.extension),
        },
      );
    } catch (e) {
      AppToast.error('发送文件失败: $e');
    }
  }

  String _getMimeType(String? extension) {
    if (extension == null) return 'application/octet-stream';
    final ext = extension.toLowerCase();
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'zip': 'application/zip',
      'mp3': 'audio/mpeg',
      'mp4': 'video/mp4',
    };
    return mimeTypes[ext] ?? 'application/octet-stream';
  }

  /// 发送语音消息
  Future<void> _sendVoiceMessage(String localPath, int duration) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) {
        AppToast.error('语音文件不存在');
        return;
      }

      final imageUploadService = ImageUploadService();
      final voiceUrl = await imageUploadService.uploadFile(
        file: file,
        bucket: 'user-uploads',
        folder: 'chat-voice/direct-chat',
      );

      widget.controller.sendMessage(
        '语音消息',
        messageType: 'voice',
        attachment: {
          'url': voiceUrl,
          'duration': duration,
          'mimeType': 'audio/m4a',
        },
      );

      try {
        await file.delete();
      } catch (e) {
        debugPrint('⚠️ 删除临时语音文件失败: $e');
      }
    } catch (e) {
      AppToast.error('发送语音失败: $e');
    }
  }

  /// 发送图片消息
  Future<void> _sendImage(XFile image) async {
    // 创建上传中图片的唯一 ID
    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadingImage = _UploadingImage(
      id: uploadId,
      localPath: image.path,
      progress: 0,
    );

    // 添加到上传列表，显示在聊天中
    setState(() {
      _uploadingImages.add(uploadingImage);
    });

    try {
      // 1. 上传图片到 Supabase Storage
      final imageFile = File(image.path);
      final imageUploadService = ImageUploadService();

      // 模拟进度更新（Supabase SDK 暂不支持进度回调，使用模拟进度）
      _simulateUploadProgress(uploadId);

      // 使用 user-uploads bucket，文件夹为 chat-images/direct-chat
      final imageUrl = await imageUploadService.uploadImage(
        imageFile: imageFile,
        bucket: 'user-uploads',
        folder: 'chat-images/direct-chat',
        compress: true,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      debugPrint('✅ 图片上传成功: $imageUrl');

      // 2. 先发送图片消息
      widget.controller.sendMessage(
        imageUrl,
        messageType: 'image',
        attachment: {
          'url': imageUrl,
          'name': image.name,
          'type': 'image',
          'mimeType': 'image/jpeg',
        },
      );

      // 3. 预加载网络图片，加载完成后再移除上传中的预览
      _preloadAndRemoveUploadingImage(imageUrl, uploadId);
    } catch (e) {
      debugPrint('❌ 图片上传失败: $e');
      // 标记上传失败
      String errorMsg = '上传失败';
      if (e.toString().contains('Bucket not found')) {
        errorMsg = '存储服务错误';
      } else if (e.toString().contains('not authenticated')) {
        errorMsg = '请重新登录';
      } else if (e.toString().contains('未初始化')) {
        errorMsg = '请重启应用';
      } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
        errorMsg = '网络错误';
      }

      setState(() {
        final index = _uploadingImages.indexWhere((img) => img.id == uploadId);
        if (index != -1) {
          _uploadingImages[index].errorMessage = errorMsg;
          _uploadingImages[index].progress = 0;
        }
      });
    }
  }

  /// 模拟上传进度（因为 Supabase 不支持进度回调）
  void _simulateUploadProgress(String uploadId) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));

      final index = _uploadingImages.indexWhere((img) => img.id == uploadId);
      if (index == -1) return false; // 已完成或已移除

      if (_uploadingImages[index].progress < 0.9) {
        setState(() {
          _uploadingImages[index].progress += 0.1;
        });
        return true;
      }
      return false;
    });
  }

  /// 预加载网络图片，加载完成后移除上传中的预览
  void _preloadAndRemoveUploadingImage(String imageUrl, String uploadId) {
    // 使用 precacheImage 预加载图片
    final imageProvider = NetworkImage(imageUrl);
    precacheImage(imageProvider, context).then((_) {
      // 图片预加载完成，移除上传中的预览
      if (mounted) {
        setState(() {
          _uploadingImages.removeWhere((img) => img.id == uploadId);
        });
      }
    }).catchError((_) {
      // 预加载失败，仍然移除上传中的预览（网络图片会显示加载状态）
      if (mounted) {
        setState(() {
          _uploadingImages.removeWhere((img) => img.id == uploadId);
        });
      }
    });
  }

  /// 重试上传失败的图片
  void _retryUpload(_UploadingImage uploadingImage) {
    // 移除失败的记录
    setState(() {
      _uploadingImages.removeWhere((img) => img.id == uploadingImage.id);
    });
    // 重新上传
    _sendImage(XFile(uploadingImage.localPath));
  }

  /// 取消/移除上传失败的图片
  void _removeUploadingImage(String uploadId) {
    setState(() {
      _uploadingImages.removeWhere((img) => img.id == uploadId);
    });
  }

  /// 构建消息内容（支持文本和图片）
  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    // 检查是否是位置消息
    if (message.attachment?.isLocation == true) {
      return _buildLocationMessage(message, isMe);
    }

    // 检查是否是语音消息
    if (message.type == MessageType.voice) {
      return _buildVoiceMessageContent(message, isMe);
    }

    // 检查是否是文件消息
    if (message.type == MessageType.file) {
      return _buildFileMessageContent(message, isMe);
    }

    // 检查是否是图片消息
    final isImageMessage = message.type == MessageType.image ||
        (message.attachment?.url.isNotEmpty == true &&
            (message.attachment!.isImage ||
                message.attachment!.url.endsWith('.jpg') ||
                message.attachment!.url.endsWith('.png') ||
                message.attachment!.url.endsWith('.jpeg'))) ||
        _isImageUrl(message.message);

    if (isImageMessage) {
      return _buildImageMessage(message, isMe);
    }

    // 普通文本消息
    return Text(
      message.message,
      style: TextStyle(
        fontSize: 16,
        color: isMe ? Colors.white : const Color(0xFF1a1a1a),
        height: 1.4,
      ),
    );
  }

  /// 构建位置消息
  Widget _buildLocationMessage(ChatMessage message, bool isMe) {
    final attachment = message.attachment!;
    return GestureDetector(
      onTap: () => _showMapPicker(
        attachment.latitude!,
        attachment.longitude!,
        attachment.locationName ?? '位置',
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 地图预览
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: 200,
                height: 100,
                color: const Color(0xFFE8F5E9),
                child: Stack(
                  children: [
                    Image.network(
                      'https://staticmap.openstreetmap.de/staticmap.php?center=${attachment.latitude},${attachment.longitude}&zoom=15&size=200x100&markers=${attachment.latitude},${attachment.longitude},red-pushpin',
                      fit: BoxFit.cover,
                      width: 200,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              FontAwesomeIcons.mapLocationDot,
                              color: Color(0xFF4CAF50),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    const Center(
                      child: Icon(
                        FontAwesomeIcons.locationDot,
                        color: Color(0xFFE53935),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 位置名称
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.locationDot,
                    color: isMe ? Colors.white70 : const Color(0xFF666666),
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      attachment.locationName ?? '位置',
                      style: TextStyle(
                        fontSize: 13,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  /// 构建语音消息内容
  Widget _buildVoiceMessageContent(ChatMessage message, bool isMe) {
    final attachment = message.attachment;
    final duration = attachment?.duration ?? 0;
    final voiceUrl = attachment?.url ?? '';

    if (voiceUrl.isEmpty) {
      return const Text('语音消息不可用');
    }

    return ChatVoiceMessageSimple(
      voiceUrl: voiceUrl,
      duration: duration,
      isMe: isMe,
      textColor: isMe ? Colors.white : Colors.black87,
      iconColor: isMe ? Colors.white70 : const Color(0xFFFF3838),
    );
  }

  /// 构建文件消息内容
  Widget _buildFileMessageContent(ChatMessage message, bool isMe) {
    final attachment = message.attachment;
    final fileName = attachment?.fileName ?? '文件';
    final fileSize = attachment?.fileSize ?? 0;

    return GestureDetector(
      onTap: () {
        if (attachment?.url.isNotEmpty == true) {
          launchUrl(Uri.parse(attachment!.url), mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.file,
            color: isMe ? Colors.white70 : const Color(0xFF666666),
            size: 28,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatFileSize(fileSize),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white60 : const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 显示地图APP选择器
  void _showMapPicker(double latitude, double longitude, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择地图导航',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1),
            _DirectMapAppOption(
              icon: FontAwesomeIcons.apple,
              title: 'Apple 地图',
              iconColor: Colors.black87,
              onTap: () => _openAppleMaps(latitude, longitude, name),
            ),
            _DirectMapAppOption(
              icon: FontAwesomeIcons.google,
              title: 'Google 地图',
              iconColor: const Color(0xFF4285F4),
              onTap: () => _openGoogleMaps(latitude, longitude, name),
            ),
            _DirectMapAppOption(
              icon: FontAwesomeIcons.locationArrow,
              title: '高德地图',
              iconColor: const Color(0xFF0091FF),
              onTap: () => _openAmap(latitude, longitude, name),
            ),
            _DirectMapAppOption(
              icon: FontAwesomeIcons.mapPin,
              title: '百度地图',
              iconColor: const Color(0xFF3385FF),
              onTap: () => _openBaiduMap(latitude, longitude, name),
            ),
            _DirectMapAppOption(
              icon: FontAwesomeIcons.mapLocation,
              title: '腾讯地图',
              iconColor: const Color(0xFF12B7F5),
              onTap: () => _openTencentMap(latitude, longitude, name),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openAppleMaps(double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse('maps://?q=${Uri.encodeComponent(name)}&ll=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError('Apple 地图');
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse('comgooglemaps://?q=$latitude,$longitude&center=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError('Google 地图');
    }
  }

  Future<void> _openAmap(double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'iosamap://viewMap?sourceApplication=GoNomads&poiname=${Uri.encodeComponent(name)}&lat=$latitude&lon=$longitude&dev=0');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError('高德地图');
    }
  }

  Future<void> _openBaiduMap(double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'baidumap://map/marker?location=$latitude,$longitude&title=${Uri.encodeComponent(name)}&coord_type=gcj02&src=GoNomads');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError('百度地图');
    }
  }

  Future<void> _openTencentMap(double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse('qqmap://map/marker?marker=coord:$latitude,$longitude;title:${Uri.encodeComponent(name)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError('腾讯地图');
    }
  }

  void _showMapError(String mapName) {
    AppToast.warning('未安装$mapName');
  }

  /// 检查是否是图片 URL
  bool _isImageUrl(String text) {
    // 检查是否是网络图片 URL
    if (text.startsWith('http://') || text.startsWith('https://')) {
      final lowerText = text.toLowerCase();
      return lowerText.endsWith('.jpg') ||
          lowerText.endsWith('.jpeg') ||
          lowerText.endsWith('.png') ||
          lowerText.endsWith('.gif') ||
          lowerText.endsWith('.webp') ||
          lowerText.contains('supabase') && lowerText.contains('storage'); // Supabase 存储 URL
    }
    return false;
  }

  /// 构建图片消息
  Widget _buildImageMessage(ChatMessage message, bool isMe) {
    // 获取图片URL
    String? imageUrl = message.attachment?.url;
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = message.message;
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl!),
      child: Hero(
        tag: 'image_$imageUrl',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: _buildNetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }

  /// 构建网络图片（加载时显示灰色占位框）（加载时显示灰色占位框）
  Widget _buildNetworkImage(String imageUrl) {
    // 网络图片
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // 显示灰色占位框，带图片图标
          return Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                FontAwesomeIcons.image,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  /// 构建图片占位符
  Widget _buildImagePlaceholder() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  /// 显示全屏图片
  void _showFullScreenImage(String imagePath) {
    Get.to(
      () => _FullScreenImageViewer(imagePath: imagePath),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// 切换表情面板显示
  void _toggleEmojiPanel() {
    setState(() {
      _showEmojiPanel = !_showEmojiPanel;
      if (_showEmojiPanel) {
        // 显示表情面板时收起键盘
        _inputFocusNode.unfocus();
      } else {
        // 收起表情面板时显示键盘
        _inputFocusNode.requestFocus();
      }
    });
  }

  /// 插入表情到输入框
  void _insertEmoji(String emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
    setState(() {});
  }

  /// 构建表情面板
  Widget _buildEmojiPanel() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5E5)),
        ),
      ),
      child: Column(
        children: [
          // 表情分类标签
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                _buildEmojiCategoryTab('😀', true),
                _buildEmojiCategoryTab('❤️', false),
                _buildEmojiCategoryTab('👋', false),
                _buildEmojiCategoryTab('🎉', false),
                _buildEmojiCategoryTab('🍔', false),
                _buildEmojiCategoryTab('⚽', false),
                _buildEmojiCategoryTab('🚗', false),
                const Spacer(),
                // 删除按钮
                IconButton(
                  icon: const Icon(FontAwesomeIcons.deleteLeft, size: 20, color: Color(0xFF666666)),
                  onPressed: () {
                    final text = _messageController.text;
                    if (text.isNotEmpty) {
                      // 删除最后一个字符（考虑 emoji 可能是多个字符）
                      final characters = text.characters.toList();
                      characters.removeLast();
                      _messageController.text = characters.join();
                      _messageController.selection = TextSelection.collapsed(
                        offset: _messageController.text.length,
                      );
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          // 表情网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _insertEmoji(_emojis[index]),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _emojis[index],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              },
            ),
          ),
          // 发送按钮区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _messageController.text.trim().isEmpty
                      ? null
                      : () {
                          final text = _messageController.text;
                          if (text.trim().isNotEmpty) {
                            widget.controller.sendMessage(text);
                            _messageController.clear();
                            setState(() {});
                          }
                        },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _messageController.text.trim().isEmpty ? const Color(0xFFE5E5E5) : const Color(0xFFFF3838),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建表情分类标签
  Widget _buildEmojiCategoryTab(String emoji, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // TODO: 切换表情分类
      },
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFF3838) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  /// 常用表情列表
  static const List<String> _emojis = [
    // 笑脸与情绪
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
    '🙂', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗',
    '😚', '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗',
    '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶',
    '😏', '😒', '🙄', '😬', '🤥', '😌', '😔', '😪',
    '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧',
    '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '🥸',
    '😎', '🤓', '🧐', '😕', '😟', '🙁', '☹️', '😮',
    '😯', '😲', '😳', '🥺', '😦', '😧', '😨', '😰',
    '😥', '😢', '😭', '😱', '😖', '😣', '😞', '😓',
    '😩', '😫', '🥱', '😤', '😡', '😠', '🤬', '😈',
    '👿', '💀', '☠️', '💩', '🤡', '👹', '👺', '👻',
    // 手势
    '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏',
    '✌️', '🤞', '🤟', '🤘', '🤙', '👈', '👉', '👆',
    '🖕', '👇', '☝️', '👍', '👎', '✊', '👊', '🤛',
    '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏', '✍️',
    // 爱心
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
    '💘', '💝', '💟', '♥️', '😻', '💑', '💏', '👩‍❤️‍👨',
    // 庆祝
    '🎉', '🎊', '🎈', '🎁', '🎀', '🏆', '🥇', '🥈',
    '🥉', '🏅', '🎖️', '🎗️', '🎄', '🎃', '🎂', '🍰',
    // 食物
    '🍔', '🍟', '🍕', '🌭', '🥪', '🌮', '🌯', '🥙',
    '🧆', '🥚', '🍳', '🥘', '🍲', '🥣', '🥗', '🍿',
    '🧈', '🧂', '🥫', '🍱', '🍘', '🍙', '🍚', '🍛',
    '🍜', '🍝', '🍠', '🍢', '🍣', '🍤', '🍥', '🥮',
    // 运动
    '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
    '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', '🏑', '🥍',
    '🏏', '🪃', '🥅', '⛳', '🪁', '🏹', '🎣', '🤿',
    // 交通
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑',
    '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🛵', '🏍️',
    '🛺', '🚲', '🛴', '✈️', '🚀', '🛸', '🚁', '🛶',
  ];
}

/// 全屏图片查看器
class _FullScreenImageViewer extends StatefulWidget {
  final String imagePath;

  const _FullScreenImageViewer({required this.imagePath});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  double _currentScale = 1.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController.addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  /// 双击缩放
  void _handleDoubleTap(TapDownDetails details) {
    final position = details.localPosition;
    final endScale = _currentScale > 1.0 ? 1.0 : 2.5;

    final Matrix4 endMatrix;
    if (endScale == 1.0) {
      endMatrix = Matrix4.identity();
    } else {
      final tx = -position.dx * (endScale - 1);
      final ty = -position.dy * (endScale - 1);
      endMatrix = Matrix4.identity()
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty)
        ..setEntry(0, 0, endScale)
        ..setEntry(1, 1, endScale);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0);
    setState(() => _currentScale = endScale);
  }

  /// 切换控制栏显示
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.download, color: Colors.white, size: 20),
                  onPressed: () {
                    AppToast.info('保存功能即将推出');
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.share, color: Colors.white, size: 20),
                  onPressed: () {
                    AppToast.info('分享功能即将推出');
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: _handleDoubleTap,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: 'image_${widget.imagePath}',
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                onInteractionEnd: (details) {
                  setState(() {
                    _currentScale = _transformationController.value.getMaxScaleOnAxis();
                  });
                },
                child: _buildFullScreenImage(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _showControls
          ? Container(
              color: Colors.black.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.magnifyingGlassMinus, color: Colors.white54, size: 20),
                      onPressed: () {
                        _transformationController.value = Matrix4.identity();
                        setState(() => _currentScale = 1.0);
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(_currentScale * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.magnifyingGlassPlus, color: Colors.white54, size: 20),
                      onPressed: () {
                        final currentScale = _transformationController.value.getMaxScaleOnAxis();
                        if (currentScale < 4.0) {
                          final newScale = currentScale + 0.5;
                          _transformationController.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
                          setState(() => _currentScale = newScale);
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFullScreenImage() {
    final imageUrl = widget.imagePath;

    // 网络图片
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.white54),
        SizedBox(height: 16),
        Text(
          '无法加载图片',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ],
    );
  }
}

/// 地图APP选项组件（直接聊天）
class _DirectMapAppOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _DirectMapAppOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
