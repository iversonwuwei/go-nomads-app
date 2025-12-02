import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/create_meetup_page.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/edit_button.dart';
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
import 'package:df_admin_mobile/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'direct_chat_page.dart';
import 'member_detail_page.dart';

/// Meetup 详情页面
class MeetupDetailPage extends StatefulWidget {
  final Meetup meetup;

  const MeetupDetailPage({
    super.key,
    required this.meetup,
  });

  @override
  State<MeetupDetailPage> createState() => _MeetupDetailPageState();
}

class _MeetupDetailPageState extends State<MeetupDetailPage> {
  late Rx<Meetup> _meetup;
  final IMeetupRepository _meetupRepository = Get.find();
  final _meetupController = Get.find<MeetupStateController>();
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _participants = <Map<String, dynamic>>[].obs;

  // 图片轮播相关
  final PageController _imagePageController = PageController();
  final RxInt _currentImageIndex = 0.obs;

  // 检查当前用户是否已加入活动 - 使用 controller 的 isRsvped 方法
  bool get _isJoined => _meetupController.isRsvped(_meetup.value.id);

  // 检查当前用户是否是活动组织者
  // 优先使用实体自带的 isOrganizer 字段(由后端根据 token 计算)
  bool get _isOrganizer {
    // 直接使用实体中的 isOrganizer 字段
    final result = _meetup.value.isOrganizer;

    print('🔍 组织者判断 - meetup.isOrganizer: $result');
    print('🔍 组织者判断 - 活动组织者ID: ${_meetup.value.organizer.id}');

    return result;
  }

  @override
  void initState() {
    super.initState();
    _meetup = widget.meetup.obs;
    // 异步加载详情,不阻塞页面显示
    Future.microtask(() => _loadEventDetails());
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  /// 从后端加载活动详情
  Future<void> _loadEventDetails() async {
    try {
      _isLoading.value = true;

      // 直接调用 API 获取原始响应，以便提取 participants 数据
      final httpService = Get.find<HttpService>();
      final response = await httpService.get('/events/${widget.meetup.id}');
      final data = response.data as Map<String, dynamic>;

      // 提取 participants 列表
      if (data['participants'] != null) {
        final participantsList = data['participants'] as List<dynamic>;
        _participants.value = participantsList.map((p) => p as Map<String, dynamic>).toList();
        print('✅ 成功加载 ${_participants.length} 位参与者');
      }

      // 映射为 Meetup 实体
      final dto = MeetupDto.fromJson(data);
      final meetup = dto.toDomain();

      _meetup.value = meetup;
      print('✅ 成功加载活动详情: ${meetup.title}');
    } catch (e) {
      print('❌ 加载活动详情失败: $e');
      AppToast.error('加载活动详情失败');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 顶部图片和AppBar
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: Colors.white,
            leading: const SliverBackButton(),
            actions: [
              // 编辑按钮 - 只有组织者可见
              if (_isOrganizer)
                SliverEditButton(
                  onPressed: () async {
                    final result = await Get.to(() => CreateMeetupPage(editingMeetup: _meetup.value));
                    if (result == true) {
                      // 编辑成功，刷新数据
                      await _loadEventDetails();
                    }
                  },
                  size: 18,
                ),
              SliverShareButton(onPressed: _shareMeetup),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Obx(() => _meetup.value.images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // 图片轮播
                        PageView.builder(
                          controller: _imagePageController,
                          itemCount: _meetup.value.images.length,
                          onPageChanged: (index) {
                            _currentImageIndex.value = index;
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              _meetup.value.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.borderLight,
                                  child: Icon(
                                    FontAwesomeIcons.imagePortrait,
                                    size: 64.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // 图片指示器 - 只有多张图片时显示
                        if (_meetup.value.images.length > 1)
                          Positioned(
                            bottom: 16.h,
                            left: 0,
                            right: 0,
                            child: Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _meetup.value.images.length,
                                    (index) => Container(
                                      width: _currentImageIndex.value == index ? 24.w : 8.w,
                                      height: 8.h,
                                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.r),
                                        color: _currentImageIndex.value == index
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        // 图片计数器
                        if (_meetup.value.images.length > 1)
                          Positioned(
                            top: 100.h,
                            right: 16.w,
                            child: Obx(() => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex.value + 1} / ${_meetup.value.images.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                          ),
                      ],
                    )
                  : Container(
                      color: AppColors.borderLight,
                      child: Icon(
                        FontAwesomeIcons.calendarDays,
                        size: 64.sp,
                        color: AppColors.textTertiary,
                      ),
                    )),
            ),
          ),

          // 内容区域
          SliverToBoxAdapter(
            child: Obx(() {
              // 显示加载指示器
              if (_isLoading.value) {
                return Container(
                  padding: EdgeInsets.all(40.w),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFF4458),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本信息
                  _buildBasicInfo(),

                  SizedBox(height: 16.h),

                  // 时间地点
                  _buildTimeLocationInfo(),

                  SizedBox(height: 16.h),

                  // 描述
                  _buildDescription(),

                  SizedBox(height: 16.h),

                  // 组织者信息
                  _buildOrganizerInfo(),

                  SizedBox(height: 16.h),

                  // 参与者列表
                  _buildAttendeesList(),

                  SizedBox(height: 100.h),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasicInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeChip(
                // 优先使用 eventType 的国际化名称
                _meetup.value.eventType?.getDisplayName(
                      Localizations.localeOf(context).languageCode,
                    ) ??
                    _meetup.value.type.value,
              ),
              SizedBox(width: 12.w),
              if (_meetup.value.isStartingSoon)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.clock, size: 12.sp, color: const Color(0xFFFF4458)),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.startingSoon,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF4458),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _meetup.value.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.city, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Text(
                '${_meetup.value.location.city}, ${_meetup.value.location.country}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLocationInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoRow(
            FontAwesomeIcons.calendar,
            l10n.dateAndTime,
            _formatDateTime(_meetup.value.schedule.startTime),
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            FontAwesomeIcons.locationDot,
            l10n.venue,
            _meetup.value.venue.name,
            subtitle: _meetup.value.venue.address,
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            FontAwesomeIcons.users,
            l10n.attendees,
            '${_meetup.value.capacity.currentAttendees} / ${_meetup.value.capacity.maxAttendees}',
            subtitle: _meetup.value.capacity.isFull
                ? l10n.meetupIsFull
                : l10n.spotsLeft('${_meetup.value.capacity.remainingSlots}'),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity, // 占据整个屏幕宽度
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.about,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _meetup.value.description,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.organizer,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 跳转到 Organizer 的个人详情页
                  final organizerUser = _createBasicUserModel(
                    _meetup.value.organizer.id,
                    _meetup.value.organizer.name,
                    _meetup.value.organizer.avatarUrl,
                  );
                  Get.to(() => MemberDetailPage(user: organizerUser));
                },
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundImage:
                      (_meetup.value.organizer.avatarUrl != null && _meetup.value.organizer.avatarUrl!.isNotEmpty)
                          ? NetworkImage(_meetup.value.organizer.avatarUrl!)
                          : null,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _meetup.value.organizer.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.eventOrganizer,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _contactOrganizer,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4458),
                  side: BorderSide(color: const Color(0xFFFF4458), width: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text(
                  l10n.message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesList() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.attendeesCount('${_meetup.value.capacity.currentAttendees}'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_meetup.value.capacity.currentAttendees > 0)
                TextButton(
                  onPressed: _showAllAttendees,
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFFFF4458),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (_participants.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    l10n.noAttendeesYet,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _participants.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  final userId = participant['userId']?.toString() ?? '';

                  // 从嵌套的 user 对象中获取头像
                  final userInfo = participant['user'] as Map<String, dynamic>?;
                  final userAvatar = userInfo?['avatar'] as String?;
                  final userName = userInfo?['name'] as String? ?? 'User';

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        // 跳转到参与者的个人详情页
                        final participantUser = _createBasicUserModel(
                          userId,
                          userName,
                          userAvatar ?? '',
                        );
                        Get.to(() => MemberDetailPage(user: participantUser));
                      },
                      child: Tooltip(
                        message: userName,
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundImage:
                              (userAvatar != null && userAvatar.isNotEmpty) ? NetworkImage(userAvatar) : null,
                          child: (userAvatar == null || userAvatar.isEmpty)
                              ? Icon(FontAwesomeIcons.user, size: 20.r)
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;

    // 添加调试输出
    print('🎨 构建底部按钮栏 - _isOrganizer: $_isOrganizer');
    print('🎨 构建底部按钮栏 - _isJoined: $_isJoined');
    print('🎨 构建底部按钮栏 - meetup status: ${_meetup.value.status}');

    return Obx(() => Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, -2.h),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 如果是组织者，显示取消活动按钮
                if (_isOrganizer) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _meetup.value.status == 'cancelled' || _meetup.value.isEnded ? null : _cancelMeetup,
                      icon: Icon(FontAwesomeIcons.ban, size: 20.sp),
                      label: Text(
                        _meetup.value.status == 'cancelled' ? '已取消' : '取消活动',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _meetup.value.status == 'cancelled' ? AppColors.borderLight : Colors.red,
                        foregroundColor: _meetup.value.status == 'cancelled' ? AppColors.textSecondary : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppColors.borderLight,
                      ),
                    ),
                  ),
                ]
                // 如果不是组织者，显示聊天和参与按钮
                else ...[
                  // Chat Button - 只有参与了才能点击
                  OutlinedButton.icon(
                    onPressed: _isJoined ? _openChat : null,
                    icon: Icon(FontAwesomeIcons.message, size: 20.sp),
                    label: Text(
                      l10n.chat,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isJoined ? Colors.blue : Colors.grey,
                      side: BorderSide(
                        color: _isJoined ? Colors.blue : Colors.grey.shade300,
                        width: 1.5.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      backgroundColor: _isJoined ? null : Colors.grey.shade50,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Join Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _meetup.value.isEnded || _meetup.value.capacity.isFull || _meetup.value.status == 'cancelled'
                              ? null
                              : _toggleJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isJoined ? AppColors.borderLight : const Color(0xFFFF4458),
                        foregroundColor: _isJoined ? AppColors.textSecondary : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppColors.borderLight,
                      ),
                      child: Text(
                        _meetup.value.status == 'cancelled'
                            ? '已取消'
                            : _meetup.value.isEnded
                                ? l10n.ended
                                : _meetup.value.capacity.isFull
                                    ? l10n.full
                                    : _isJoined
                                        ? l10n.leaveMeetup
                                        : l10n.joinMeetup,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildTypeChip(String type) {
    Color color;
    IconData icon;
    // 根据类型名称设置颜色和图标（支持中英文）
    final typeLower = type.toLowerCase();
    if (typeLower.contains('coffee') || typeLower.contains('咖啡')) {
      color = Colors.brown;
      icon = FontAwesomeIcons.mugSaucer;
    } else if (typeLower.contains('coworking') || typeLower.contains('共享办公')) {
      color = Colors.blue;
      icon = FontAwesomeIcons.laptop;
    } else if (typeLower.contains('activity') ||
        typeLower.contains('运动') ||
        typeLower.contains('sports') ||
        typeLower.contains('健身')) {
      color = Colors.green;
      icon = FontAwesomeIcons.football;
    } else if (typeLower.contains('language') || typeLower.contains('语言')) {
      color = Colors.purple;
      icon = FontAwesomeIcons.globe;
    } else if (typeLower.contains('social') ||
        typeLower.contains('社交') ||
        typeLower.contains('networking') ||
        typeLower.contains('网络')) {
      color = Colors.orange;
      icon = FontAwesomeIcons.userGroup;
    } else if (typeLower.contains('tech') ||
        typeLower.contains('workshop') ||
        typeLower.contains('技术') ||
        typeLower.contains('工作坊')) {
      color = Colors.indigo;
      icon = FontAwesomeIcons.code;
    } else if (typeLower.contains('food') || typeLower.contains('美食')) {
      color = Colors.red;
      icon = FontAwesomeIcons.utensils;
    } else {
      color = AppColors.textSecondary;
      icon = FontAwesomeIcons.calendarDays;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            type,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: const Color(0xFFFF4458)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleJoin() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // 判断是加入还是退出
      final isJoining = !_isJoined;

      // 调用 Repository
      if (isJoining) {
        await _meetupRepository.rsvpToMeetup(_meetup.value.id);
        print('✅ 成功加入活动: ${_meetup.value.title}');
        // 更新 Controller 的 rsvpedMeetupIds
        if (!_meetupController.rsvpedMeetupIds.contains(_meetup.value.id)) {
          _meetupController.rsvpedMeetupIds.add(_meetup.value.id);
        }
      } else {
        await _meetupRepository.cancelRsvp(_meetup.value.id);
        print('✅ 成功退出活动: ${_meetup.value.title}');
        // 更新 Controller 的 rsvpedMeetupIds
        _meetupController.rsvpedMeetupIds.remove(_meetup.value.id);
      }

      // API 调用成功后，重新加载活动详情以获取最新数据
      await _loadEventDetails();

      // 显示成功消息
      if (isJoining) {
        AppToast.success(
          l10n.joinedSuccessfully,
          title: l10n.joined,
        );
      } else {
        AppToast.info(
          l10n.youLeftMeetup,
          title: l10n.leftMeetup,
        );
      }
    } catch (e) {
      print('❌ 加入/退出活动失败: $e');
      AppToast.error(
        _isJoined ? '退出活动失败' : '加入活动失败',
      );
    }
  }

  Future<void> _cancelMeetup() async {
    final l10n = AppLocalizations.of(context)!;
    final meetupRepository = Get.find<IMeetupRepository>();

    // 显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消活动'),
        content: const Text('确定要取消这个活动吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await meetupRepository.cancelMeetup(_meetup.value.id);
      print('✅ 成功取消活动: ${_meetup.value.title}');

      // 显示成功消息
      AppToast.success(
        '活动已取消',
        title: '成功',
      );

      // 如果成功,重新加载活动详情以更新 UI
      await _loadEventDetails();
    } catch (e) {
      print('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败');
    }
  }

  void _openChat() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isJoined) {
      AppToast.warning(
        l10n.joinToAccessChat,
        title: l10n.joinRequired,
      );
      return;
    }

    // 跳转到群聊页面
    Get.toNamed(
      AppRoutes.cityChat,
      arguments: {
        'city': _meetup.value.title,
        'country': '${_meetup.value.type} ${l10n.meetup}',
        'meetupId': _meetup.value.id,
        'isMeetupChat': true,
      },
    );
  }

  void _shareMeetup() {
    final meetup = _meetup.value;

    // 格式化时间
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    final timeStr = dateFormat.format(meetup.schedule.startTime);

    // 构建分享内容
    final String title = '${meetup.title} - 数字游民聚会';
    final String description = '📅 时间: $timeStr\n'
        '📍 地点: ${meetup.venue.name}\n'
        '👥 组织者: ${meetup.organizer.name}\n\n'
        '${meetup.description}';

    // 构建分享链接
    final String shareUrl = 'https://nomadcities.app/meetups/${meetup.id}';

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      shareUrl: shareUrl,
    );
  }

  void _contactOrganizer() {
    // 创建组织者的 User 对象
    final organizerUser = User(
      id: _meetup.value.organizer.id,
      name: _meetup.value.organizer.name,
      username: _meetup.value.organizer.name.toLowerCase().replaceAll(' ', '_'),
      avatarUrl: _meetup.value.organizer.avatarUrl,
      stats: TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0.0,
      ),
      joinedDate: DateTime.now(),
    );

    // 跳转到一对一聊天页面
    Get.to(() => DirectChatPage(user: organizerUser));
  }

  void _showAllAttendees() {
    final l10n = AppLocalizations.of(context)!;
    Get.dialog(
      AlertDialog(
        title: Text(l10n.allAttendees, style: TextStyle(fontSize: 18.sp)),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (_participants.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    l10n.noAttendeesYet,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                final userId = participant['userId']?.toString() ?? '';

                // 🔧 从嵌套的 user 对象中获取用户信息
                final userInfo = participant['user'] as Map<String, dynamic>?;
                final userName = userInfo?['name'] as String? ?? '${l10n.user} ${index + 1}';
                final userEmail = userInfo?['email'] as String?;
                final userAvatar = userInfo?['avatar'] as String?;

                return ListTile(
                  onTap: () {
                    // 跳转到参与者的个人详情页
                    final participantUser = _createBasicUserModel(
                      userId,
                      userName,
                      userAvatar ?? '',
                    );
                    Get.back(); // 关闭对话框
                    Get.to(() => MemberDetailPage(user: participantUser));
                  },
                  leading: CircleAvatar(
                    backgroundImage: (userAvatar != null && userAvatar.isNotEmpty) ? NetworkImage(userAvatar) : null,
                    child: (userAvatar == null || userAvatar.isEmpty) ? const Icon(FontAwesomeIcons.user) : null,
                  ),
                  title: Text(userName, style: TextStyle(fontSize: 14.sp)),
                  subtitle: Text(
                    userEmail ?? l10n.digitalNomad,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.close, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy \'at\' HH:mm').format(dateTime);
  }

  /// 创建基本的 User 实体用于跳转到详情页
  User _createBasicUserModel(String id, String name, String? avatarUrl) {
    return User(
      id: id,
      name: name,
      username: name, // 使用 name 作为 username
      avatarUrl: avatarUrl,
      stats: TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0.0,
      ),
      joinedDate: DateTime.now(),
    );
  }
}
