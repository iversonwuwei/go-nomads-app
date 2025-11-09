import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../features/meetup/domain/entities/meetup.dart';
import '../features/meetup/domain/repositories/i_meetup_repository.dart';
import '../features/user/domain/entities/user.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
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
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _participants =
      <Map<String, dynamic>>[].obs;

  // TODO: 需要从认证服务获取当前用户ID
  String get _currentUserId => 'TODO_CURRENT_USER_ID';

  // 检查当前用户是否已加入活动
  bool get _isJoined => _meetup.value.attendeeIds.contains(_currentUserId);

  @override
  void initState() {
    super.initState();
    _meetup = widget.meetup.obs;
    _loadEventDetails();
  }

  /// 从后端加载活动详情
  Future<void> _loadEventDetails() async {
    try {
      _isLoading.value = true;

      // 调用 Repository 获取详情
      final meetup = await _meetupRepository.getMeetupById(widget.meetup.id);
      
      if (meetup != null) {
        _meetup.value = meetup;
        print('✅ 成功加载活动详情: ${meetup.title}');
      } else {
        print('⚠️ 未找到活动详情');
        AppToast.error('未找到活动信息');
      }
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
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share, color: Colors.white, size: 20.sp),
                ),
                onPressed: _shareMeetup,
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _meetup.value.images.isNotEmpty
                  ? Image.network(
                      _meetup.value.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.borderLight,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64.sp,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.borderLight,
                      child: Icon(
                        Icons.event,
                        size: 64.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
          ),

          // 内容区域
          SliverToBoxAdapter(
            child: Obx(() {
              // 显示加载指示�?
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

                  // 组织者信�?
                  _buildOrganizerInfo(),

                  SizedBox(height: 16.h),

                  // 参与者列�?
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
              _buildTypeChip(_meetup.value.type.value),
              SizedBox(width: 12.w),
              if (_meetup.value.isStartingSoon)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          size: 12.sp, color: const Color(0xFFFF4458)),
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
              Icon(Icons.location_city,
                  size: 16.sp, color: AppColors.textSecondary),
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
            Icons.calendar_today,
            l10n.dateAndTime,
            _formatDateTime(_meetup.value.schedule.startTime),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.location_on,
            l10n.venue,
            _meetup.value.venue.name,
            subtitle: _meetup.value.venue.address,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.people,
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
                      NetworkImage(_meetup.value.organizer.avatarUrl ?? ''),
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
                  side:
                      BorderSide(color: const Color(0xFFFF4458), width: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                l10n.attendeesCount(
                    '${_meetup.value.capacity.currentAttendees}'),
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

                  // 从嵌套的 user 对象中获取头�?
                  final userInfo = participant['user'] as Map<String, dynamic>?;
                  final userAvatar = userInfo?['avatar'] as String?;
                  final userName = userInfo?['name'] as String? ?? 'User';

                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        // 跳转到参与者的个人详情�?
                        final participantUser = _createBasicUserModel(
                          userId,
                          userName,
                          userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',
                        );
                        Get.to(() => MemberDetailPage(user: participantUser));
                      },
                      child: Tooltip(
                        message: userName,
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundImage: NetworkImage(
                            userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',
                          ),
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
                // Chat Button - 只有参与了才能点�?
                OutlinedButton.icon(
                  onPressed: _isJoined ? _openChat : null,
                  icon: Icon(Icons.chat_bubble_outline, size: 20.sp),
                  label: Text(
                    l10n.chat,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _isJoined ? Colors.blue : Colors.grey,
                    side: BorderSide(
                      color: _isJoined
                          ? Colors.blue
                          : Colors.grey.shade300,
                      width: 1.5.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    backgroundColor:
                        _isJoined ? null : Colors.grey.shade50,
                  ),
                ),
                SizedBox(width: 12.w),
                // Join Button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _meetup.value.isEnded || _meetup.value.capacity.isFull
                        ? null
                        : _toggleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isJoined
                          ? AppColors.borderLight
                          : const Color(0xFFFF4458),
                      foregroundColor:
                          _isJoined
                          ? AppColors.textSecondary
                          : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.borderLight,
                    ),
                    child: Text(
                      _meetup.value.isEnded
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
            ),
          ),
        ));
  }

  Widget _buildTypeChip(String type) {
    Color color;
    IconData icon;
    switch (type.toLowerCase()) {
      case 'coffee':
        color = Colors.brown;
        icon = Icons.local_cafe;
        break;
      case 'coworking':
        color = Colors.blue;
        icon = Icons.laptop;
        break;
      case 'activity':
        color = Colors.green;
        icon = Icons.sports;
        break;
      case 'language':
        color = Colors.purple;
        icon = Icons.language;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.event;
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

  Widget _buildInfoRow(IconData icon, String title, String value,
      {String? subtitle}) {
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
      } else {
        await _meetupRepository.cancelRsvp(_meetup.value.id);
        print('✅ 成功退出活动: ${_meetup.value.title}');
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

  void _openChat() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isJoined) {
      AppToast.warning(
        l10n.joinToAccessChat,
        title: l10n.joinRequired,
      );
      return;
    }

    // 跳转到群聊页�?
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
    final l10n = AppLocalizations.of(context)!;
    AppToast.info(l10n.shareMeetupComingSoon, title: l10n.share);
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

                // 🔧 从嵌套的 user 对象中获取用户信�?
                final userInfo = participant['user'] as Map<String, dynamic>?;
                final userName =
                    userInfo?['name'] as String? ?? '${l10n.user} ${index + 1}';
                final userEmail = userInfo?['email'] as String?;
                final userAvatar = userInfo?['avatar'] as String?;

                return ListTile(
                  onTap: () {
                    // 跳转到参与者的个人详情�?
                    final participantUser = _createBasicUserModel(
                      userId,
                      userName,
                      userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',
                    );
                    Get.back(); // 关闭对话�?
                    Get.to(() => MemberDetailPage(user: participantUser));
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',
                    ),
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
