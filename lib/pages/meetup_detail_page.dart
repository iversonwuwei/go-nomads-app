import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../models/meetup_model.dart';

/// Meetup 详情页面
class MeetupDetailPage extends StatefulWidget {
  final MeetupModel meetup;

  const MeetupDetailPage({
    super.key,
    required this.meetup,
  });

  @override
  State<MeetupDetailPage> createState() => _MeetupDetailPageState();
}

class _MeetupDetailPageState extends State<MeetupDetailPage> {
  late Rx<MeetupModel> _meetup;

  @override
  void initState() {
    super.initState();
    _meetup = widget.meetup.obs;
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
            child: Column(
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeChip(_meetup.value.type),
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
                        'Starting Soon',
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
                '${_meetup.value.city}, ${_meetup.value.country}',
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
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Date & Time',
            _formatDateTime(_meetup.value.dateTime),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.location_on,
            'Venue',
            _meetup.value.venue,
            subtitle: _meetup.value.venueAddress,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.people,
            'Attendees',
            '${_meetup.value.currentAttendees} / ${_meetup.value.maxAttendees}',
            subtitle: _meetup.value.isFull
                ? 'This meetup is full'
                : '${_meetup.value.remainingSlots} spots left',
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
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
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organizer',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: NetworkImage(_meetup.value.organizerAvatar),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _meetup.value.organizerName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Event Organizer',
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
                  'Message',
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
                'Attendees (${_meetup.value.currentAttendees})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_meetup.value.currentAttendees > 0)
                TextButton(
                  onPressed: _showAllAttendees,
                  child: Text(
                    'View All',
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
          if (_meetup.value.currentAttendees == 0)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  'No attendees yet. Be the first to join!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _meetup.value.currentAttendees.clamp(0, 10),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=${index + 10}',
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
                // Chat Button - 只有参与了才能点击
                OutlinedButton.icon(
                  onPressed: _meetup.value.isJoined ? _openChat : null,
                  icon: Icon(Icons.chat_bubble_outline, size: 20.sp),
                  label: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _meetup.value.isJoined ? Colors.blue : Colors.grey,
                    side: BorderSide(
                      color: _meetup.value.isJoined
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
                        _meetup.value.isJoined ? null : Colors.grey.shade50,
                  ),
                ),
                SizedBox(width: 12.w),
                // Join Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _meetup.value.isEnded || _meetup.value.isFull
                        ? null
                        : _toggleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _meetup.value.isJoined
                          ? AppColors.borderLight
                          : const Color(0xFFFF4458),
                      foregroundColor: _meetup.value.isJoined
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
                          ? 'Ended'
                          : _meetup.value.isFull
                              ? 'Full'
                              : _meetup.value.isJoined
                                  ? 'Leave Meetup'
                                  : 'Join Meetup',
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

  void _toggleJoin() {
    final updated = _meetup.value.copyWith(
      isJoined: !_meetup.value.isJoined,
      currentAttendees:
          _meetup.value.currentAttendees + (_meetup.value.isJoined ? -1 : 1),
    );
    _meetup.value = updated;

    Get.snackbar(
      updated.isJoined ? '✅ Joined!' : '👋 Left meetup',
      updated.isJoined
          ? 'You have successfully joined this meetup'
          : 'You left this meetup',
      backgroundColor:
          updated.isJoined ? Colors.green : AppColors.textSecondary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _openChat() {
    if (!_meetup.value.isJoined) {
      Get.snackbar(
        '⚠️ Join Required',
        'You need to join this meetup before you can access the group chat',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // 跳转到群聊页面
    Get.toNamed(
      '/city-chat',
      arguments: {
        'city': _meetup.value.title,
        'country': '${_meetup.value.type} Meetup',
        'meetupId': _meetup.value.id,
        'isMeetupChat': true,
      },
    );
  }

  void _shareMeetup() {
    Get.snackbar(
      '🔗 Share',
      'Share meetup functionality coming soon!',
      backgroundColor: AppColors.textSecondary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _contactOrganizer() {
    Get.snackbar(
      '💬 Message',
      'Opening chat with ${_meetup.value.organizerName}...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAllAttendees() {
    Get.dialog(
      AlertDialog(
        title: Text('All Attendees', style: TextStyle(fontSize: 18.sp)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _meetup.value.currentAttendees,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=${index + 10}',
                  ),
                ),
                title: Text('User ${index + 1}',
                    style: TextStyle(fontSize: 14.sp)),
                subtitle:
                    Text('Digital Nomad', style: TextStyle(fontSize: 12.sp)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy \'at\' HH:mm').format(dateTime);
  }
}
