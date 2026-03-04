import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/location_controller.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Meetup List Tab 枚举
enum MeetupListTab {
  upcoming, // 即将开始
  joined, // 已加入
  past, // 已结束
  cancelled, // 已取消
}

/// Meetup List 页面控制器
class MeetupListController extends GetxController with GetSingleTickerProviderStateMixin {
  // 依赖注入
  final IMeetupRepository _meetupRepository = Get.find();
  final AuthStateController _authController = Get.find();
  final LocationController _locationController = Get.put(LocationController());
  final MeetupStateController _meetupStateController = Get.find();

  // Tab 控制器
  late TabController tabController;

  // 每个 Tab 的数据状态
  final Map<MeetupListTab, RxList<Meetup>> tabMeetups = {
    MeetupListTab.upcoming: <Meetup>[].obs,
    MeetupListTab.joined: <Meetup>[].obs,
    MeetupListTab.past: <Meetup>[].obs,
    MeetupListTab.cancelled: <Meetup>[].obs,
  };

  // 每个 Tab 的加载状态
  final Map<MeetupListTab, RxBool> tabLoading = {
    MeetupListTab.upcoming: false.obs,
    MeetupListTab.joined: false.obs,
    MeetupListTab.past: false.obs,
    MeetupListTab.cancelled: false.obs,
  };

  // 每个 Tab 的分页状态
  final Map<MeetupListTab, int> tabPage = {
    MeetupListTab.upcoming: 1,
    MeetupListTab.joined: 1,
    MeetupListTab.past: 1,
    MeetupListTab.cancelled: 1,
  };

  // 每个 Tab 是否还有更多数据
  final Map<MeetupListTab, bool> tabHasMore = {
    MeetupListTab.upcoming: true,
    MeetupListTab.joined: true,
    MeetupListTab.past: true,
    MeetupListTab.cancelled: true,
  };

  // 每个 Tab 的滚动控制器
  final Map<MeetupListTab, ScrollController> tabScrollControllers = {};

  // 下拉刷新状态
  final isRefreshing = false.obs;

  // 筛选条件
  final selectedCountries = <String>[].obs;
  final selectedCities = <String>[].obs;
  final selectedTypes = <String>[].obs;
  final timeFilter = 'all'.obs;
  final maxAttendees = 100.obs;

  // 可用筛选选项
  final availableCountries = ['Thailand', 'Indonesia', 'Vietnam', 'Portugal', 'Mexico', 'Japan'];
  final availableCities = ['Bangkok', 'Chiang Mai', 'Bali', 'Lisbon', 'Tokyo', 'Ho Chi Minh'];
  final availableTypes = ['Coffee', 'Coworking', 'Activity', 'Language Exchange', 'Dinner', 'Workshop'];

  // 当前 Tab 索引
  final currentTabIndex = 0.obs;

  // DataEventBus 订阅
  StreamSubscription<DataChangedEvent>? _rsvpChangedSubscription;

  // 当前用户ID
  String? get currentUserId => _authController.currentUser.value?.id;
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  // 是否有活动筛选条件
  bool get hasActiveFilters =>
      selectedCountries.isNotEmpty ||
      selectedCities.isNotEmpty ||
      selectedTypes.isNotEmpty ||
      timeFilter.value != 'all' ||
      maxAttendees.value != 100;

  @override
  void onInit() {
    super.onInit();
    log('🔵 MeetupListController onInit');

    // 初始化 Tab 控制器
    tabController = TabController(length: 4, vsync: this);

    // 为每个 Tab 创建滚动控制器
    for (final tab in MeetupListTab.values) {
      tabScrollControllers[tab] = ScrollController();
      _setupScrollListener(tab);
    }

    // 监听 Tab 切换
    tabController.addListener(_onTabChanged);

    // 设置 RSVP 变更监听
    _setupRsvpChangeListener();

    // 加载初始数据
    loadTabData(MeetupListTab.upcoming);
    _autoSelectCurrentCountry();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    for (var controller in tabScrollControllers.values) {
      controller.dispose();
    }
    _rsvpChangedSubscription?.cancel();
    _rsvpChangedSubscription = null;
    super.onClose();
  }

  /// 设置滚动监听器实现无限滚动
  void _setupScrollListener(MeetupListTab tab) {
    tabScrollControllers[tab]!.addListener(() {
      final controller = tabScrollControllers[tab]!;
      if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
        loadMoreData(tab);
      }
    });
  }

  /// 设置 RSVP 变更监听器
  void _setupRsvpChangeListener() {
    _rsvpChangedSubscription = DataEventBus.instance.on('meetup_rsvp', (event) {
      log('🔔 [MeetupListController] 收到 RSVP 变更: ${event.entityId}, ${event.changeType}');

      final meetupId = event.entityId;
      final isJoining = event.changeType == DataChangeType.created;

      // 刷新 "已加入" tab（如果当前不在该 tab 则刷新，否则由 handleToggleJoin 已刷新）
      if (currentTab != MeetupListTab.joined) {
        loadTabData(MeetupListTab.joined, refresh: true);
      }

      // 更新所有 tab 中对应活动的状态（除了已加入 tab，因为已刷新）
      if (meetupId != null) {
        for (final tab in MeetupListTab.values) {
          if (tab != MeetupListTab.joined) {
            _updateMeetupJoinStatus(tab, meetupId, isJoining);
          }
        }
      }
    });

    log('✅ [MeetupListController] RSVP 变更监听已设置');
  }

  /// 更新指定 tab 中活动的加入状态
  void _updateMeetupJoinStatus(MeetupListTab tab, String meetupId, bool isJoined) {
    final meetups = tabMeetups[tab]!;
    final index = meetups.indexWhere((m) => m.id == meetupId);

    if (index != -1) {
      final oldMeetup = meetups[index];
      final newCount = isJoined
          ? oldMeetup.capacity.currentAttendees + 1
          : (oldMeetup.capacity.currentAttendees - 1).clamp(0, oldMeetup.capacity.maxAttendees);

      meetups[index] = Meetup(
        id: oldMeetup.id,
        title: oldMeetup.title,
        type: oldMeetup.type,
        eventType: oldMeetup.eventType,
        description: oldMeetup.description,
        location: oldMeetup.location,
        venue: oldMeetup.venue,
        schedule: oldMeetup.schedule,
        capacity: Capacity(
          maxAttendees: oldMeetup.capacity.maxAttendees,
          currentAttendees: newCount,
        ),
        organizer: oldMeetup.organizer,
        images: oldMeetup.images,
        attendeeIds: oldMeetup.attendeeIds,
        status: oldMeetup.status,
        createdAt: oldMeetup.createdAt,
        isJoined: isJoined,
        isOrganizer: oldMeetup.isOrganizer,
      );

      meetups.refresh();
      log('✅ [MeetupListController] 已更新 $tab 中活动 $meetupId 的加入状态: $isJoined');
    }
  }

  /// Tab 切换事件处理
  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      final tab = MeetupListTab.values[tabController.index];
      currentTabIndex.value = tabController.index;
      // 如果该 Tab 还没有数据，则加载
      if (tabMeetups[tab]!.isEmpty && !tabLoading[tab]!.value) {
        loadTabData(tab);
      }
    }
  }

  /// 自动选择当前国家
  void _autoSelectCurrentCountry() {
    ever(_locationController.currentCountry, (country) {
      if (country != '未知国家' && availableCountries.contains(country)) {
        if (!selectedCountries.contains(country)) {
          selectedCountries.add(country);
        }
      }
    });
  }

  /// 重置筛选条件
  void resetFilters() {
    selectedCountries.clear();
    selectedCities.clear();
    selectedTypes.clear();
    timeFilter.value = 'all';
    maxAttendees.value = 100;
    _autoSelectCurrentCountry();
  }

  /// 获取当前 Tab
  MeetupListTab get currentTab => MeetupListTab.values[tabController.index];

  /// 获取当前 Tab 的数据
  RxList<Meetup> get currentMeetups => tabMeetups[currentTab]!;

  /// 获取当前 Tab 的加载状态
  RxBool get currentLoading => tabLoading[currentTab]!;

  /// 获取当前 Tab 的滚动控制器
  ScrollController? get currentScrollController => tabScrollControllers[currentTab];

  /// 加载指定 Tab 的数据
  Future<void> loadTabData(MeetupListTab tab, {bool refresh = false}) async {
    log('📡 loadTabData: tab=$tab, refresh=$refresh');
    log('   loading=${tabLoading[tab]!.value}, hasMore=${tabHasMore[tab]}');

    if (tabLoading[tab]!.value) {
      log('   ⏭️ 跳过：正在加载中');
      return;
    }
    if (!refresh && !tabHasMore[tab]!) {
      log('   ⏭️ 跳过：没有更多数据');
      return;
    }

    tabLoading[tab]!.value = true;

    try {
      if (refresh) {
        tabPage[tab] = 1;
        tabHasMore[tab] = true;
      }

      final page = tabPage[tab]!;
      List<Meetup> meetups = [];

      // 根据 Tab 调用不同的后端接口
      switch (tab) {
        case MeetupListTab.upcoming:
          // 获取所有未取消和未过期的活动 (upcoming + ongoing)
          // 排序：按开始时间升序（最近的排前面）
          meetups = await _meetupRepository.getMeetups(
            status: 'upcoming,ongoing',
            page: page,
            pageSize: 20,
          );
          // 确保按开始时间升序排序（最近的活动排前面）
          meetups.sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));
          break;
        case MeetupListTab.joined:
          // 已加入的活动（不包含已过期和取消的）
          meetups = await _meetupRepository.getJoinedMeetups(
            page: page,
            pageSize: 20,
          );
          // 按开始时间升序排序
          meetups.sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));
          break;
        case MeetupListTab.past:
          // 已结束的活动 - 按结束时间降序（最近结束的排前面）
          meetups = await _meetupRepository.getMeetups(
            status: 'completed',
            page: page,
            pageSize: 20,
          );
          // 确保按结束时间降序排序（最近结束的排前面）
          // endTime 可能为空，如果为空则使用 startTime
          meetups.sort((a, b) {
            final aEndTime = a.schedule.endTime ?? a.schedule.startTime;
            final bEndTime = b.schedule.endTime ?? b.schedule.startTime;
            return bEndTime.compareTo(aEndTime);
          });
          break;
        case MeetupListTab.cancelled:
          // 当前用户取消参与的活动
          if (currentUserId == null) {
            log('⚠️ 用户未登录，无法加载已取消的活动');
            meetups = [];
          } else {
            log('🔍 正在加载用户 $currentUserId 取消的活动...');
            meetups = await _meetupRepository.getCancelledMeetupsByUser(
              currentUserId!,
              page: page,
              pageSize: 20,
            );
            log('✅ 成功加载 ${meetups.length} 个已取消的活动');
          }
          break;
      }

      if (refresh) {
        tabMeetups[tab]!.value = meetups;
      } else {
        tabMeetups[tab]!.addAll(meetups);
      }

      // 如果返回数据少于 pageSize，说明没有更多数据了
      if (meetups.length < 20) {
        tabHasMore[tab] = false;
      } else {
        tabPage[tab] = page + 1;
      }

      log('✅ Tab $tab 加载了 ${meetups.length} 个活动 (页码: $page)');
    } catch (e, stackTrace) {
      log('❌ Tab $tab 加载失败: $e');
      log('Stack trace: $stackTrace');
      AppToast.error(_l10n.loadFailed);
    } finally {
      tabLoading[tab]!.value = false;
    }
  }

  /// 加载更多数据(无限滚动)
  Future<void> loadMoreData(MeetupListTab tab) async {
    await loadTabData(tab);
  }

  /// 刷新当前 Tab 数据
  Future<void> refreshCurrentTab() async {
    isRefreshing.value = true;
    await loadTabData(currentTab, refresh: true);
    isRefreshing.value = false;
  }

  /// 更新 Meetup 数据
  void updateMeetup(Meetup updatedMeetup) {
    for (final tab in MeetupListTab.values) {
      final meetups = tabMeetups[tab]!;
      final index = meetups.indexWhere((m) => m.id == updatedMeetup.id);
      if (index != -1) {
        meetups[index] = updatedMeetup;
      }
    }
  }

  /// 处理加入/退出活动
  Future<void> handleToggleJoin(Meetup meetup, bool currentlyJoined) async {
    final isJoining = !currentlyJoined;

    try {
      if (isJoining) {
        await _meetupRepository.rsvpToMeetup(meetup.id);
        log('✅ 成功加入活动: ${meetup.title}');
        if (!_meetupStateController.rsvpedMeetupIds.contains(meetup.id)) {
          _meetupStateController.rsvpedMeetupIds.add(meetup.id);
        }
        AppToast.success(_l10n.joinedSuccessfully);
      } else {
        await _meetupRepository.cancelRsvp(meetup.id);
        log('✅ 成功退出活动: ${meetup.title}');
        _meetupStateController.rsvpedMeetupIds.remove(meetup.id);
        AppToast.success(_l10n.youLeftMeetup);
      }

      // 发送 RSVP 变更事件，通知其他 tab 更新
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'meetup_rsvp',
        entityId: meetup.id,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: isJoining ? DataChangeType.created : DataChangeType.deleted,
      ));

      // 刷新当前 tab
      await refreshCurrentTab();
    } catch (e) {
      log('❌ 加入/退出活动失败: $e');
      final errorMessage = e.toString();

      // 处理状态不同步的情况
      if (errorMessage.contains('已经参加') || errorMessage.contains('already joined')) {
        if (!_meetupStateController.rsvpedMeetupIds.contains(meetup.id)) {
          _meetupStateController.rsvpedMeetupIds.add(meetup.id);
        }
        await refreshCurrentTab();
        AppToast.info(_l10n.dataServiceAlreadyJoinedMeetup);
        return;
      }

      if (errorMessage.contains('未参加') ||
          errorMessage.contains('not joined') ||
          errorMessage.contains('not a participant')) {
        _meetupStateController.rsvpedMeetupIds.remove(meetup.id);
        await refreshCurrentTab();
        AppToast.info(_l10n.dataServiceNotJoinedMeetup);
        return;
      }

      rethrow;
    }
  }

  /// 处理取消活动
  Future<bool> handleCancelMeetup(Meetup meetup) async {
    try {
      await _meetupRepository.cancelMeetup(meetup.id);
      log('✅ 成功取消活动: ${meetup.title}');
      await refreshCurrentTab();
      return true;
    } catch (e) {
      log('❌ 取消活动失败: $e');
      return false;
    }
  }
}
