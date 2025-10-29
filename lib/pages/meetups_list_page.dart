import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../controllers/location_controller.dart';
import '../generated/app_localizations.dart';
import '../models/meetup_model.dart';
import '../routes/app_routes.dart';
import '../services/events_api_service.dart';
import '../widgets/app_toast.dart';
import 'create_meetup_page.dart';
import 'meetup_detail_page.dart';

/// Meetups 列表页面
class MeetupsListPage extends StatefulWidget {
  const MeetupsListPage({super.key});

  @override
  State<MeetupsListPage> createState() => _MeetupsListPageState();
}

class _MeetupsListPageState extends State<MeetupsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RxBool _isLoading = false.obs;
  final RxList<MeetupModel> _meetups = <MeetupModel>[].obs;

  // 筛选条�?
  final RxList<String> _selectedCountries = <String>[].obs;
  final RxList<String> _selectedCities = <String>[].obs;
  final RxList<String> _selectedTypes = <String>[].obs;
  final RxString _timeFilter = 'all'.obs; // all, today, week, month
  final RxInt _maxAttendees = 100.obs;

  // 可用选项
  final List<String> availableCountries = [
    'Thailand',
    'Indonesia',
    'Vietnam',
    'Portugal',
    'Mexico',
    'Japan'
  ];
  final List<String> availableCities = [
    'Bangkok',
    'Chiang Mai',
    'Bali',
    'Lisbon',
    'Tokyo',
    'Ho Chi Minh'
  ];
  final List<String> availableTypes = [
    'Coffee',
    'Coworking',
    'Activity',
    'Language Exchange',
    'Dinner',
    'Workshop'
  ];

  // 位置控制�?
  final LocationController _locationController = Get.put(LocationController());

  // Events API 服务
  final EventsApiService _eventsApiService = EventsApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMeetups();
    _autoSelectCurrentCountry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 自动选择当前国家
  void _autoSelectCurrentCountry() {
    // 从位置控制器获取当前国家
    ever(_locationController.currentCountry, (country) {
      if (country != '未知国家' && availableCountries.contains(country)) {
        if (!_selectedCountries.contains(country)) {
          _selectedCountries.add(country);
        }
      }
    });
  }

  // 重置筛选条�?
  void _resetFilters() {
    _selectedCountries.clear();
    _selectedCities.clear();
    _selectedTypes.clear();
    _timeFilter.value = 'all';
    _maxAttendees.value = 100;
    _autoSelectCurrentCountry();
  }

  // 是否有活动筛选条�?
  bool get _hasActiveFilters {
    return _selectedCountries.isNotEmpty ||
        _selectedCities.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _timeFilter.value != 'all' ||
        _maxAttendees.value != 100;
  }

  Future<void> _loadMeetups() async {
    _isLoading.value = true;

    try {
      // 从后端API加载活动数据
      final response = await _eventsApiService.getEvents(
        status: 'upcoming',
        pageSize: 100, // 获取更多数据
      );

      // HttpService 的拦截器已经解包�?API 响应
      // response 现在直接�?data 对象: {items: [], totalCount: 3, page: 1, ...}
      print('📦 Response data: $response');

      final items = response['items'] as List<dynamic>? ?? [];

      // 打印第一个活动的完整数据结构（用于调试）
      if (items.isNotEmpty) {
        print('🔍 第一个活动的完整数据:');
        print(items[0]);
      }

      // 转换�?MeetupModel 列表
      _meetups.value = items.map((item) {
        return _convertApiEventToMeetupModel(item as Map<String, dynamic>);
      }).toList();

      print(
          '�?从后端API加载�?${_meetups.length} 个活�?(总数: ${response['totalCount']})');
    } catch (e, stackTrace) {
      print('�?从API加载失败: $e');
      print('Stack trace: $stackTrace');
      AppToast.error('加载活动失败');
      _meetups.value = [];
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

    // 解析组织者信�?
    final organizerData = event['organizer'] as Map<String, dynamic>?;
    final organizerName = organizerData?['name'] as String? ?? 'Unknown';
    final organizerId = organizerData?['id']?.toString() ??
        event['organizerId']?.toString() ??
        '0';

    // 获取 imageUrl（用于列表页的封面图�?
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

    // 🔍 调试日志:打印所有可能的参与者字�?
    print('🔍 Event ${event['id']} - isParticipant: ${event['isParticipant']}');
    print('  participantCount: ${event['participantCount']}');
    print('  currentParticipants: ${event['currentParticipants']}');
    print('  participantsCount: ${event['participantsCount']}');
    print('  attendeesCount: ${event['attendeesCount']}');
    print('  participants: ${event['participants']}');
    print('  maxParticipants: ${event['maxParticipants']}');

    // 获取当前参与者数�?- 支持多个可能的字段名（优先使�?participantCount，与 detail page 保持一致）
    final currentParticipants = (event['participantCount'] as int?) ??
        (event['currentParticipants'] as int?) ??
        (event['participantsCount'] as int?) ??
        (event['attendeesCount'] as int?) ??
        (event['participants'] as int?) ??
        0;

    // 确保参与者数量不为负�?
    final maxParticipants = event['maxParticipants'] as int? ?? 20;
    final validCurrentParticipants =
        currentParticipants.clamp(0, maxParticipants);

    print(
        '  �?最终使�? currentAttendees=$validCurrentParticipants, maxAttendees=$maxParticipants');

    return MeetupModel(
      id: event['id']?.toString() ?? '',
      title: event['title'] as String? ?? '',
      type: event['category'] as String? ?? 'Meetup',
      description: event['description'] as String? ?? '',
      city: cityName,
      country: country,
      venue: event['location'] as String? ?? '',
      venueAddress: event['address'] as String? ?? '',
      dateTime: DateTime.parse(
          event['startTime'] as String? ?? DateTime.now().toIso8601String()),
      maxAttendees: maxParticipants,
      currentAttendees: validCurrentParticipants,
      organizerId: organizerId,
      organizerName: organizerName,
      organizerAvatar: 'https://i.pravatar.cc/150?u=$organizerId',
      imageUrl: imageUrl, // 封面图（列表页使用）
      images: images, // 完整图片数组（详情页使用�?
      attendeeIds: [], // 需要单独查�?
      isJoined: event['isParticipant'] as bool? ?? false,
      createdAt: DateTime.parse(
          event['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  List<MeetupModel> get _filteredMeetups {
    final now = DateTime.now();
    List<MeetupModel> filtered = [];

    // 先按标签页筛�?
    switch (_tabController.index) {
      case 0: // All
        filtered = _meetups.where((m) => m.dateTime.isAfter(now)).toList();
        break;
      case 1: // Joined
        filtered = _meetups
            .where((m) => m.isJoined && m.dateTime.isAfter(now))
            .toList();
        break;
      case 2: // Past
        filtered = _meetups.where((m) => m.dateTime.isBefore(now)).toList();
        break;
      default:
        filtered = _meetups.toList();
    }

    // 按国家筛�?
    if (_selectedCountries.isNotEmpty) {
      filtered = filtered
          .where((m) => _selectedCountries.contains(m.country))
          .toList();
    }

    // 按城市筛�?
    if (_selectedCities.isNotEmpty) {
      filtered =
          filtered.where((m) => _selectedCities.contains(m.city)).toList();
    }

    // 按类型筛�?
    if (_selectedTypes.isNotEmpty) {
      filtered =
          filtered.where((m) => _selectedTypes.contains(m.type)).toList();
    }

    // 按时间范围筛�?
    if (_timeFilter.value != 'all') {
      switch (_timeFilter.value) {
        case 'today':
          filtered = filtered.where((m) {
            final diff = m.dateTime.difference(now);
            return diff.inHours >= 0 && diff.inHours < 24;
          }).toList();
          break;
        case 'week':
          filtered = filtered.where((m) {
            final diff = m.dateTime.difference(now);
            return diff.inDays >= 0 && diff.inDays < 7;
          }).toList();
          break;
        case 'month':
          filtered = filtered.where((m) {
            final diff = m.dateTime.difference(now);
            return diff.inDays >= 0 && diff.inDays < 30;
          }).toList();
          break;
      }
    }

    // 按最大人数筛�?
    if (_maxAttendees.value < 100) {
      filtered =
          filtered.where((m) => m.maxAttendees <= _maxAttendees.value).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.meetups,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.tune_outlined,
                      color: _hasActiveFilters
                          ? const Color(0xFFFF4458)
                          : AppColors.textSecondary,
                      size: 24.sp,
                    ),
                    onPressed: _showFilterDrawer,
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4458),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              )),
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: const Color(0xFFFF4458), size: 24.sp),
            onPressed: () async {
              // 跳转到创建页面，等待返回结果
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateMeetupPage(),
                ),
              );
              // 如果创建成功，刷新列表
              if (result == true) {
                _loadMeetups();
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF4458),
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: const Color(0xFFFF4458),
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          onTap: (index) => setState(() {}),
          tabs: [
            Tab(text: l10n.allMeetups),
            Tab(text: l10n.joined),
            Tab(text: l10n.past),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFFFF4458),
              strokeWidth: 3.w,
            ),
          );
        }

        final meetups = _filteredMeetups;

        if (meetups.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: const Color(0xFFFF4458),
          onRefresh: _loadMeetups,
          child: Column(
            children: [
              // 工具�?
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tabController.index == 0
                          ? l10n.upcomingEvents('${meetups.length}')
                          : _tabController.index == 1
                              ? l10n.joinedEvents('${meetups.length}')
                              : l10n.pastEvents('${meetups.length}'),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        // View toggle (could add list/grid view later)
                        IconButton(
                          icon: Icon(
                            Icons.grid_view_outlined,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            // Toggle view - could implement grid view
                          },
                        ),
                        // Sort
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.sort_outlined,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          ),
                          onSelected: (value) {
                            // Handle sort
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 'date', child: Text(l10n.date)),
                            PopupMenuItem(
                                value: 'popular', child: Text(l10n.popular)),
                            PopupMenuItem(
                                value: 'nearby', child: Text(l10n.nearby)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Meetups list
              Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100), // 底部留白给导航栏
                  itemCount: meetups.length,
                  itemBuilder: (context, index) {
                    return _buildMeetupCard(meetups[index]);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            _tabController.index == 1
                ? l10n.noJoinedMeetupsYet
                : _tabController.index == 2
                    ? l10n.noPastMeetups
                    : l10n.noMeetupsAvailable,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupCard(MeetupModel meetup) {
    // 使用自管理生命周期的 StatefulWidget，参�?data_service_page 的设�?
    return _MeetupListCard(
      meetup: meetup,
      eventsApiService: _eventsApiService,
      onUpdated: (updatedMeetup) {
        // 回调更新父级�?_meetups 列表
        final index = _meetups.indexWhere((m) => m.id == updatedMeetup.id);
        if (index != -1) {
          _meetups[index] = updatedMeetup;
          _meetups.refresh();
        }
      },
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeetupFilterDrawer(
        selectedCountries: _selectedCountries,
        selectedCities: _selectedCities,
        selectedTypes: _selectedTypes,
        timeFilter: _timeFilter,
        maxAttendees: _maxAttendees,
        availableCountries: availableCountries,
        availableCities: availableCities,
        availableTypes: availableTypes,
        onReset: _resetFilters,
      ),
    );
  }
}

// 自管理生命周期的 Meetup Card - 参�?data_service_page 的设�?
class _MeetupListCard extends StatefulWidget {
  final MeetupModel meetup;
  final EventsApiService eventsApiService;
  final Function(MeetupModel) onUpdated;

  const _MeetupListCard({
    required this.meetup,
    required this.eventsApiService,
    required this.onUpdated,
  });

  @override
  State<_MeetupListCard> createState() => _MeetupListCardState();
}

class _MeetupListCardState extends State<_MeetupListCard> {
  // 卡片自己的状�?- 符合 DDD 原则
  late bool _isJoined;
  late int _currentAttendees;
  late int _maxAttendees;

  @override
  void initState() {
    super.initState();

    // 初始化本地状�?
    _isJoined = widget.meetup.isJoined;
    _currentAttendees = widget.meetup.currentAttendees;
    _maxAttendees = widget.meetup.maxAttendees;

    print('🔍 MeetupListCard initState:');
    print('   ID: ${widget.meetup.id}');
    print('   Title: ${widget.meetup.title}');
    print('   isJoined: $_isJoined');
    print('   Attendees: $_currentAttendees / $_maxAttendees');
  }

  @override
  void didUpdateWidget(_MeetupListCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // �?widget 更新时，检查数据是否变�?
    if (oldWidget.meetup.id == widget.meetup.id) {
      // 同一�?meetup，更新状�?
      if (_isJoined != widget.meetup.isJoined ||
          _currentAttendees != widget.meetup.currentAttendees) {
        print('🔄 Meetup ${widget.meetup.title} 数据更新:');
        print('   isJoined: $_isJoined -> ${widget.meetup.isJoined}');
        print(
            '   Attendees: $_currentAttendees -> ${widget.meetup.currentAttendees}');
        setState(() {
          _isJoined = widget.meetup.isJoined;
          _currentAttendees = widget.meetup.currentAttendees;
          _maxAttendees = widget.meetup.maxAttendees;
        });
      }
    }
  }

  Future<void> _handleToggleJoin() async {
    final l10n = AppLocalizations.of(context)!;

    // 判断是加入还是退�?
    final isJoining = !_isJoined;

    try {
      // 调用 API
      if (isJoining) {
        await widget.eventsApiService.joinEvent(widget.meetup.id);
        print('�?成功加入活动: ${widget.meetup.title}');
      } else {
        await widget.eventsApiService.leaveEvent(widget.meetup.id);
        print('�?成功退出活�? ${widget.meetup.title}');
      }

      // API 调用成功，更新本地状�?
      setState(() {
        _isJoined = isJoining;
        _currentAttendees = _currentAttendees + (isJoining ? 1 : -1);
      });

      // 通知父级更新全局列表
      final updatedMeetup = widget.meetup.copyWith(
        isJoined: isJoining,
        currentAttendees: _currentAttendees,
      );
      widget.onUpdated(updatedMeetup);

      // 显示成功消息
      if (isJoining) {
        AppToast.success(
          l10n.youHaveJoined(widget.meetup.title),
          title: l10n.joined,
        );
      } else {
        AppToast.info(
          l10n.youLeft(widget.meetup.title),
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
        'city': widget.meetup.title,
        'country': '${widget.meetup.type} Meetup',
        'meetupId': widget.meetup.id,
        'isMeetupChat': true,
      },
    );
  }

  int get _remainingSlots => _maxAttendees - _currentAttendees;
  bool get _isFull => _remainingSlots <= 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Get.to(() => MeetupDetailPage(meetup: widget.meetup));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片 - 列表页只使用 imageUrl，如果为空显示占位图�?
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: widget.meetup.imageUrl != null &&
                      widget.meetup.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.meetup.imageUrl!,
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和类�?
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.meetup.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildTypeChip(widget.meetup.type),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // 时间
                  _buildInfoRow(
                    Icons.schedule,
                    _formatDateTime(widget.meetup.dateTime),
                    widget.meetup.isStartingSoon
                        ? const Color(0xFFFF4458)
                        : null,
                  ),

                  SizedBox(height: 8.h),

                  // 地点
                  _buildInfoRow(Icons.location_on, widget.meetup.venue, null),

                  SizedBox(height: 8.h),

                  // 参与人数和剩余名�?- 使用本地状�?
                  _buildInfoRow(
                    Icons.people,
                    '$_currentAttendees/$_maxAttendees attendees �?$_remainingSlots spots left',
                    _isFull
                        ? Colors.orange
                        : (_remainingSlots <= 3 ? Colors.red : null),
                  ),

                  SizedBox(height: 16.h),

                  // 组织者和操作按钮
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundImage:
                            NetworkImage(widget.meetup.organizerAvatar),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.meetup.organizerName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _buildJoinButton(l10n),
                      SizedBox(width: 8.w),
                      _buildChatButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 64.sp,
          color: const Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    // 根据后端返回�?category 类型设置颜色
    switch (type.toLowerCase()) {
      case 'coffee':
        color = Colors.brown;
        break;
      case 'coworking':
      case 'business':
        color = Colors.blue;
        break;
      case 'activity':
      case 'outdoor':
        color = Colors.green;
        break;
      case 'language':
        color = Colors.purple;
        break;
      case 'social':
        color = Colors.orange;
        break;
      case 'tech':
      case 'workshop':
        color = Colors.indigo;
        break;
      case 'food':
      case 'dinner':
        color = Colors.red;
        break;
      case 'sports':
        color = Colors.teal;
        break;
      case 'culture':
      case 'art':
        color = Colors.pink;
        break;
      case 'other':
        color = AppColors.textSecondary;
        break;
      default:
        // 为其他未知类型使用紫色调
        color = const Color(0xFF9C27B0);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color ?? AppColors.textSecondary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: color ?? AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(AppLocalizations l10n) {
    if (widget.meetup.isEnded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          l10n.ended,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_isFull && !_isJoined) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          l10n.full,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _handleToggleJoin,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _isJoined
              ? const Color(0xFFFF4458).withValues(alpha: 0.1)
              : const Color(0xFFFF4458),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          _isJoined ? l10n.joined : l10n.join,
          style: TextStyle(
            fontSize: 12.sp,
            color: _isJoined ? const Color(0xFFFF4458) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          size: 18.sp,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return '${l10n.today} ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return '${l10n.tomorrow} ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    }
  }
}

// Meetup 筛选抽屉组�?
class _MeetupFilterDrawer extends StatelessWidget {
  final RxList<String> selectedCountries;
  final RxList<String> selectedCities;
  final RxList<String> selectedTypes;
  final RxString timeFilter;
  final RxInt maxAttendees;
  final List<String> availableCountries;
  final List<String> availableCities;
  final List<String> availableTypes;
  final VoidCallback onReset;

  const _MeetupFilterDrawer({
    required this.selectedCountries,
    required this.selectedCities,
    required this.selectedTypes,
    required this.timeFilter,
    required this.maxAttendees,
    required this.availableCountries,
    required this.availableCities,
    required this.availableTypes,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部�?
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: onReset,
                      child: Text(
                        l10n.reset,
                        style: TextStyle(
                          color: const Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 筛选选项（可滚动�?
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 国家筛�?
                  _buildSectionTitle(l10n.country),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.autoDetectedLocation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: availableCountries.map((country) {
                          final isSelected =
                              selectedCountries.contains(country);
                          return FilterChip(
                            label: Text(country),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                selectedCountries.add(country);
                              } else {
                                selectedCountries.remove(country);
                              }
                            },
                            selectedColor:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  SizedBox(height: 24.h),

                  // 城市筛�?
                  _buildSectionTitle(l10n.city),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: availableCities.map((city) {
                          final isSelected = selectedCities.contains(city);
                          return FilterChip(
                            label: Text(city),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                selectedCities.add(city);
                              } else {
                                selectedCities.remove(city);
                              }
                            },
                            selectedColor:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  SizedBox(height: 24.h),

                  // 类型筛�?
                  _buildSectionTitle(l10n.meetupType),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: availableTypes.map((type) {
                          final isSelected = selectedTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                selectedTypes.add(type);
                              } else {
                                selectedTypes.remove(type);
                              }
                            },
                            selectedColor:
                                const Color(0xFFFF4458).withValues(alpha: 0.1),
                            checkmarkColor: const Color(0xFFFF4458),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : AppColors.borderLight,
                            ),
                          );
                        }).toList(),
                      )),

                  SizedBox(height: 24.h),

                  // 时间筛�?
                  _buildSectionTitle(l10n.timeRange),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _buildTimeChip(l10n.all, 'all'),
                          _buildTimeChip(l10n.today, 'today'),
                          _buildTimeChip(l10n.thisWeek, 'week'),
                          _buildTimeChip(l10n.thisMonth, 'month'),
                        ],
                      )),

                  SizedBox(height: 24.h),

                  // 最大人数筛�?
                  _buildSectionTitle(l10n.maximumAttendees),
                  SizedBox(height: 12.h),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maxAttendees.value >= 100
                                ? l10n.peoplePlus
                                : l10n.peopleCount('${maxAttendees.value}'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Slider(
                            value: maxAttendees.value.toDouble(),
                            min: 5,
                            max: 100,
                            divisions: 19,
                            activeColor: const Color(0xFFFF4458),
                            inactiveColor: AppColors.borderLight,
                            onChanged: (value) {
                              maxAttendees.value = value.toInt();
                            },
                          ),
                        ],
                      )),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // 底部应用按钮
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.applyFilters,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTimeChip(String label, String value) {
    final isSelected = timeFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          timeFilter.value = value;
        }
      },
      selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
      checkmarkColor: const Color(0xFFFF4458),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13.sp,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
      ),
    );
  }
}
