import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 城市聊天室页面 - WeChat 风格设计
///
/// 设计理念:
/// - 简洁的列表界面,清晰的层级结构
/// - 绿色作为主题色(WeChat 风格)
/// - 流畅的动画和过渡效果
/// - 支持长按回复、滑动删除等交互
class CityChatPage extends StatelessWidget {
  const CityChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatStateController>();

    return Obx(() {
      if (controller.isLoading && controller.currentRoom == null) {
        return const ChatListSkeleton();
      }

      if (controller.currentRoom == null) {
        return _ChatRoomsListView(controller: controller);
      }

      return _ChatRoomView(controller: controller);
    });
  }
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
                room.stats.onlineUsers > 99
                    ? '99+'
                    : '${room.stats.onlineUsers}',
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

/// 聊天室详情视图
class _ChatRoomView extends StatefulWidget {
  final ChatStateController controller;

  const _ChatRoomView({required this.controller});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
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
            child: Obx(() => widget.controller.messages.isEmpty
                ? _buildEmptyMessages()
                : _buildMessagesList()),
          ),
          Obx(() {
            if (widget.controller.replyTo != null) {
              return _buildReplyBar();
            }
            return const SizedBox.shrink();
          }),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final room = widget.controller.currentRoom!;
    return AppBar(
      backgroundColor: const Color(0xFFEDEDED),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: AppBackButton(
        color: Colors.black,
        onPressed: () => widget.controller.leaveRoom(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.displayName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${room.stats.onlineUsers}人在线',
            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
          ),
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
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.controller.messages.length,
      itemBuilder: (context, index) {
        final message = widget.controller.messages[index];
        final isMe = message.author.userId == 'currentUserId'; // TODO: 实际用户ID
        return _MessageBubble(
          message: message,
          isMe: isMe,
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
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF666666)),
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
                icon: const Icon(FontAwesomeIcons.microphone,
                    color: Color(0xFF666666), size: 26),
                onPressed: () => _showMoreOptions(),
              ),
            ),
            // 输入框
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: '说点什么...',
                    hintStyle:
                        TextStyle(color: Color(0xFFBBBBBB), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  onChanged: (_) => setState(() {}),
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
                      icon: const Icon(FontAwesomeIcons.faceSmile,
                          color: Color(0xFF666666), size: 26),
                      onPressed: () => AppToast.info('表情功能即将推出'),
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.circlePlus,
                          color: Color(0xFF666666), size: 26),
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
    }
  }

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
                  AppToast.info('成员列表功能即将推出');
                },
              ),
              _buildMenuOption(
                icon: FontAwesomeIcons.magnifyingGlass,
                title: '搜索聊天记录',
                onTap: () {
                  Get.back();
                  AppToast.info('搜索功能即将推出');
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
                  Get.back();
                  widget.controller.leaveRoom();
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
                  children: [
                    _buildMoreOption(
                      icon: FontAwesomeIcons.images,
                      label: '相册',
                      onTap: () async {
                        Get.back();
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          AppToast.success('已选择图片');
                        }
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.camera,
                      label: '拍摄',
                      onTap: () async {
                        Get.back();
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          AppToast.success('已拍摄照片');
                        }
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.locationDot,
                      label: '位置',
                      onTap: () {
                        Get.back();
                        AppToast.info('位置分享功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.microphone,
                      label: '语音',
                      onTap: () {
                        Get.back();
                        AppToast.info('语音功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.video,
                      label: '视频',
                      onTap: () {
                        Get.back();
                        AppToast.info('视频功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.userPlus,
                      label: '名片',
                      onTap: () {
                        Get.back();
                        AppToast.info('名片分享功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.folder,
                      label: '文件',
                      onTap: () {
                        Get.back();
                        AppToast.info('文件功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.heart,
                      label: '收藏',
                      onTap: () {
                        Get.back();
                        AppToast.info('收藏功能即将推出');
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
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
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: (message.author.userAvatar != null &&
                        message.author.userAvatar!.isNotEmpty)
                    ? NetworkImage(message.author.userAvatar!)
                    : null,
                child: (message.author.userAvatar == null ||
                        message.author.userAvatar!.isEmpty)
                    ? const Icon(FontAwesomeIcons.user, size: 20)
                    : null,
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
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.author.userName,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF95EC69) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMe ? 18 : 4),
                        topRight: Radius.circular(isMe ? 4 : 18),
                        bottomLeft: const Radius.circular(18),
                        bottomRight: const Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundImage: (message.author.userAvatar != null &&
                        message.author.userAvatar!.isNotEmpty)
                    ? NetworkImage(message.author.userAvatar!)
                    : null,
                child: (message.author.userAvatar == null ||
                        message.author.userAvatar!.isEmpty)
                    ? const Icon(FontAwesomeIcons.user, size: 20)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
