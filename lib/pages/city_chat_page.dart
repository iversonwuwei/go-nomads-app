// ignore_for_file: unused_element_parameter
import 'dart:async';
import 'dart:io';

import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/flutter_map_picker_page.dart';
import 'package:df_admin_mobile/pages/member_detail_page.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

/// 城市聊天室页面 - WeChat 风格设计
///
/// 设计理念:
/// - 简洁的列表界面,清晰的层级结构
/// - 绿色作为主题色(WeChat 风格)
/// - 流畅的动画和过渡效果
/// - 支持长按回复、滑动删除等交互
class CityChatPage extends StatefulWidget {
  const CityChatPage({super.key});

  @override
  State<CityChatPage> createState() => _CityChatPageState();
}

class _CityChatPageState extends State<CityChatPage> {
  late ChatStateController controller;
  bool _initialized = false;
  bool _isMeetupChat = false;
  String? _meetupTitle;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatStateController>();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final args = Get.arguments;
    Map<String, dynamic>? argsMap;

    // 安全地获取参数
    if (args is Map<String, dynamic>) {
      argsMap = args;
    }

    if (argsMap != null && argsMap['isMeetupChat'] == true) {
      // 从 Meetup 进入的聊天
      _isMeetupChat = true;
      final meetupId = argsMap['meetupId'] as String?;
      final meetupTitle = argsMap['city'] as String? ?? 'Meetup Chat';
      final meetupType = argsMap['country'] as String?;
      _meetupTitle = meetupTitle;

      if (meetupId != null) {
        await controller.joinMeetupRoom(
          meetupId: meetupId,
          meetupTitle: meetupTitle,
          meetupType: meetupType,
        );
      }
    }

    // 检查 widget 是否仍然挂载在树中
    if (!mounted) return;

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 如果是 Meetup 聊天，显示加载状态或聊天室
    if (_isMeetupChat) {
      return Obx(() {
        // 先访问可观察变量，确保 Obx 正常工作
        final room = controller.currentRoom;
        // ignore: unused_local_variable
        final isLoading = controller.isLoading;

        // 显示加载状态
        if (!_initialized || room == null) {
          return _ChatLoadingView(
            roomName: _meetupTitle ?? '聊天室',
            onBack: () async {
              await controller.leaveRoom();
              Get.back();
            },
          );
        }

        // 显示聊天视图
        return _ChatRoomView(
          controller: controller,
          isMeetupChat: true,
          meetupTitle: _meetupTitle,
        );
      });
    }

    // 非 Meetup 聊天的原有逻辑
    return Obx(() {
      if (controller.currentRoom == null) {
        return _ChatRoomsListView(controller: controller);
      }

      return _ChatRoomView(
        controller: controller,
        isMeetupChat: false,
      );
    });
  }
}

/// 聊天室加载动画视图
class _ChatLoadingView extends StatefulWidget {
  final String roomName;
  final Future<void> Function() onBack;

  const _ChatLoadingView({
    required this.roomName,
    required this.onBack,
  });

  @override
  State<_ChatLoadingView> createState() => _ChatLoadingViewState();
}

class _ChatLoadingViewState extends State<_ChatLoadingView> with TickerProviderStateMixin {
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
    FontAwesomeIcons.message,
    FontAwesomeIcons.comments,
    FontAwesomeIcons.faceSmile,
    FontAwesomeIcons.heart,
    FontAwesomeIcons.star,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.fire,
    FontAwesomeIcons.handPeace,
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
              Color(0xFF07C160),
              Color(0xFF059C4C),
              Color(0xFF048A42),
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: widget.onBack,
                ),
              ),

              // 中心加载动画
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 脉冲圆环动画
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.8),
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.white.withValues(alpha: 0.8),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          FontAwesomeIcons.comments,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 聊天室名称
                    Text(
                      widget.roomName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
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
                color: Colors.white,
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
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '.' * dotCount,
                style: const TextStyle(
                  color: Colors.white70,
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

/// 聊天室列表视图
class _ChatRoomsListView extends StatelessWidget {
  final ChatStateController controller;

  const _ChatRoomsListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const AppBackButton(color: Colors.black),
        title: Text(
          l10n.cityChats,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.black),
            onPressed: () => AppToast.info('创建聊天室功能即将推出'),
          ),
        ],
      ),
      body: controller.chatRooms.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              itemCount: controller.chatRooms.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                color: Color(0xFFE5E5E5),
              ),
              itemBuilder: (context, index) {
                final room = controller.chatRooms[index];
                return _ChatRoomItem(room: room, controller: controller);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.message,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无聊天室',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 聊天室列表项
class _ChatRoomItem extends StatelessWidget {
  final ChatRoom room;
  final ChatStateController controller;

  const _ChatRoomItem({required this.room, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => controller.joinRoom(room),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF07C160), Color(0xFF059C4C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(FontAwesomeIcons.users, color: Colors.white, size: 28),
        ),
        if (room.stats.onlineUsers > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                room.stats.onlineUsers > 99 ? '99+' : '${room.stats.onlineUsers}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                room.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(room.lastMessage?.timestamp ?? DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          room.lastMessage?.message ?? '${room.stats.onlineUsers} 人在线',
          style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}/${time.day}';
  }
}

/// 上传中的图片信息（群聊）
class _UploadingImageGroup {
  final String id;
  final String localPath;
  double progress;
  String? errorMessage;

  _UploadingImageGroup({
    required this.id,
    required this.localPath,
    this.progress = 0,
    this.errorMessage,
  });
}

/// 上传中的文件信息（群聊）
class _UploadingFileGroup {
  final String id;
  final String fileName;
  final int fileSize;
  final String localPath;
  double progress;
  String? errorMessage;

  _UploadingFileGroup({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.localPath,
    this.progress = 0,
    this.errorMessage,
  });

  _UploadingFileGroup copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? localPath,
    double? progress,
    String? errorMessage,
  }) {
    return _UploadingFileGroup(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      localPath: localPath ?? this.localPath,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 聊天室详情视图
class _ChatRoomView extends StatefulWidget {
  final ChatStateController controller;
  final bool isMeetupChat;
  final String? meetupTitle;

  const _ChatRoomView({
    required this.controller,
    this.isMeetupChat = false,
    this.meetupTitle,
  });

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  // 表情面板显示状态
  bool _showEmojiPanel = false;

  /// 正在上传的图片列表
  final List<_UploadingImageGroup> _uploadingImages = [];

  /// 正在上传的文件列表
  final List<_UploadingFileGroup> _uploadingFiles = [];

  // 获取当前用户 ID
  String? get _currentUserId {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.currentUser.value?.id;
    } catch (e) {
      return null;
    }
  }

  // 用户颜色缓存（用于群聊中区分不同用户）
  final Map<String, Color> _userColors = {};

  // 预定义的群聊用户颜色列表
  static const List<Color> _bubbleColors = [
    Color(0xFFE3F2FD), // 浅蓝色
    Color(0xFFFCE4EC), // 浅粉色
    Color(0xFFF3E5F5), // 浅紫色
    Color(0xFFFFF3E0), // 浅橙色
    Color(0xFFE8F5E9), // 浅绿色
    Color(0xFFFFFDE7), // 浅黄色
    Color(0xFFE0F7FA), // 浅青色
    Color(0xFFFBE9E7), // 浅珊瑚色
    Color(0xFFF1F8E9), // 浅草绿
    Color(0xFFEDE7F6), // 浅薰衣草
  ];

  /// 根据用户 ID 获取固定的颜色
  Color _getUserBubbleColor(String userId) {
    if (!_userColors.containsKey(userId)) {
      // 使用 userId 的 hashCode 来保证同一用户始终获得相同颜色
      final colorIndex = userId.hashCode.abs() % _bubbleColors.length;
      _userColors[userId] = _bubbleColors[colorIndex];
    }
    return _userColors[userId]!;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 点击消息区域时，收起键盘和表情面板
                _inputFocusNode.unfocus();
                if (_showEmojiPanel) {
                  setState(() => _showEmojiPanel = false);
                }
              },
              child: Obx(() {
                return widget.controller.messages.isEmpty ? _buildEmptyMessages() : _buildMessagesList();
              }),
            ),
          ),
          Obx(() {
            if (widget.controller.replyTo != null) {
              return _buildReplyBar();
            }
            return const SizedBox.shrink();
          }),
          _buildInputBar(),
          // 表情面板
          if (_showEmojiPanel) _buildEmojiPanel(),
        ],
      ),
    );
  }

  /// 退出聊天室并返回上一页
  Future<void> _leaveAndGoBack() async {
    await widget.controller.leaveRoom();
    // 如果是从 Meetup 进入，直接返回上一页
    if (widget.isMeetupChat) {
      Get.back();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final room = widget.controller.currentRoom;
    // 对于 Meetup 聊天室，优先使用传入的 meetupTitle，确保显示正确的活动名称
    final roomName =
        widget.isMeetupChat && widget.meetupTitle != null ? widget.meetupTitle! : (room?.displayName ?? '聊天室');

    return AppBar(
      backgroundColor: const Color(0xFFEDEDED),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: AppBackButton(
        color: Colors.black,
        onPressed: _leaveAndGoBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roomName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(() {
            final onlineCount =
                widget.controller.onlineCount > 0 ? widget.controller.onlineCount : (room?.stats.onlineUsers ?? 0);
            return Text(
              '$onlineCount人在线',
              style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
            );
          }),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.ellipsis, color: Colors.black),
          onPressed: () => _showRoomMenu(),
        ),
      ],
    );
  }

  Widget _buildEmptyMessages() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.comments, size: 64, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            '开始聊天吧',
            style: TextStyle(color: Color(0xFF999999), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final currentUserId = _currentUserId;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.controller.messages.length + _uploadingImages.length,
      itemBuilder: (context, index) {
        // 先显示上传中的图片（在最底部/最新位置）
        if (index < _uploadingImages.length) {
          final uploadingImage = _uploadingImages[_uploadingImages.length - 1 - index];
          return _buildUploadingImageBubble(uploadingImage);
        }
        // 然后显示已发送的消息
        final messageIndex = index - _uploadingImages.length;
        final message = widget.controller.messages[messageIndex];
        final isMe = currentUserId != null && message.author.userId == currentUserId;
        final bubbleColor = isMe ? null : _getUserBubbleColor(message.author.userId);

        return _MessageBubble(
          message: message,
          isMe: isMe,
          bubbleColor: bubbleColor,
          onLongPress: () {
            if (!isMe) widget.controller.setReplyTo(message);
          },
        );
      },
    );
  }

  Widget _buildReplyBar() {
    final replyTo = widget.controller.replyTo!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF3F4F6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF07C160),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '回复 ${replyTo.author.userName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF07C160),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyTo.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.xmark, size: 20),
            onPressed: () => widget.controller.clearReplyTo(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE5E5E5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 语音按钮
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.microphone, color: Color(0xFF666666), size: 26),
                onPressed: () => _showMoreOptions(),
              ),
            ),
            // 输入框
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _inputFocusNode,
                  decoration: const InputDecoration(
                    hintText: '说点什么...',
                    hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  onChanged: (_) => setState(() {}),
                  onTap: () {
                    // 点击输入框时收起表情面板
                    if (_showEmojiPanel) {
                      setState(() => _showEmojiPanel = false);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 表情/更多按钮
            if (_textController.text.trim().isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showEmojiPanel ? FontAwesomeIcons.keyboard : FontAwesomeIcons.faceSmile,
                        color: const Color(0xFF666666),
                        size: 26,
                      ),
                      onPressed: _toggleEmojiPanel,
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.circlePlus, color: Color(0xFF666666), size: 26),
                      onPressed: () => _showMoreOptions(),
                    ),
                  ],
                ),
              )
            else
              _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final hasText = _textController.text.trim().isNotEmpty;
    return GestureDetector(
      onTap: hasText ? _sendMessage : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasText ? const Color(0xFF07C160) : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 20),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.controller.sendMessage(text);
      _textController.clear();
      // 发送后收起表情面板
      if (_showEmojiPanel) {
        setState(() => _showEmojiPanel = false);
      }
    }
  }

  /// 切换表情面板显示状态
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
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _textController.value = TextEditingValue(
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
                    final text = _textController.text;
                    if (text.isNotEmpty) {
                      // 删除最后一个字符（考虑 emoji 可能是多个字符）
                      final characters = text.characters.toList();
                      characters.removeLast();
                      _textController.text = characters.join();
                      _textController.selection = TextSelection.collapsed(
                        offset: _textController.text.length,
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
                  onPressed: _textController.text.trim().isEmpty ? null : _sendMessage,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _textController.text.trim().isEmpty ? const Color(0xFFE5E5E5) : const Color(0xFF07C160),
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
              color: isSelected ? const Color(0xFF07C160) : Colors.transparent,
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

  void _showRoomMenu() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuOption(
                icon: FontAwesomeIcons.users,
                title: '查看成员',
                onTap: () {
                  Get.back();
                  _showMembersList();
                },
              ),
              _buildMenuOption(
                icon: FontAwesomeIcons.magnifyingGlass,
                title: '搜索聊天记录',
                onTap: () {
                  Get.back();
                  _showSearchDialog();
                },
              ),
              _buildMenuOption(
                icon: FontAwesomeIcons.bellSlash,
                title: '消息免打扰',
                onTap: () {
                  Get.back();
                  AppToast.success('已开启消息免打扰');
                },
              ),
              _buildMenuOption(
                icon: FontAwesomeIcons.volumeXmark,
                title: '静音',
                onTap: () {
                  Get.back();
                  AppToast.success('已静音');
                },
              ),
              const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
              _buildMenuOption(
                icon: FontAwesomeIcons.rightFromBracket,
                title: '退出聊天室',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Get.back(); // 关闭底部菜单
                  _leaveAndGoBack();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF333333), size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: titleColor ?? const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示成员列表弹窗
  void _showMembersList() async {
    final room = widget.controller.currentRoom;
    if (room == null) return;

    // 保存屏幕高度（在 await 之前获取）
    final screenHeight = MediaQuery.of(context).size.height;

    // 加载成员列表
    await widget.controller.loadRoomMembers(room.id);

    // 检查 widget 是否还挂载
    if (!mounted) return;

    // 获取成员列表并排序（创建者置顶）
    final members = widget.controller.roomMembers;
    final sortedMembers = _sortMembersWithOwnerFirst(members);

    Get.bottomSheet(
      Container(
        height: screenHeight * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 顶部拖动条和标题
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '群成员 (${sortedMembers.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            // 成员列表
            Expanded(
              child: sortedMembers.isEmpty
                  ? _buildEmptyMembersList()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sortedMembers.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 72,
                        color: Color(0xFFF0F0F0),
                      ),
                      itemBuilder: (context, index) {
                        final member = sortedMembers[index];
                        return _buildMemberItem(member);
                      },
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// 对成员列表进行排序，创建者置顶
  List<OnlineUser> _sortMembersWithOwnerFirst(List<OnlineUser> members) {
    final sorted = List<OnlineUser>.from(members);
    sorted.sort((a, b) {
      // 创建者置顶
      if (a.isOwner && !b.isOwner) return -1;
      if (!a.isOwner && b.isOwner) return 1;
      // 管理员其次
      if (a.isAdmin && !b.isAdmin) return -1;
      if (!a.isAdmin && b.isAdmin) return 1;
      // 在线用户优先
      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;
      // 按名称排序
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  /// 显示搜索聊天记录弹窗
  void _showSearchDialog() {
    final room = widget.controller.currentRoom;
    if (room == null) return;

    // 使用 currentRoomId 而不是 room.id，因为 API 请求和文件存储使用的是 currentRoomId
    final roomId = widget.controller.currentRoomId ?? room.id;
    final searchController = TextEditingController();
    final screenHeight = MediaQuery.of(context).size.height;

    Get.bottomSheet(
      _ChatSearchSheet(
        controller: widget.controller,
        roomId: roomId,
        searchController: searchController,
        screenHeight: screenHeight,
        scrollController: _scrollController,
        messages: widget.controller.messages,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 空成员列表
  Widget _buildEmptyMembersList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.users,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无成员',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建成员列表项
  Widget _buildMemberItem(OnlineUser member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          SafeCircleAvatar(
            imageUrl: member.avatar,
            radius: 24,
            backgroundColor: const Color(0xFF07C160),
            placeholder: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            errorWidget: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 在线状态指示器
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: member.isOnline ? const Color(0xFF07C160) : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              member.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // 角色标签
          if (member.isOwner)
            _buildRoleTag('群主', const Color(0xFFFF9800))
          else if (member.isAdmin)
            _buildRoleTag('管理员', const Color(0xFF2196F3)),
        ],
      ),
      subtitle: Text(
        member.isOnline ? '在线' : member.statusText,
        style: TextStyle(
          fontSize: 13,
          color: member.isOnline ? const Color(0xFF07C160) : Colors.grey[500],
        ),
      ),
      trailing: member.isOwner
          ? const Icon(
              FontAwesomeIcons.crown,
              color: Color(0xFFFF9800),
              size: 18,
            )
          : null,
    );
  }

  /// 构建角色标签
  Widget _buildRoleTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showMoreOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖动条
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 功能网格
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildMoreOption(
                      icon: FontAwesomeIcons.images,
                      label: '相册',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.camera,
                      label: '拍摄',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.locationDot,
                      label: '位置',
                      onTap: () => _pickLocation(),
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.folder,
                      label: '文件',
                      onTap: () => _pickFile(),
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.microphone,
                      label: '语音',
                      onTap: () {
                        Get.back();
                        _showVoiceRecordPanel();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 选择图片（相册/相机）
  Future<void> _pickImage(ImageSource source) async {
    Get.back(); // 关闭底部菜单
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        _sendImage(image);
      }
    } catch (e) {
      AppToast.error('选择图片失败: $e');
    }
  }

  /// 发送图片消息
  Future<void> _sendImage(XFile image) async {
    // 创建上传中图片的唯一 ID
    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadingImage = _UploadingImageGroup(
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

      // 模拟进度更新（Supabase SDK 暂不支持进度回调）
      _simulateUploadProgress(uploadId);

      // 使用 user-uploads bucket，文件夹为 chat-images/group-chat
      final imageUrl = await imageUploadService.uploadImage(
        imageFile: imageFile,
        bucket: 'user-uploads',
        folder: 'chat-images/group-chat',
        compress: true,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      debugPrint('✅ 图片上传成功: $imageUrl');

      // 2. 上传完成，从上传列表移除
      setState(() {
        _uploadingImages.removeWhere((img) => img.id == uploadId);
      });

      // 3. 发送图片消息（使用返回的 URL）
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

  /// 重试上传失败的图片
  void _retryUpload(_UploadingImageGroup uploadingImage) {
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

  /// 构建上传中图片的气泡
  Widget _buildUploadingImageBubble(_UploadingImageGroup uploadingImage) {
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
                        color: const Color(0xFF07C160).withValues(alpha: 0.2),
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
                : const Color(0xFF07C160).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// 构建上传进度遮罩
  Widget _buildUploadProgressOverlay(_UploadingImageGroup uploadingImage) {
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
  Widget _buildUploadErrorOverlay(_UploadingImageGroup uploadingImage) {
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
                    Icon(FontAwesomeIcons.arrowRotateRight, size: 12, color: Color(0xFF07C160)),
                    SizedBox(width: 4),
                    Text('重试', style: TextStyle(fontSize: 12, color: Color(0xFF07C160))),
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

  /// 选择文件
  Future<void> _pickFile() async {
    Get.back(); // 关闭底部菜单
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        if (platformFile.path != null) {
          _sendFile(platformFile);
        } else {
          AppToast.error('无法获取文件路径');
        }
      }
    } catch (e) {
      AppToast.error('选择文件失败: $e');
    }
  }

  /// 发送文件消息
  Future<void> _sendFile(PlatformFile platformFile) async {
    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadingFile = _UploadingFileGroup(
      id: uploadId,
      fileName: platformFile.name,
      fileSize: platformFile.size,
      localPath: platformFile.path!,
      progress: 0,
    );

    setState(() {
      _uploadingFiles.add(uploadingFile);
    });

    try {
      final file = File(platformFile.path!);
      final imageUploadService = ImageUploadService();

      // 模拟进度更新
      _simulateFileUploadProgress(uploadId);

      // 上传文件到 Supabase Storage
      final fileUrl = await imageUploadService.uploadFile(
        file: file,
        bucket: 'user-uploads',
        folder: 'chat-files/group-chat',
        fileName: platformFile.name,
      );

      debugPrint('✅ 文件上传成功: $fileUrl');

      setState(() {
        _uploadingFiles.removeWhere((f) => f.id == uploadId);
      });

      // 发送文件消息
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
      debugPrint('❌ 文件上传失败: $e');
      setState(() {
        final index = _uploadingFiles.indexWhere((f) => f.id == uploadId);
        if (index != -1) {
          _uploadingFiles[index] = _uploadingFiles[index].copyWith(
            errorMessage: '上传失败，请重试',
          );
        }
      });
    }
  }

  /// 模拟文件上传进度
  void _simulateFileUploadProgress(String uploadId) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;

      final index = _uploadingFiles.indexWhere((f) => f.id == uploadId);
      if (index == -1) return false;

      final current = _uploadingFiles[index];
      if (current.errorMessage != null) return false;
      if (current.progress >= 0.9) return false;

      setState(() {
        _uploadingFiles[index] = current.copyWith(
          progress: current.progress + 0.1,
        );
      });
      return true;
    });
  }

  /// 获取文件 MIME 类型
  String _getMimeType(String? extension) {
    if (extension == null) return 'application/octet-stream';
    final ext = extension.toLowerCase();
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'zip': 'application/zip',
      'rar': 'application/x-rar-compressed',
      'mp3': 'audio/mpeg',
      'mp4': 'video/mp4',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
    };
    return mimeTypes[ext] ?? 'application/octet-stream';
  }

  /// 选择位置
  Future<void> _pickLocation() async {
    Get.back(); // 关闭底部菜单
    try {
      // 跳转到地图选择页面
      final result = await Get.to<Map<String, dynamic>>(
        () => const FlutterMapPickerPage(),
      );
      if (result != null) {
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        final address = result['address'] as String?;
        if (lat != null && lng != null) {
          // 发送位置消息
          widget.controller.sendMessage(
            address ?? '位置',
            messageType: 'location',
            attachment: {
              'latitude': lat,
              'longitude': lng,
              'locationName': address ?? '位置',
            },
          );
          debugPrint('✅ 位置消息发送: $address ($lat, $lng)');
        }
      }
    } catch (e) {
      AppToast.error('选择位置失败: $e');
    }
  }

  /// 显示语音录制面板（微信风格）
  void _showVoiceRecordPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => _VoiceRecordPanel(
        onSendVoice: (path, duration) => _sendVoiceMessage(path, duration),
      ),
    );
  }

  /// 发送语音消息
  Future<void> _sendVoiceMessage(String localPath, int duration) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) {
        AppToast.error('语音文件不存在');
        return;
      }

      // 上传语音文件到 Supabase Storage
      final imageUploadService = ImageUploadService();
      final voiceUrl = await imageUploadService.uploadFile(
        file: file,
        bucket: 'user-uploads',
        folder: 'chat-voice/group-chat',
      );

      debugPrint('✅ 语音上传成功: $voiceUrl');

      // 发送语音消息
      widget.controller.sendMessage(
        '语音消息',
        messageType: 'voice',
        attachment: {
          'url': voiceUrl,
          'duration': duration,
          'mimeType': 'audio/m4a',
        },
      );

      // 删除本地临时文件
      try {
        await file.delete();
      } catch (e) {
        debugPrint('⚠️ 删除临时语音文件失败: $e');
      }
    } catch (e) {
      AppToast.error('发送语音失败: $e');
    }
  }

  Widget _buildMoreOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF666666), size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// 消息气泡
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Color? bubbleColor;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.bubbleColor,
    this.onLongPress,
  });

  /// 获取气泡背景色
  Color get _bubbleBackgroundColor {
    if (isMe) {
      return const Color(0xFF95EC69); // 微信绿色
    }
    return bubbleColor ?? Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 非本人消息显示头像在左侧
            if (!isMe) ...[
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // 非本人消息显示用户名
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        message.author.userName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getNameColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  _buildMessageContent(context),
                  // 显示时间
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 本人消息显示头像在右侧
            if (isMe) ...[
              const SizedBox(width: 8),
              _buildAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        // 点击头像跳转到用户详情页
        if (!isMe) {
          Get.to(() => MemberDetailPage(userId: message.author.userId));
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isMe ? const Color(0xFF07C160) : _getAvatarBackgroundColor(),
        ),
        clipBehavior: Clip.antiAlias,
        child: (message.author.userAvatar != null && message.author.userAvatar!.isNotEmpty)
            ? Image.network(
                message.author.userAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  /// 头像占位符
  Widget _buildAvatarPlaceholder() {
    final initial = message.author.userName.isNotEmpty ? message.author.userName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 根据用户 ID 获取头像背景色
  Color _getAvatarBackgroundColor() {
    final colors = [
      const Color(0xFF5B8FF9),
      const Color(0xFF5AD8A6),
      const Color(0xFF5D7092),
      const Color(0xFFF6BD16),
      const Color(0xFFE8684A),
      const Color(0xFF6DC8EC),
      const Color(0xFF9270CA),
      const Color(0xFFFF9D4D),
    ];
    final index = message.author.userId.hashCode.abs() % colors.length;
    return colors[index];
  }

  /// 根据用户 ID 获取名称颜色
  Color _getNameColor() {
    final colors = [
      const Color(0xFF5B8FF9),
      const Color(0xFF5AD8A6),
      const Color(0xFF5D7092),
      const Color(0xFFF6BD16),
      const Color(0xFFE8684A),
      const Color(0xFF6DC8EC),
      const Color(0xFF9270CA),
      const Color(0xFFFF9D4D),
    ];
    final index = message.author.userId.hashCode.abs() % colors.length;
    return colors[index];
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return timeStr;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 $timeStr';
    } else if (now.difference(time).inDays < 7) {
      final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return '${weekdays[time.weekday % 7]} $timeStr';
    } else {
      return '${time.month}/${time.day} $timeStr';
    }
  }

  /// 根据消息类型构建不同的内容
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.location:
        return _buildLocationMessage(context);
      case MessageType.voice:
        return _buildVoiceMessage();
      case MessageType.video:
        // 视频消息暂不支持，显示为文本
        return _buildTextMessage();
      case MessageType.text:
        return _buildTextMessage();
    }
  }

  /// 文本消息
  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: _bubbleBackgroundColor,
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
      child: Text(
        message.message,
        style: TextStyle(
          fontSize: 16,
          color: isMe ? Colors.black : const Color(0xFF333333),
          height: 1.4,
        ),
      ),
    );
  }

  /// 图片消息
  Widget _buildImageMessage() {
    final attachment = message.attachment;
    if (attachment == null) return _buildTextMessage();

    return GestureDetector(
      onTap: () => _showFullScreenImage(attachment.url),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe ? 16 : 4),
          topRight: Radius.circular(isMe ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 300,
            ),
            child: Image.network(
              attachment.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: const Color(0xFF07C160),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.image, color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text('加载失败', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 显示全屏图片
  void _showFullScreenImage(String imageUrl) {
    Get.to(
      () => _FullScreenImageViewer(imagePath: imageUrl),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// 文件消息
  Widget _buildFileMessage() {
    final attachment = message.attachment;
    if (attachment == null) return _buildTextMessage();

    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: _bubbleBackgroundColor,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              FontAwesomeIcons.file,
              color: Color(0xFF4A90E2),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.fileName ?? '未知文件',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.formattedFileSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 位置消息
  Widget _buildLocationMessage(BuildContext context) {
    final attachment = message.attachment;
    if (attachment == null || !attachment.isLocation) {
      return _buildTextMessage();
    }

    return GestureDetector(
      onTap: () => _showMapPicker(
        context,
        attachment.latitude!,
        attachment.longitude!,
        attachment.locationName ?? '位置',
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: _bubbleBackgroundColor,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // 地图预览区域
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 16 : 4),
                topRight: Radius.circular(isMe ? 4 : 16),
              ),
              child: Container(
                width: 220,
                height: 120,
                color: const Color(0xFFE8F5E9),
                child: Stack(
                  children: [
                    // 静态地图图片（使用 OpenStreetMap 静态图）
                    Image.network(
                      'https://staticmap.openstreetmap.de/staticmap.php?center=${attachment.latitude},${attachment.longitude}&zoom=15&size=220x120&markers=${attachment.latitude},${attachment.longitude},red-pushpin',
                      fit: BoxFit.cover,
                      width: 220,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              FontAwesomeIcons.mapLocationDot,
                              color: Color(0xFF4CAF50),
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    // 中心标记点
                    const Center(
                      child: Icon(
                        FontAwesomeIcons.locationDot,
                        color: Color(0xFFE53935),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 位置名称
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.locationDot,
                    color: Color(0xFF666666),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      attachment.locationName ?? '位置',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
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

  /// 显示地图APP选择器
  void _showMapPicker(BuildContext context, double latitude, double longitude, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽条
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
            // Apple 地图
            _MapAppOption(
              icon: FontAwesomeIcons.apple,
              title: 'Apple 地图',
              iconColor: Colors.black87,
              onTap: () => _openAppleMaps(ctx, latitude, longitude, name),
            ),
            // Google 地图
            _MapAppOption(
              icon: FontAwesomeIcons.google,
              title: 'Google 地图',
              iconColor: const Color(0xFF4285F4),
              onTap: () => _openGoogleMaps(ctx, latitude, longitude, name),
            ),
            // 高德地图
            _MapAppOption(
              icon: FontAwesomeIcons.locationArrow,
              title: '高德地图',
              iconColor: const Color(0xFF0091FF),
              onTap: () => _openAmap(ctx, latitude, longitude, name),
            ),
            // 百度地图
            _MapAppOption(
              icon: FontAwesomeIcons.mapPin,
              title: '百度地图',
              iconColor: const Color(0xFF3385FF),
              onTap: () => _openBaiduMap(ctx, latitude, longitude, name),
            ),
            // 腾讯地图
            _MapAppOption(
              icon: FontAwesomeIcons.mapLocation,
              title: '腾讯地图',
              iconColor: const Color(0xFF12B7F5),
              onTap: () => _openTencentMap(ctx, latitude, longitude, name),
            ),
            const SizedBox(height: 8),
            // 取消按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
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

  /// 打开 Apple 地图
  Future<void> _openAppleMaps(
      BuildContext context, double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'maps://?q=${Uri.encodeComponent(name)}&ll=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError(context, 'Apple 地图');
    }
  }

  /// 打开 Google 地图
  Future<void> _openGoogleMaps(
      BuildContext context, double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'comgooglemaps://?q=$latitude,$longitude&center=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError(context, 'Google 地图');
    }
  }

  /// 打开高德地图
  Future<void> _openAmap(
      BuildContext context, double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'iosamap://viewMap?sourceApplication=GoNomads&poiname=${Uri.encodeComponent(name)}&lat=$latitude&lon=$longitude&dev=0');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError(context, '高德地图');
    }
  }

  /// 打开百度地图
  Future<void> _openBaiduMap(
      BuildContext context, double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'baidumap://map/marker?location=$latitude,$longitude&title=${Uri.encodeComponent(name)}&coord_type=gcj02&src=GoNomads');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError(context, '百度地图');
    }
  }

  /// 打开腾讯地图
  Future<void> _openTencentMap(
      BuildContext context, double latitude, double longitude, String name) async {
    Navigator.pop(context);
    final url = Uri.parse(
        'qqmap://map/marker?marker=coord:$latitude,$longitude;title:${Uri.encodeComponent(name)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showMapError(context, '腾讯地图');
    }
  }

  /// 显示地图打开失败提示
  void _showMapError(BuildContext context, String mapName) {
    AppToast.warning('未安装$mapName');
  }

  /// 语音消息
  Widget _buildVoiceMessage() {
    final attachment = message.attachment;
    final duration = attachment?.duration ?? 0;
    // 根据时长计算宽度，最小100，最大200
    final width = (100 + duration * 3).clamp(100, 200).toDouble();

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bubbleBackgroundColor,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.microphone,
            color: isMe ? Colors.black54 : const Color(0xFF07C160),
            size: 18,
          ),
          const SizedBox(width: 8),
          // 声波动画指示器
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => Container(
                  width: 3,
                  height: [8, 14, 10, 16, 12, 8][index].toDouble(),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black38 : const Color(0xFF07C160),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$duration″',
            style: TextStyle(
              fontSize: 14,
              color: isMe ? Colors.black54 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// 聊天记录搜索 Sheet
class _ChatSearchSheet extends StatefulWidget {
  final ChatStateController controller;
  final String roomId;
  final TextEditingController searchController;
  final double screenHeight;
  final ScrollController scrollController;
  final List<ChatMessage> messages;

  const _ChatSearchSheet({
    required this.controller,
    required this.roomId,
    required this.searchController,
    required this.screenHeight,
    required this.scrollController,
    required this.messages,
  });

  @override
  State<_ChatSearchSheet> createState() => _ChatSearchSheetState();
}

class _ChatSearchSheetState extends State<_ChatSearchSheet> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    // 打印存储状态（调试用）
    widget.controller.debugPrintStorageStats();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // 清除搜索状态
    widget.controller.clearSearch();
    super.dispose();
  }

  void _performSearch() {
    final keyword = widget.searchController.text.trim();
    if (keyword.isNotEmpty) {
      widget.controller.searchMessages(keyword, roomId: widget.roomId);
    }
  }

  /// 跳转到消息位置
  void _jumpToMessage(ChatMessage message) {
    // 在当前消息列表中查找
    final index = widget.controller.findMessageIndex(message.id);
    if (index >= 0) {
      // 关闭搜索弹窗
      Get.back();

      // 滚动到消息位置
      // 由于消息列表是倒序的，需要计算正确的位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          // 计算目标位置（每个消息约 80 像素高度）
          final targetPosition = index * 80.0;
          widget.scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });

      AppToast.success('已定位到消息');
    } else {
      AppToast.info('消息不在当前加载范围内，请加载更多历史消息');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '搜索聊天记录',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: widget.searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '搜索消息内容...',
                hintStyle: const TextStyle(color: Color(0xFF999999)),
                prefixIcon: const Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 18,
                  color: Color(0xFF999999),
                ),
                suffixIcon: Obx(() {
                  if (widget.controller.isSearching) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF07C160),
                        ),
                      ),
                    );
                  }
                  if (widget.searchController.text.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.xmark,
                        size: 16,
                        color: Color(0xFF999999),
                      ),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.controller.clearSearch();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {}); // 更新清除按钮状态
                if (value.isEmpty) {
                  widget.controller.clearSearch();
                }
              },
            ),
          ),
          // 搜索按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07C160),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '搜索',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          // 搜索结果统计
          Obx(() {
            final count = widget.controller.searchResultCount;
            final keyword = widget.controller.searchKeyword;
            if (keyword.isNotEmpty && !widget.controller.isSearching) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '找到 $count 条包含"$keyword"的消息',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const Divider(height: 1),
          // 搜索结果列表
          Expanded(
            child: Obx(() {
              if (widget.controller.isSearching) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF07C160)),
                      SizedBox(height: 16),
                      Text(
                        '搜索中...',
                        style: TextStyle(color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                );
              }

              final results = widget.controller.searchResults;
              final keyword = widget.controller.searchKeyword;

              if (keyword.isEmpty) {
                return _buildSearchHint();
              }

              if (results.isEmpty) {
                return _buildNoResults(keyword);
              }

              return ListView.builder(
                itemCount: results.length + (widget.controller.hasMoreSearchResults ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == results.length) {
                    // 加载更多
                    return _buildLoadMore();
                  }
                  return _buildSearchResultItem(results[index], keyword);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '输入关键词搜索聊天记录',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String keyword) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.faceSadTear,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '未找到包含"$keyword"的消息',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词？',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return InkWell(
      onTap: () => widget.controller.loadMoreSearchResults(roomId: widget.roomId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: Text(
            '加载更多结果',
            style: TextStyle(
              color: Color(0xFF07C160),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(ChatMessage message, String keyword) {
    return InkWell(
      onTap: () => _jumpToMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 发送者头像
            SafeCircleAvatar(
              imageUrl: message.author.userAvatar,
              radius: 20,
              backgroundColor: const Color(0xFF07C160),
              placeholder: Text(
                message.author.userName.isNotEmpty ? message.author.userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 消息内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 发送者名称和时间
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.author.userName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 消息内容（高亮关键词）
                  _buildHighlightedText(message.message, keyword),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 跳转图标
            const Icon(
              FontAwesomeIcons.chevronRight,
              size: 12,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }

  /// 高亮显示关键词
  Widget _buildHighlightedText(String text, String keyword) {
    if (keyword.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerKeyword, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF07C160),
          fontWeight: FontWeight.w600,
          backgroundColor: Color(0xFFE8F5E9),
        ),
      ));

      start = index + keyword.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 格式化消息时间
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      // 今天，显示时:分
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[time.weekday % 7];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 全屏图片查看器
class _FullScreenImageViewer extends StatefulWidget {
  final String imagePath;

  const _FullScreenImageViewer({required this.imagePath});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_currentScale != 1.0)
            IconButton(
              icon: const Icon(Icons.zoom_out_map, color: Colors.white),
              onPressed: _resetZoom,
              tooltip: '重置缩放',
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
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
    );
  }

  Widget _buildFullScreenImage() {
    return Image.network(
      widget.imagePath,
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
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.image, color: Colors.grey, size: 60),
            SizedBox(height: 16),
            Text('图片加载失败', style: TextStyle(color: Colors.grey)),
          ],
        );
      },
    );
  }
}

/// 微信风格语音录制面板
class _VoiceRecordPanel extends StatefulWidget {
  final void Function(String path, int duration) onSendVoice;

  const _VoiceRecordPanel({required this.onSendVoice});

  @override
  State<_VoiceRecordPanel> createState() => _VoiceRecordPanelState();
}

class _VoiceRecordPanelState extends State<_VoiceRecordPanel> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isCancelArea = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  String? _recordingPath;
  double _startY = 0;

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        // 开始计时
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
          // 最长录音 60 秒
          if (_recordDuration >= 60) {
            _stopRecording(send: true);
          }
        });

        // 震动反馈
        HapticFeedback.mediumImpact();
      } else {
        AppToast.error('请允许录音权限');
      }
    } catch (e) {
      AppToast.error('录音失败: $e');
    }
  }

  Future<void> _stopRecording({bool send = false}) async {
    _recordTimer?.cancel();
    
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      
      setState(() {
        _isRecording = false;
      });

      if (send && path != null && _recordDuration >= 1) {
        widget.onSendVoice(path, _recordDuration);
        Get.back();
      } else if (_recordDuration < 1) {
        AppToast.info('说话时间太短');
        // 删除过短的录音文件
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('停止录音失败: $e');
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      
      setState(() {
        _isRecording = false;
      });

      // 删除录音文件
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }

      Get.back();
    } catch (e) {
      debugPrint('取消录音失败: $e');
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 录音状态指示
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 取消区域指示
                if (_isRecording)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isCancelArea ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCancelArea ? FontAwesomeIcons.trash : FontAwesomeIcons.arrowUp,
                          color: _isCancelArea ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCancelArea ? '松开取消' : '上滑取消发送',
                          style: TextStyle(
                            color: _isCancelArea ? Colors.red : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // 录音时长
                if (_isRecording)
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                else
                  const Text(
                    '按住录音',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                
                const SizedBox(height: 10),
                
                // 声波动画
                if (_isRecording)
                  _buildSoundWave(),
              ],
            ),
          ),
          
          // 录音按钮
          GestureDetector(
            onLongPressStart: (details) {
              _startY = details.globalPosition.dy;
              _startRecording();
            },
            onLongPressMoveUpdate: (details) {
              final deltaY = _startY - details.globalPosition.dy;
              setState(() {
                _isCancelArea = deltaY > 100;
              });
            },
            onLongPressEnd: (details) {
              if (_isCancelArea) {
                _cancelRecording();
              } else {
                _stopRecording(send: true);
              }
            },
            onLongPressCancel: () {
              _cancelRecording();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording 
                    ? (_isCancelArea ? Colors.red : const Color(0xFF07C160))
                    : const Color(0xFF07C160),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording 
                        ? (_isCancelArea ? Colors.red : const Color(0xFF07C160))
                        : const Color(0xFF07C160)).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isRecording 
                    ? (_isCancelArea ? FontAwesomeIcons.xmark : FontAwesomeIcons.microphone)
                    : FontAwesomeIcons.microphone,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        final heights = [12.0, 20.0, 28.0, 36.0, 28.0, 20.0, 12.0];
        return AnimatedContainer(
          duration: Duration(milliseconds: 100 + index * 50),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: heights[index] * (0.5 + (_recordDuration % 2) * 0.5),
          decoration: BoxDecoration(
            color: const Color(0xFF07C160),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// 地图APP选项组件
class _MapAppOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapAppOption({
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
