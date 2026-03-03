import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/chat/presentation/controllers/conversation_list_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 会话列表页面 — 微信风格
/// 展示所有 C2C 聊天会话，支持未读数量、最后消息预览、滑动删除
class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 延迟注入控制器
    final controller = Get.put(ConversationListController());

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // 微信风格背景色
      appBar: AppBar(
        title: Text(
          '消息',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingView();
        }

        if (controller.errorMessage.value != null) {
          return _ErrorView(
            message: controller.errorMessage.value!,
            onRetry: () => controller.onRefresh(),
          );
        }

        if (controller.conversations.isEmpty) {
          return const _EmptyView();
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: const Color(0xFF07C160), // 微信绿
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return _ConversationTile(
                conversation: conversation,
                onTap: () => _navigateToChat(controller, conversation),
                onDismissed: () => controller.deleteConversation(conversation.conversationID),
              );
            },
          ),
        );
      }),
    );
  }

  /// 导航到私聊页面
  void _navigateToChat(
    ConversationListController controller,
    V2TimConversation conversation,
  ) {
    // 标记已读
    final userId = controller.extractUserId(conversation.conversationID);
    if (userId != null) {
      controller.markAsRead(userId);
    }

    // 构造一个最小 User 对象用于导航
    final user = models.User(
      id: userId ?? '',
      name: conversation.showName ?? '未知用户',
      username: conversation.showName ?? '未知用户',
      avatarUrl: conversation.faceUrl,
      stats: models.TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0,
      ),
      joinedDate: DateTime.now(),
    );

    Get.toNamed(AppRoutes.directChat, arguments: user);
  }
}

// ============================================================================
// 会话列表项 — 微信风格
// ============================================================================

class _ConversationTile extends StatelessWidget {
  final V2TimConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCount ?? 0;
    final lastMsg = conversation.lastMessage;
    final timestamp = lastMsg?.timestamp;

    final tile = Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // 头像 + 未读 badge
              _buildAvatar(unread),
              SizedBox(width: 12.w),
              // 名字 + 最后消息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.showName ?? '未知用户',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            _formatTime(timestamp),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFFB2B2B2),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getLastMessagePreview(lastMsg),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF999999),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key(conversation.conversationID),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除会话'),
            content: const Text('确定要删除这个会话吗？聊天记录将被清除。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDismissed(),
      child: tile,
    );
  }

  /// 头像 + 未读角标
  Widget _buildAvatar(int unread) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 头像
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r), // 微信方形圆角风格
          child: conversation.faceUrl != null && conversation.faceUrl!.isNotEmpty
              ? Image.network(
                  conversation.faceUrl!,
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultAvatar(),
                )
              : _defaultAvatar(),
        ),
        // 未读角标
        if (unread > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFA5151), // 微信红点
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.h),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFF07C160).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          color: Color(0xFF07C160),
          size: 22.r,
        ),
      ),
    );
  }

  /// 格式化时间戳为友好显示
  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dt.weekday - 1];
    }
    return '${dt.month}/${dt.day}';
  }

  /// 获取最后一条消息的预览文本
  String _getLastMessagePreview(dynamic lastMsg) {
    if (lastMsg == null) return '';

    final elemType = lastMsg.elemType;
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return lastMsg.textElem?.text ?? '';
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return '[图片]';
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return '[语音]';
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return '[视频]';
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return '[文件]';
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return '[表情]';
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return '[位置]';
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return '[自定义消息]';
      default:
        return '[消息]';
    }
  }
}

// ============================================================================
// 空状态
// ============================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.commentDots,
            size: 64.r,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无消息',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '去城市或活动页面开始聊天吧',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 加载状态
// ============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: Colors.white,
        child: Row(
          children: [
            // 头像骨架
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4.r),
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
}

// ============================================================================
// 错误状态
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            size: 48.r,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
