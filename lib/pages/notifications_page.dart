import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/notification/domain/entities/app_notification.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 通知列表页面
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationStateController _controller;
  bool _isInitialized = false;
  final RxBool _isRefreshing = false.obs; // 下拉刷新状态标志

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 设置中文 timeago
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());

    // 获取控制器
    _controller = Get.find<NotificationStateController>();

    // 页面显示后立即加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        print('📱 页面初始化完成，开始加载通知数据');
        // 只调用一次，获取列表和未读数量
        _controller.loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _isRefreshing.value = true;
    await _controller.refresh();
    _isRefreshing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    print('📱 NotificationsPage.build() 开始');

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // TabBar 区域
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // TabBar 和操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.accent,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.accent,
                          tabs: const [
                            Tab(text: '全部'),
                            Tab(text: '未读'),
                            Tab(text: '已读'),
                          ],
                          onTap: (index) {
                            switch (index) {
                              case 0:
                                _controller.loadNotifications();
                                break;
                              case 1:
                                _controller.loadNotifications(isRead: false);
                                break;
                              case 2:
                                _controller.loadNotifications(isRead: true);
                                break;
                            }
                          },
                        ),
                      ),
                      // 全部标记为已读按钮
                      Obx(() {
                        final hasUnread = _controller.unreadCount.value > 0;
                        return hasUnread
                            ? IconButton(
                                icon: const Icon(FontAwesomeIcons.checkDouble),
                                tooltip: '全部标记为已读',
                                onPressed: () async {
                                  final success = await _controller.markAllAsRead();
                                  if (success) {
                                    AppToast.success('已全部标记为已读');
                                  }
                                },
                              )
                            : const SizedBox(width: 48);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_controller, isMobile, null),
                _buildNotificationList(_controller, isMobile, false),
                _buildNotificationList(_controller, isMobile, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    NotificationStateController controller,
    bool isMobile,
    bool? isRead,
  ) {
    return Obx(() {
      // 首次加载时显示中间加载指示器
      if (_controller.isLoading.value && _controller.notifications.isEmpty && !_isRefreshing.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.circleExclamation, size: 64, color: AppColors.iconSecondary),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage.value,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _controller.loadNotifications(isRead: isRead),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      final notifications = _controller.notifications.where((n) => isRead == null || n.isRead == isRead).toList();

      if (notifications.isEmpty) {
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.bell, size: 64, color: AppColors.iconSecondary),
                        const SizedBox(height: 16),
                        Text(
                          isRead == null
                              ? '暂无通知'
                              : isRead
                                  ? '暂无已读通知'
                                  : '暂无未读通知',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ListView.separated(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, controller, isMobile);
          },
        ),
      );
    });
  }

  Widget _buildNotificationCard(
    AppNotification notification,
    NotificationStateController controller,
    bool isMobile,
  ) {
    final color = Color(
      int.parse(notification.type.colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(FontAwesomeIcons.trash, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _controller.deleteNotification(notification.id);
        AppToast.info('通知已删除');
      },
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await _controller.markAsRead(notification.id);
          }

          // 导航到相关页面
          _handleNotificationTap(notification);
        },
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notification.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // 未读指示器
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 消息内容
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // 时间
                    Text(
                      timeago.format(notification.createdAt, locale: 'zh_CN'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.moderatorApplication:
        // 管理员：跳转到审核页面（待实现）
        // Get.toNamed('/admin/moderator-applications');
        AppToast.info('审核功能开发中');
        break;

      case NotificationType.moderatorApproved:
      case NotificationType.moderatorRejected:
        // 跳转到相关城市页面
        if (notification.relatedId != null) {
          Get.toNamed('/city/${notification.relatedId}');
        }
        break;

      case NotificationType.cityUpdate:
        if (notification.relatedId != null) {
          Get.toNamed('/city/${notification.relatedId}');
        }
        break;

      case NotificationType.systemAnnouncement:
        // 显示详情对话框
        _showAnnouncementDialog(notification);
        break;

      case NotificationType.other:
        break;
    }
  }

  void _showAnnouncementDialog(AppNotification notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
