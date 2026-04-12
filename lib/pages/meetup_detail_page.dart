import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/utils/share_link_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';
import 'package:intl/intl.dart';

import 'member_detail_page.dart';
import 'tencent_im_direct_chat_page.dart';

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
  final _meetupController = Get.find<MeetupStateController>();
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _participants = <Map<String, dynamic>>[].obs;

  // 数据变更标记 - 用于返回时通知列表页面更新缓存
  bool _hasDataChanged = false;

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

    log('🔍 组织者判断 - meetup.isOrganizer: $result');
    log('🔍 组织者判断 - 活动组织者ID: ${_meetup.value.organizer.id}');

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
    final l10n = AppLocalizations.of(context)!;
    try {
      _isLoading.value = true;

      // 直接调用 API 获取原始响应，以便提取 participants 数据
      final httpService = Get.find<HttpService>();
      final response = await httpService.get('/events/${widget.meetup.id}');
      final data = response.data as Map<String, dynamic>;

      // 提取 participants 列表（直接使用后端返回的数据，不做过滤）
      if (data['participants'] != null) {
        final participantsList = data['participants'] as List<dynamic>;
        _participants.value = participantsList.map((p) => p as Map<String, dynamic>).toList();
        log('✅ 成功加载 ${_participants.length} 位参与者');
      }

      // 映射为 Meetup 实体
      final dto = MeetupDto.fromJson(data);
      final meetup = dto.toDomain();

      // 调试：打印解析后的数据
      log('🔍 解析后 - capacity.currentAttendees: ${meetup.capacity.currentAttendees}');

      // 先触发刷新，确保 Obx 重新构建
      _meetup.value = meetup;
      _meetup.refresh(); // 强制触发更新
      log('✅ 成功加载活动详情: ${meetup.title}, 参与者: ${meetup.capacity.currentAttendees}');
    } catch (e) {
      log('❌ 加载活动详情失败: $e');
      AppToast.error(l10n.loadFailed);
    } finally {
      _isLoading.value = false;
    }
  }

  /// 统一处理返回逻辑
  void _handleBack() {
    NavigationUtil.backFromDetail<Meetup>(
      entity: _meetup.value,
      hasChanged: _hasDataChanged,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.h,
              pinned: true,
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: SliverBackButton(
                onPressed: _handleBack,
              ),
              actions: [
                // 编辑按钮 - 只有组织者可见
                if (_isOrganizer)
                  SliverEditButton(
                    onPressed: () async {
                      await NavigationUtil.toWithCallback<Meetup>(
                        page: () => CreateMeetupPage(editingMeetup: _meetup.value),
                        onResult: (result) async {
                          if (result.needsRefresh) {
                            // 编辑成功，刷新数据并标记变更
                            await _loadEventDetails();
                            _hasDataChanged = true;
                          }
                        },
                      );
                    },
                    size: 18.r,
                  ),
                SliverShareButton(onPressed: _shareMeetup),
                SizedBox(width: 8.w),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Obx(() => Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_meetup.value.images.isNotEmpty)
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
                                    color: AppColors.backgroundSecondary,
                                    child: Icon(
                                      FontAwesomeIcons.imagePortrait,
                                      size: 64.sp,
                                      color: AppColors.textTertiary,
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        else
                          Container(
                            color: AppColors.backgroundSecondary,
                            child: Icon(
                              FontAwesomeIcons.calendarDays,
                              size: 64.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.04),
                                Colors.black.withValues(alpha: 0.12),
                                const Color(0xFF15212B).withValues(alpha: 0.78),
                              ],
                            ),
                          ),
                        ),
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
                        if (_meetup.value.images.length > 1)
                          Positioned(
                            top: 100.h,
                            right: 16.w,
                            child: Obx(() => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex.value + 1} / ${_meetup.value.images.length}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                          ),
                        Positioned(
                          left: 20.w,
                          right: 20.w,
                          bottom: 34.h,
                          child: _buildHeroOverlay(),
                        ),
                      ],
                    )),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                final currentAttendees = _meetup.value.capacity.currentAttendees;
                log('🔄 Obx 重建 - currentAttendees: $currentAttendees');

                if (_isLoading.value) {
                  return Container(
                    padding: EdgeInsets.all(40.w),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cityPrimary,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: Offset(0, -40.h),
                            child: _buildHeroStatusCard(),
                          ),
                          SizedBox(height: 8.h),
                          _buildSectionShell(
                            eyebrow: 'Live pulse',
                            title: 'How this meetup is shaping up',
                            child: _buildMeetupSignalBoard(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionShell(
                            eyebrow: 'Event brief',
                            title: 'Why this session matters',
                            child: _buildBasicInfo(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionShell(
                            eyebrow: 'Plan the arrival',
                            title: 'Time and venue',
                            child: _buildTimeLocationInfo(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionShell(
                            eyebrow: 'About the room',
                            title: 'Session context',
                            child: _buildDescription(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionShell(
                            eyebrow: 'Host layer',
                            title: 'Organizer and trust',
                            child: _buildOrganizerInfo(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSectionShell(
                            eyebrow: 'Social proof',
                            title: 'Who is already in',
                            child: _buildAttendeesList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBasicInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _buildTypeChip(
              _meetup.value.eventType?.getDisplayName(
                    Localizations.localeOf(context).languageCode,
                  ) ??
                  _meetup.value.type.value,
            ),
            if (_meetup.value.isStartingSoon)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.cityPrimary.withValues(alpha: 0.16)),
                ),
                child: Text(
                  l10n.startingSoon,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cityPrimary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          _meetup.value.description,
          style: TextStyle(
            fontSize: 15.sp,
            height: 1.65,
            color: AppColors.textSecondary,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTimeLocationInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
    );
  }

  Widget _buildDescription() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
    );
  }

  Widget _buildOrganizerInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
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
                final organizerUser = _createBasicUserModel(
                  _meetup.value.organizer.id,
                  _meetup.value.organizer.name,
                  _meetup.value.organizer.avatarUrl,
                );
                Get.to(() => MemberDetailPage(user: organizerUser));
              },
              child: SafeCircleAvatar(
                imageUrl: _meetup.value.organizer.avatarUrl,
                radius: 30.r,
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
            if (!_isOrganizer)
              OutlinedButton(
                onPressed: _contactOrganizer,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cityPrimary,
                  backgroundColor: AppColors.cityPrimaryLight,
                  side: BorderSide(color: AppColors.cityPrimary.withValues(alpha: 0.18), width: 1.2),
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
    );
  }

  Widget _buildAttendeesList() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final attendeesCount = _meetup.value.capacity.currentAttendees;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.attendeesCount('$attendeesCount'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (attendeesCount > 0)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.cityPrimary,
                    backgroundColor: AppColors.cityPrimaryLight,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: _showAllAttendees,
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 16.h),
        Obx(() {
          if (_participants.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Text(
                  l10n.noAttendeesYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: SizedBox(
              height: 44.h,
              child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _participants.length.clamp(0, 10),
              itemBuilder: (context, index) {
                final participant = _participants[index];
                final userId = participant['userId']?.toString() ?? '';
                final userInfo = participant['user'] as Map<String, dynamic>?;
                final userAvatar = userInfo?['avatar'] as String?;
                final userName = userInfo?['name'] as String? ?? 'User';

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () {
                      final participantUser = _createBasicUserModel(
                        userId,
                        userName,
                        userAvatar ?? '',
                      );
                      Get.to(() => MemberDetailPage(user: participantUser));
                    },
                    child: Tooltip(
                      message: userName,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                          color: AppColors.surfaceElevated,
                        ),
                        child: SafeCircleAvatar(
                          imageUrl: userAvatar,
                          radius: 20.r,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeroOverlay() {
    final eventTypeLabel = _meetup.value.eventType?.getDisplayName(
          Localizations.localeOf(context).languageCode,
        ) ??
        _meetup.value.type.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildHeroPill(FontAwesomeIcons.userGroup, eventTypeLabel),
            _buildHeroPill(
              FontAwesomeIcons.clock,
              _meetup.value.isStartingSoon
                  ? AppLocalizations.of(context)!.startingSoon
                  : (_meetup.value.isOngoing ? 'Live now' : 'Upcoming'),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          _meetup.value.title,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.08,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(FontAwesomeIcons.locationDot, size: 12.r, color: Colors.white70),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${_meetup.value.location.city}, ${_meetup.value.location.country}',
                style: TextStyle(fontSize: 13.sp, color: Colors.white70),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.heroCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meetup profile',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.cityPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _meetup.value.isJoined ? 'You are already in' : 'Decision snapshot',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatDateTime(_meetup.value.schedule.startTime),
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _meetup.value.capacity.remainingSlots.toString(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'spots left',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  label: 'Attendees',
                  value: _meetup.value.capacity.currentAttendees.toString(),
                  hint: 'people confirmed',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildSummaryMetric(
                  label: 'Fill rate',
                  value: '${(_meetup.value.participationRate * 100).round()}%',
                  hint: _meetup.value.isNearlyFull ? 'close to full' : 'room to join',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildSummaryMetric(
                  label: 'Host mode',
                  value: _isOrganizer ? 'You' : 'Host',
                  hint: _meetup.value.organizer.name,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupSignalBoard() {
    final signals = [
      _buildSignalTile(
        label: 'Status',
        value: _meetup.value.isOngoing ? 'Live' : (_meetup.value.isEnded ? 'Ended' : 'Upcoming'),
        detail: _meetup.value.status.value,
        icon: FontAwesomeIcons.signal,
        accent: const Color(0xFF276A88),
      ),
      _buildSignalTile(
        label: 'Capacity',
        value: '${_meetup.value.capacity.currentAttendees}/${_meetup.value.capacity.maxAttendees}',
        detail: _meetup.value.capacity.isFull ? 'No seats left' : '${_meetup.value.capacity.remainingSlots} still open',
        icon: FontAwesomeIcons.users,
        accent: const Color(0xFF855129),
      ),
      _buildSignalTile(
        label: 'Timing',
        value: _meetup.value.isStartingSoon ? 'Soon' : (_meetup.value.isUpcoming ? 'Planned' : 'Past'),
        detail: _meetup.value.durationInHours != null
            ? '${_meetup.value.durationInHours!.toStringAsFixed(1)} hour session'
            : 'Duration not specified',
        icon: FontAwesomeIcons.clock,
        accent: const Color(0xFF3E7B59),
      ),
      _buildSignalTile(
        label: 'Access',
        value: _isJoined ? 'Joined' : (_meetup.value.canJoin ? 'Can join' : 'Restricted'),
        detail: _isOrganizer ? 'Organizer controls active' : 'Chat unlocks after joining',
        icon: FontAwesomeIcons.doorOpen,
        accent: const Color(0xFF6F3D78),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: signals.map((tile) => SizedBox(width: width, child: tile)).toList(),
        );
      },
    );
  }

  Widget _buildSectionShell({required String eyebrow, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.cityPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildHeroPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSignalTile({
    required String label,
    required String value,
    required String detail,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 16.r, color: accent),
          ),
          SizedBox(height: 14.h),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: accent)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 6.h),
          Text(detail, style: TextStyle(fontSize: 12.sp, height: 1.45, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({required String label, required String value, required String hint}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.cityPrimary)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text(hint, style: TextStyle(fontSize: 11.sp, height: 1.35, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;

    // 添加调试输出
    log('🎨 构建底部按钮栏 - _isOrganizer: $_isOrganizer');
    log('🎨 构建底部按钮栏 - _isJoined: $_isJoined');
    log('🎨 构建底部按钮栏 - meetup status: ${_meetup.value.status}');

    return Obx(() => Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
            boxShadow: AppUiTokens.softTopSheetShadow,
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 如果是组织者，显示聊天按钮 + 取消活动按钮
                if (_isOrganizer) ...[
                  // Chat Button - 组织者始终可用
                  OutlinedButton.icon(
                    onPressed: _openChat,
                    icon: Icon(FontAwesomeIcons.message, size: 20.sp),
                    label: Text(
                      l10n.chat,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // 取消活动按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _meetup.value.status == MeetupStatus.cancelled || _meetup.value.isEnded
                          ? null
                          : _cancelMeetup,
                      icon: Icon(FontAwesomeIcons.ban, size: 20.sp),
                      label: Text(
                        _meetup.value.status == MeetupStatus.cancelled ? l10n.cancelled : l10n.cancelMeetup,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                          _meetup.value.status == MeetupStatus.cancelled ? AppColors.borderLight : AppColors.feedbackError,
                        foregroundColor:
                            _meetup.value.status == MeetupStatus.cancelled ? AppColors.textSecondary : Colors.white,
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
                      foregroundColor: _isJoined ? AppColors.textPrimary : AppColors.textTertiary,
                      side: BorderSide(
                        color: _isJoined ? AppColors.border : AppColors.borderLight,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      backgroundColor: _isJoined ? AppColors.surfaceElevated : AppColors.surfaceDisabled,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Join Button - 使用后端返回的 capacity.isFull 判断
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _meetup.value.isEnded ||
                              (_meetup.value.capacity.isFull && !_isJoined) ||
                              _meetup.value.status == MeetupStatus.cancelled
                          ? null
                          : _toggleJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isJoined ? AppColors.borderLight : AppColors.cityPrimary,
                        foregroundColor: _isJoined ? AppColors.textSecondary : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppColors.borderLight,
                      ),
                      child: Text(
                        _meetup.value.status == MeetupStatus.cancelled
                            ? l10n.cancelled
                            : _meetup.value.isEnded
                                ? l10n.ended
                                : (_meetup.value.capacity.isFull && !_isJoined)
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
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
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
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.cityPrimary),
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
      ),
    );
  }

  Future<void> _toggleJoin() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // 判断是加入还是退出
      final isJoining = !_isJoined;

      // 使用 MeetupStateController 的方法，已实现单点更新列表
      bool success;
      if (isJoining) {
        success = await _meetupController.rsvpToMeetup(_meetup.value.id);
        log('✅ 成功加入活动: ${_meetup.value.title}');
      } else {
        success = await _meetupController.cancelRsvp(_meetup.value.id);
        log('✅ 成功退出活动: ${_meetup.value.title}');
      }

      if (success) {
        // 本地单点更新详情页数据，而不是重新加载整个详情
        final currentMeetup = _meetup.value;
        final newCount = isJoining
            ? currentMeetup.capacity.currentAttendees + 1
            : (currentMeetup.capacity.currentAttendees - 1).clamp(0, currentMeetup.capacity.maxAttendees);
        final newCapacity = Capacity(
          maxAttendees: currentMeetup.capacity.maxAttendees,
          currentAttendees: newCount,
        );

        // 创建新的 Meetup 对象，只更新参与人数和加入状态
        _meetup.value = Meetup(
          id: currentMeetup.id,
          title: currentMeetup.title,
          type: currentMeetup.type,
          eventType: currentMeetup.eventType,
          description: currentMeetup.description,
          location: currentMeetup.location,
          venue: currentMeetup.venue,
          schedule: currentMeetup.schedule,
          capacity: newCapacity,
          organizer: currentMeetup.organizer,
          images: currentMeetup.images,
          attendeeIds: currentMeetup.attendeeIds,
          status: currentMeetup.status,
          createdAt: currentMeetup.createdAt,
          isJoined: isJoining,
          isOrganizer: currentMeetup.isOrganizer,
        );

        // 本地更新参与者列表
        if (isJoining) {
          // 获取当前用户信息并添加到参与者列表
          final authController = Get.find<AuthStateController>();
          final currentUser = authController.currentUser.value;
          if (currentUser != null) {
            _participants.add({
              'userId': currentUser.id,
              'user': {
                'name': currentUser.name,
                'avatar': currentUser.avatar,
                'email': currentUser.email,
              },
            });
          }
        } else {
          // 从参与者列表移除当前用户
          final authController = Get.find<AuthStateController>();
          final currentUserId = authController.currentUser.value?.id;
          if (currentUserId != null) {
            _participants.removeWhere(
              (p) => p['id'] == currentUserId || p['userId'] == currentUserId,
            );
          }
        }

        // 强制刷新 UI
        _meetup.refresh();

        // 打印更新后的数据用于调试
        log('📊 更新后数据 - currentAttendees: ${_meetup.value.capacity.currentAttendees}, participants: ${_participants.length}');

        // 标记数据已变更，返回时通知列表页面更新缓存
        _hasDataChanged = true;
        // 无需调用 refreshMeetups()，rsvpToMeetup/cancelRsvp 已经单点更新了列表
      }
    } catch (e) {
      log('❌ 加入/退出活动失败: $e');
      AppToast.error(
        _isJoined ? l10n.leaveMeetupFailed : l10n.dataServiceJoinMeetupFailed,
      );
    }
  }

  Future<void> _cancelMeetup() async {
    final l10n = AppLocalizations.of(context)!;
    final meetupRepository = Get.find<IMeetupRepository>();

    // 显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(l10n.confirmCancelMeetupTitle),
        content: Text(l10n.confirmCancelMeetupMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.feedbackError,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await meetupRepository.cancelMeetup(_meetup.value.id);
      log('✅ 成功取消活动: ${_meetup.value.title}');

      // 显示成功消息
      AppToast.success(
        l10n.cancelMeetupSuccess,
        title: l10n.success,
      );

      // 本地单点更新状态，而不是重新加载整个详情
      final currentMeetup = _meetup.value;
      _meetup.value = Meetup(
        id: currentMeetup.id,
        title: currentMeetup.title,
        type: currentMeetup.type,
        eventType: currentMeetup.eventType,
        description: currentMeetup.description,
        location: currentMeetup.location,
        venue: currentMeetup.venue,
        schedule: currentMeetup.schedule,
        capacity: currentMeetup.capacity,
        organizer: currentMeetup.organizer,
        images: currentMeetup.images,
        attendeeIds: currentMeetup.attendeeIds,
        status: MeetupStatus.cancelled,
        createdAt: currentMeetup.createdAt,
        isJoined: currentMeetup.isJoined,
        isOrganizer: currentMeetup.isOrganizer,
      );
      _meetup.refresh();
      log('📊 更新后状态 - status: ${_meetup.value.status.value}');

      // 标记数据已变更，返回时通知列表页面更新缓存
      _hasDataChanged = true;
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error(l10n.cancelMeetupFailed);
    }
  }

  void _openChat() {
    final l10n = AppLocalizations.of(context)!;
    // 组织者或已加入的成员都可以访问聊天室
    if (!_isJoined && !_isOrganizer) {
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
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final timeStr = dateFormat.format(meetup.schedule.startTime);

    // 构建分享内容
    final l10n = AppLocalizations.of(context)!;
    final String title = l10n.nomadMeetupShare(meetup.title);
    final String description = '${l10n.shareTime(timeStr)}\n'
        '${l10n.shareVenue(meetup.venue.name)}\n'
        '${l10n.shareOrganizer(meetup.organizer.name)}\n\n'
        '${meetup.description}';

    // 构建分享链接
    final String shareUrl = ShareLinkUtil.meetupDetail(meetup.id);

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
    Get.to(() => TencentIMDirectChatPage(user: organizerUser));
  }

  void _showAllAttendees() {
    final l10n = AppLocalizations.of(context)!;
    Get.bottomSheet(
      AppBottomDrawer(
        title: l10n.allAttendees,
        maxHeightFactor: 0.72,
        footer: AppBottomDrawerActionRow(
          primaryLabel: l10n.close,
          onPrimaryPressed: () => Get.back<void>(),
          secondaryLabel: l10n.close,
          onSecondaryPressed: null,
          secondaryEnabled: false,
        ),
          child: Obx(() {
            if (_participants.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      l10n.noAttendeesYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
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
                final userId = participant['userId']?.toString() ?? participant['id']?.toString() ?? '';

                final userInfo = participant['user'] as Map<String, dynamic>?;
                final userName =
                  userInfo?['name'] as String? ?? participant['name'] as String? ?? '${l10n.user} ${index + 1}';
                final userEmail = userInfo?['email'] as String? ?? participant['email'] as String?;
                final userAvatar = userInfo?['avatar'] as String? ?? participant['avatarUrl'] as String?;

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                  onTap: () {
                    final participantUser = _createBasicUserModel(
                      userId,
                      userName,
                      userAvatar ?? '',
                    );
                  Get.back<void>();
                    Get.to(() => MemberDetailPage(user: participantUser));
                  },
                  leading: SafeCircleAvatar(
                    imageUrl: userAvatar,
                    radius: 20,
                  ),
                  title: Text(
                    userName,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    userEmail ?? l10n.digitalNomad,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                  ),
                );
              },
            );
        }),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
