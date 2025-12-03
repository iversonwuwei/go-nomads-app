import 'package:df_admin_mobile/features/chat/domain/entities/chat.dart';
import 'package:df_admin_mobile/features/chat/presentation/controllers/chat_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/flutter_map_picker_page.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:file_picker/file_picker.dart';
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
class CityChatPage extends StatefulWidget {
  const CityChatPage({super.key});

  @override
  State<CityChatPage> createState() => _CityChatPageState();
}

class _CityChatPageState extends State<CityChatPage> {
  late ChatStateController controller;
  bool _initialized = false;
  bool _isMeetupChat = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatStateController>();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null && args['isMeetupChat'] == true) {
      // 从 Meetup 进入的聊天
      _isMeetupChat = true;
      final meetupId = args['meetupId'] as String?;
      final meetupTitle = args['city'] as String? ?? 'Meetup Chat';
      final meetupType = args['country'] as String?;

      if (meetupId != null) {
        await controller.joinMeetupRoom(
          meetupId: meetupId,
          meetupTitle: meetupTitle,
          meetupType: meetupType,
        );
      }
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ChatListSkeleton();
    }

    return Obx(() {
      if (controller.isLoading && controller.currentRoom == null) {
        return const ChatListSkeleton();
      }

      if (controller.currentRoom == null) {
        // 如果是从 Meetup 进入但聊天室已被清空，说明已经退出，返回上一页
        if (_isMeetupChat) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
          });
          return const SizedBox.shrink();
        }
        return _ChatRoomsListView(controller: controller);
      }

      return _ChatRoomView(
        controller: controller,
        isMeetupChat: _isMeetupChat,
      );
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

/// 聊天室详情视图
class _ChatRoomView extends StatefulWidget {
  final ChatStateController controller;
  final bool isMeetupChat;

  const _ChatRoomView({
    required this.controller,
    this.isMeetupChat = false,
  });

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
            child: Obx(() => widget.controller.messages.isEmpty ? _buildEmptyMessages() : _buildMessagesList()),
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

  /// 退出聊天室并返回上一页
  Future<void> _leaveAndGoBack() async {
    await widget.controller.leaveRoom();
    // 如果是从 Meetup 进入，直接返回上一页
    if (widget.isMeetupChat) {
      Get.back();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final room = widget.controller.currentRoom!;
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
            room.displayName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(() => Text(
                '${widget.controller.onlineCount > 0 ? widget.controller.onlineCount : room.stats.onlineUsers}人在线',
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
              )),
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
                      icon: const Icon(FontAwesomeIcons.faceSmile, color: Color(0xFF666666), size: 26),
                      onPressed: () => AppToast.info('表情功能即将推出'),
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
                  _showMembersList();
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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF07C160),
            backgroundImage: member.hasAvatar ? NetworkImage(member.avatar!) : null,
            child: !member.hasAvatar
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
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
                        AppToast.info('语音功能即将推出');
                      },
                    ),
                    _buildMoreOption(
                      icon: FontAwesomeIcons.video,
                      label: '视频',
                      onTap: () => _pickVideo(),
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
    // TODO: 上传图片到服务器并获取 URL，然后发送图片消息
    AppToast.info('图片发送功能即将完善');
    debugPrint('选择的图片: ${image.path}');
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    Get.back(); // 关闭底部菜单
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (video != null) {
        // TODO: 上传视频到服务器并获取 URL，然后发送视频消息
        AppToast.info('视频发送功能即将完善');
        debugPrint('选择的视频: ${video.path}');
      }
    } catch (e) {
      AppToast.error('选择视频失败: $e');
    }
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
        final file = result.files.first;
        // TODO: 上传文件到服务器并获取 URL，然后发送文件消息
        AppToast.info('文件发送功能即将完善');
        debugPrint('选择的文件: ${file.name}, 大小: ${file.size}');
      }
    } catch (e) {
      AppToast.error('选择文件失败: $e');
    }
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
          // TODO: 发送位置消息
          AppToast.info('位置发送功能即将完善');
          debugPrint('选择的位置: $address ($lat, $lng)');
        }
      }
    } catch (e) {
      AppToast.error('选择位置失败: $e');
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
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: (message.author.userAvatar != null && message.author.userAvatar!.isNotEmpty)
                    ? NetworkImage(message.author.userAvatar!)
                    : null,
                child: (message.author.userAvatar == null || message.author.userAvatar!.isEmpty)
                    ? const Icon(FontAwesomeIcons.user, size: 20)
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.author.userName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ),
                  _buildMessageContent(context),
                ],
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundImage: (message.author.userAvatar != null && message.author.userAvatar!.isNotEmpty)
                    ? NetworkImage(message.author.userAvatar!)
                    : null,
                child: (message.author.userAvatar == null || message.author.userAvatar!.isEmpty)
                    ? const Icon(FontAwesomeIcons.user, size: 20)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据消息类型构建不同的内容
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.location:
        return _buildLocationMessage();
      case MessageType.voice:
        return _buildVoiceMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.text:
        return _buildTextMessage();
    }
  }

  /// 文本消息
  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }

  /// 图片消息
  Widget _buildImageMessage() {
    final attachment = message.attachment;
    if (attachment == null) return _buildTextMessage();

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMe ? 18 : 4),
        topRight: Radius.circular(isMe ? 4 : 18),
        bottomLeft: const Radius.circular(18),
        bottomRight: const Radius.circular(18),
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
        color: isMe ? const Color(0xFF95EC69) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe ? 18 : 4),
          topRight: Radius.circular(isMe ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
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
  Widget _buildLocationMessage() {
    final attachment = message.attachment;
    if (attachment == null || !attachment.isLocation) {
      return _buildTextMessage();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF95EC69) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe ? 18 : 4),
          topRight: Radius.circular(isMe ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 地图预览区域
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 18 : 4),
              topRight: Radius.circular(isMe ? 4 : 18),
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
    );
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
        color: isMe ? const Color(0xFF95EC69) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe ? 18 : 4),
          topRight: Radius.circular(isMe ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
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

  /// 视频消息
  Widget _buildVideoMessage() {
    final attachment = message.attachment;
    if (attachment == null) return _buildTextMessage();

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMe ? 18 : 4),
        topRight: Radius.circular(isMe ? 4 : 18),
        bottomLeft: const Radius.circular(18),
        bottomRight: const Radius.circular(18),
      ),
      child: Stack(
        children: [
          // 视频缩略图
          Container(
            width: 200,
            height: 150,
            color: Colors.black87,
            child: attachment.url.isNotEmpty
                ? Image.network(
                    attachment.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.video,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      FontAwesomeIcons.video,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
          ),
          // 播放按钮
          Positioned.fill(
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.play,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          // 视频时长
          if (attachment.duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(attachment.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 格式化时长
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
