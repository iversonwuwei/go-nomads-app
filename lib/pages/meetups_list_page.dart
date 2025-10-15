import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_colors.dart';
import '../controllers/location_controller.dart';
import '../models/meetup_model.dart';
import '../widgets/app_toast.dart';
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

  // 筛选条件
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

  // 位置控制器
  final LocationController _locationController = Get.put(LocationController());

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

  // 重置筛选条件
  void _resetFilters() {
    _selectedCountries.clear();
    _selectedCities.clear();
    _selectedTypes.clear();
    _timeFilter.value = 'all';
    _maxAttendees.value = 100;
    _autoSelectCurrentCountry();
  }

  // 是否有活动筛选条件
  bool get _hasActiveFilters {
    return _selectedCountries.isNotEmpty ||
        _selectedCities.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _timeFilter.value != 'all' ||
        _maxAttendees.value != 100;
  }

  Future<void> _loadMeetups() async {
    _isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    _meetups.value = [
      MeetupModel(
        id: '1',
        title: 'Digital Nomad Coffee Morning',
        type: 'Coffee',
        description:
            'Join us for a relaxed morning coffee session to meet other digital nomads in Bangkok!',
        city: 'Bangkok',
        country: 'Thailand',
        venue: 'Hub53 Coworking',
        venueAddress: '535 Sukhumvit Road',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
        maxAttendees: 15,
        currentAttendees: 8,
        organizerId: 'user1',
        organizerName: 'Sarah Chen',
        organizerAvatar: 'https://i.pravatar.cc/150?img=1',
        images: [
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
        ],
        attendeeIds: List.generate(8, (i) => 'attendee$i'),
        isJoined: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MeetupModel(
        id: '2',
        title: 'Coworking Session & Networking',
        type: 'Coworking',
        description:
            'Productive coworking session followed by networking drinks. Bring your laptop!',
        city: 'Chiang Mai',
        country: 'Thailand',
        venue: 'Punspace Nimman',
        venueAddress: 'Nimmana Haeminda Road',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
        maxAttendees: 20,
        currentAttendees: 15,
        organizerId: 'user2',
        organizerName: 'Mike Johnson',
        organizerAvatar: 'https://i.pravatar.cc/150?img=12',
        images: [
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
        ],
        attendeeIds: List.generate(15, (i) => 'attendee$i'),
        isJoined: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MeetupModel(
        id: '3',
        title: 'Weekend Hiking Adventure',
        type: 'Activity',
        description:
            'Explore the beautiful trails around Chiang Mai. All fitness levels welcome!',
        city: 'Chiang Mai',
        country: 'Thailand',
        venue: 'Doi Suthep Trailhead',
        venueAddress: 'Doi Suthep-Pui National Park',
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 7)),
        maxAttendees: 12,
        currentAttendees: 9,
        organizerId: 'user3',
        organizerName: 'Emma Wilson',
        organizerAvatar: 'https://i.pravatar.cc/150?img=5',
        images: [
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
        ],
        attendeeIds: List.generate(9, (i) => 'attendee$i'),
        isJoined: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      MeetupModel(
        id: '4',
        title: 'Thai Language Exchange',
        type: 'Language',
        description:
            'Practice Thai with locals and help them with English. Fun and casual atmosphere!',
        city: 'Bangkok',
        country: 'Thailand',
        venue: 'Lumpini Park',
        venueAddress: 'Rama IV Road',
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 17)),
        maxAttendees: 25,
        currentAttendees: 18,
        organizerId: 'user4',
        organizerName: 'David Lee',
        organizerAvatar: 'https://i.pravatar.cc/150?img=13',
        images: [
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
        ],
        attendeeIds: List.generate(18, (i) => 'attendee$i'),
        isJoined: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    _isLoading.value = false;
  }

  List<MeetupModel> get _filteredMeetups {
    final now = DateTime.now();
    List<MeetupModel> filtered = [];

    // 先按标签页筛选
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

    // 按国家筛选
    if (_selectedCountries.isNotEmpty) {
      filtered = filtered
          .where((m) => _selectedCountries.contains(m.country))
          .toList();
    }

    // 按城市筛选
    if (_selectedCities.isNotEmpty) {
      filtered =
          filtered.where((m) => _selectedCities.contains(m.city)).toList();
    }

    // 按类型筛选
    if (_selectedTypes.isNotEmpty) {
      filtered =
          filtered.where((m) => _selectedTypes.contains(m.type)).toList();
    }

    // 按时间范围筛选
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

    // 按最大人数筛选
    if (_maxAttendees.value < 100) {
      filtered =
          filtered.where((m) => m.maxAttendees <= _maxAttendees.value).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
          'Meetups',
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
            onPressed: () {
              Get.toNamed('/create-meetup');
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
            Tab(text: 'All Meetups'),
            Tab(text: 'Joined'),
            Tab(text: 'Past'),
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
              // 工具栏
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${meetups.length} ${_tabController.index == 0 ? 'Upcoming' : _tabController.index == 1 ? 'Joined' : 'Past'} Events',
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
                            const PopupMenuItem(
                                value: 'date', child: Text('Date')),
                            const PopupMenuItem(
                                value: 'popular', child: Text('Popular')),
                            const PopupMenuItem(
                                value: 'nearby', child: Text('Nearby')),
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
                  padding: EdgeInsets.all(16.w),
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
                ? 'No joined meetups yet'
                : _tabController.index == 2
                    ? 'No past meetups'
                    : 'No meetups available',
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
    return GestureDetector(
      onTap: () {
        Get.to(() => MeetupDetailPage(meetup: meetup));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
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
            // 图片
            if (meetup.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  meetup.images.first,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180.h,
                      color: AppColors.borderLight,
                      child: Icon(Icons.image_not_supported,
                          size: 48.sp, color: AppColors.textTertiary),
                    );
                  },
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和类型
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meetup.title,
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
                      _buildTypeChip(meetup.type),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // 时间
                  _buildInfoRow(
                    Icons.schedule,
                    _formatDateTime(meetup.dateTime),
                    meetup.isStartingSoon ? const Color(0xFFFF4458) : null,
                  ),

                  SizedBox(height: 8.h),

                  // 地点
                  _buildInfoRow(Icons.location_on, meetup.venue, null),

                  SizedBox(height: 8.h),

                  // 参与人数
                  _buildInfoRow(
                    Icons.people,
                    '${meetup.currentAttendees}/${meetup.maxAttendees} attendees',
                    meetup.isFull ? Colors.orange : null,
                  ),

                  SizedBox(height: 16.h),

                  // 组织者和操作按钮
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundImage: NetworkImage(meetup.organizerAvatar),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          meetup.organizerName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _buildJoinButton(meetup),
                      SizedBox(width: 8.w),
                      _buildChatButton(meetup),
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

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'coffee':
        color = Colors.brown;
        break;
      case 'coworking':
        color = Colors.blue;
        break;
      case 'activity':
        color = Colors.green;
        break;
      case 'language':
        color = Colors.purple;
        break;
      default:
        color = AppColors.textSecondary;
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

  Widget _buildJoinButton(MeetupModel meetup) {
    if (meetup.isEnded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Ended',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (meetup.isFull && !meetup.isJoined) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Full',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _toggleJoin(meetup),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: meetup.isJoined
              ? const Color(0xFFFF4458).withValues(alpha: 0.1)
              : const Color(0xFFFF4458),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          meetup.isJoined ? 'Joined' : 'Join',
          style: TextStyle(
            fontSize: 12.sp,
            color: meetup.isJoined ? const Color(0xFFFF4458) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(MeetupModel meetup) {
    return GestureDetector(
      onTap: () => _openChat(meetup),
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

  void _toggleJoin(MeetupModel meetup) {
    final index = _meetups.indexWhere((m) => m.id == meetup.id);
    if (index != -1) {
      final updated = meetup.copyWith(
        isJoined: !meetup.isJoined,
        currentAttendees: meetup.currentAttendees + (meetup.isJoined ? -1 : 1),
      );
      _meetups[index] = updated;

      if (updated.isJoined) {
        AppToast.success(
          'You have joined ${meetup.title}',
          title: 'Joined!',
        );
      } else {
        AppToast.info(
          'You left ${meetup.title}',
          title: 'Left meetup',
        );
      }
    }
  }

  void _openChat(MeetupModel meetup) {
    if (!meetup.isJoined) {
      AppToast.warning(
        'You need to join this meetup before you can access the group chat',
        title: 'Join Required',
      );
      return;
    }

    // 跳转到群聊页面
    Get.toNamed(
      '/city-chat',
      arguments: {
        'city': meetup.title,
        'country': '${meetup.type} Meetup',
        'meetupId': meetup.id,
        'isMeetupChat': true,
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    }
  }
}

// Meetup 筛选抽屉组件
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
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
                  'Filters',
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
                        'Reset',
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

          // 筛选选项（可滚动）
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 国家筛选
                  _buildSectionTitle('Country'),
                  SizedBox(height: 12.h),
                  Text(
                    'Auto-detected based on your current location',
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

                  // 城市筛选
                  _buildSectionTitle('City'),
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

                  // 类型筛选
                  _buildSectionTitle('Meetup Type'),
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

                  // 时间筛选
                  _buildSectionTitle('Time Range'),
                  SizedBox(height: 12.h),
                  Obx(() => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _buildTimeChip('All', 'all'),
                          _buildTimeChip('Today', 'today'),
                          _buildTimeChip('This Week', 'week'),
                          _buildTimeChip('This Month', 'month'),
                        ],
                      )),

                  SizedBox(height: 24.h),

                  // 最大人数筛选
                  _buildSectionTitle('Maximum Attendees'),
                  SizedBox(height: 12.h),
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maxAttendees.value >= 100
                                ? '100+ people'
                                : '${maxAttendees.value} people',
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
                    'Apply Filters',
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
