import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../models/meetup_model.dart';
import '../models/user_model.dart';
import '../services/events_api_service.dart';
import '../widgets/app_toast.dart';
import 'direct_chat_page.dart';
import 'member_detail_page.dart';

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
  final EventsApiService _eventsApiService = EventsApiService();
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _participants =
      <Map<String, dynamic>>[].obs;

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

      // 调用 API 获取详情
      final response = await _eventsApiService.getEvent(widget.meetup.id);

      // 解析响应数据
      final eventData = response;

      // 更新 meetup 数据
      _meetup.value = _convertApiEventToMeetupModel(eventData);

      // 🔧 从 eventData 中提取参与者列表（后端已经通过 gRPC 填充了用户信息）
      // ParticipantResponse 包含: id, eventId, userId, status, registeredAt, user{id, name, email, avatar, phone}
      final participantsData = eventData['participants'] as List?;
      if (participantsData != null) {
        _participants.value =
            participantsData.map((p) => p as Map<String, dynamic>).toList();
        print('✅ 成功从活动详情中加载 ${_participants.length} 个参与者(包含用户信息)');
      } else {
        _participants.value = [];
        print('⚠️ 活动详情中无参与者数据');
      }

      print('✅ 成功加载活动详情: ${_meetup.value.title}');
    } catch (e) {
      print('❌ 加载活动详情失败: $e');
      AppToast.error('加载活动详情失败');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 将后端API的Event数据转换为MeetupModel
  MeetupModel _convertApiEventToMeetupModel(Map<String, dynamic> event) {
    // 解析城市信息
    final cityData = event['city'] as Map<String, dynamic>?;
    final cityName = cityData?['name'] as String? ?? '';
    final country = cityData?['country'] as String? ?? '';

    // 解析组织者信息
    final organizerData = event['organizer'] as Map<String, dynamic>?;
    final organizerName = organizerData?['name'] as String? ?? 'Unknown';
    final organizerId = organizerData?['id']?.toString() ??
        event['organizerId']?.toString() ??
        '0';

    // 获取 imageUrl（用于列表页的封面图）
    final imageUrl = event['imageUrl']?.toString();

    // 获取 images 数组（用于详情页的图片轮播）
    List<String> images = [];
    final imagesList = event['images'];
    if (imagesList is List) {
      images = imagesList
          .where((img) => img != null && img.toString().isNotEmpty)
          .map((img) => img.toString())
          .toList();
    }

    return MeetupModel(
      id: event['id']?.toString() ?? widget.meetup.id,
      title: event['title'] as String? ?? '',
      type: event['category'] as String? ?? 'Meetup',
      description: event['description'] as String? ?? '',
      city: cityName,
      country: country,
      venue: event['location'] as String? ?? '',
      venueAddress: event['address'] as String? ?? '',
      dateTime: DateTime.parse(
          event['startTime'] as String? ?? DateTime.now().toIso8601String()),
      maxAttendees: event['maxParticipants'] as int? ?? 20,
      currentAttendees: event['participantCount'] as int? ?? 0,
      organizerId: organizerId,
      organizerName: organizerName,
      organizerAvatar: 'https://i.pravatar.cc/150?u=$organizerId',
      imageUrl: imageUrl,
      images: images,
      attendeeIds: [],
      isJoined: event['isParticipant'] as bool? ?? false,
      createdAt: DateTime.parse(
          event['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            l10n.dateAndTime,
            _formatDateTime(_meetup.value.dateTime),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.location_on,
            l10n.venue,
            _meetup.value.venue,
            subtitle: _meetup.value.venueAddress,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.people,
            l10n.attendees,
            '${_meetup.value.currentAttendees} / ${_meetup.value.maxAttendees}',
            subtitle: _meetup.value.isFull
                ? l10n.meetupIsFull
                : l10n.spotsLeft('${_meetup.value.remainingSlots}'),
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
                    _meetup.value.organizerId,
                    _meetup.value.organizerName,
                    _meetup.value.organizerAvatar,
                  );
                  Get.to(() => MemberDetailPage(user: organizerUser));
                },
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage(_meetup.value.organizerAvatar),
                ),
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
                l10n.attendeesCount('${_meetup.value.currentAttendees}'),
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
                // Chat Button - 只有参与了才能点击
                OutlinedButton.icon(
                  onPressed: _meetup.value.isJoined ? _openChat : null,
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
                          ? l10n.ended
                          : _meetup.value.isFull
                              ? l10n.full
                              : _meetup.value.isJoined
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
      final isJoining = !_meetup.value.isJoined;

      // 调用 API
      if (isJoining) {
        await _eventsApiService.joinEvent(_meetup.value.id);
        print('✅ 成功加入活动: ${_meetup.value.title}');
      } else {
        await _eventsApiService.leaveEvent(_meetup.value.id);
        print('✅ 成功退出活动: ${_meetup.value.title}');
      }

      // API 调用成功后,重新加载活动详情以获取最新数据
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
        _meetup.value.isJoined ? '退出活动失败' : '加入活动失败',
      );
    }
  }

  void _openChat() {
    final l10n = AppLocalizations.of(context)!;
    if (!_meetup.value.isJoined) {
      AppToast.warning(
        l10n.joinToAccessChat,
        title: l10n.joinRequired,
      );
      return;
    }

    // 跳转到群聊页面
    Get.toNamed(
      '/city-chat',
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
    // 创建组织者的 UserModel 对象
    final organizerUser = UserModel(
      id: _meetup.value.organizerId,
      name: _meetup.value.organizerName,
      username: _meetup.value.organizerName.toLowerCase().replaceAll(' ', '_'),
      avatarUrl: _meetup.value.organizerAvatar,
      stats: TravelStats(
        countriesVisited: 0,
        citiesLived: 0,
        daysNomading: 0,
        meetupsAttended: 0,
        tripsCompleted: 0,
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
                final userName =
                    userInfo?['name'] as String? ?? '${l10n.user} ${index + 1}';
                final userEmail = userInfo?['email'] as String?;
                final userAvatar = userInfo?['avatar'] as String?;

                return ListTile(
                  onTap: () {
                    // 跳转到参与者的个人详情页
                    final participantUser = _createBasicUserModel(
                      userId,
                      userName,
                      userAvatar ?? 'https://i.pravatar.cc/150?u=$userId',
                    );
                    Get.back(); // 关闭对话框
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

  /// 创建基本的 UserModel 用于跳转到详情页
  UserModel _createBasicUserModel(String id, String name, String avatarUrl) {
    return UserModel(
      id: id,
      name: name,
      username: name, // 使用 name 作为 username
      avatarUrl: avatarUrl,
      stats: TravelStats(
        countriesVisited: 0,
        citiesLived: 0,
        daysNomading: 0,
        meetupsAttended: 0,
        tripsCompleted: 0,
      ),
      joinedDate: DateTime.now(),
    );
  }
}
