import 'dart:async';
import 'dart:developer';

import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/cancel_meetup_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/cancel_rsvp_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/create_meetup_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/get_meetups_by_city_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/get_meetups_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/rsvp_to_meetup_use_case.dart';
import 'package:go_nomads_app/features/meetup/application/use_cases/update_meetup_use_case.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/services/meetup_signalr_service.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:get/get.dart';

/// Meetup 状态管理 Controller V2
///
/// 使用新的数据同步框架优化版本
///
/// 改进点：
/// 1. 继承 PaginatedRefreshableController，统一分页和刷新逻辑
/// 2. 使用 hybrid 刷新策略
/// 3. 自动订阅数据变更事件
/// 4. 保留所有业务功能（RSVP、创建、更新等）
class MeetupStateController extends PaginatedRefreshableController {
  // ==================== Dependencies ====================
  final GetMeetupsUseCase _getMeetupsUseCase;
  final GetMeetupsByCityUseCase _getMeetupsByCityUseCase;
  final CreateMeetupUseCase _createMeetupUseCase;
  final UpdateMeetupUseCase _updateMeetupUseCase;
  final RsvpToMeetupUseCase _rsvpToMeetupUseCase;
  final CancelRsvpUseCase _cancelRsvpUseCase;
  final CancelMeetupUseCase _cancelMeetupUseCase;
  final IMeetupRepository _meetupRepository;

  MeetupStateController({
    required GetMeetupsUseCase getMeetupsUseCase,
    required GetMeetupsByCityUseCase getMeetupsByCityUseCase,
    required CreateMeetupUseCase createMeetupUseCase,
    required UpdateMeetupUseCase updateMeetupUseCase,
    required RsvpToMeetupUseCase rsvpToMeetupUseCase,
    required CancelRsvpUseCase cancelRsvpUseCase,
    required CancelMeetupUseCase cancelMeetupUseCase,
    required IMeetupRepository meetupRepository,
  })  : _getMeetupsUseCase = getMeetupsUseCase,
        _getMeetupsByCityUseCase = getMeetupsByCityUseCase,
        _createMeetupUseCase = createMeetupUseCase,
        _updateMeetupUseCase = updateMeetupUseCase,
        _rsvpToMeetupUseCase = rsvpToMeetupUseCase,
        _cancelRsvpUseCase = cancelRsvpUseCase,
        _cancelMeetupUseCase = cancelMeetupUseCase,
        _meetupRepository = meetupRepository;

  // ==================== 继承配置 ====================

  @override
  String get entityType => 'meetup_list';

  @override
  RefreshStrategy get refreshStrategy => RefreshStrategy.hybrid;

  @override
  Duration? get customCacheDuration => const Duration(minutes: 2);

  @override
  int get pageSize => 20;

  // ==================== 状态管理 ====================

  /// 活动列表
  final RxList<Meetup> meetups = <Meetup>[].obs;

  /// 用户已 RSVP 的活动 ID 集合
  final RxList<String> rsvpedMeetupIds = <String>[].obs;

  /// 当前筛选的城市ID
  final RxString currentCityId = ''.obs;

  /// 当前筛选的状态
  final RxString currentStatus = 'upcoming'.obs;

  // ==================== Getters ====================

  /// 获取即将到来的活动 (未来30天内)
  List<Meetup> get upcomingMeetups {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    return meetups
        .where((m) =>
            m.status.value != 'cancelled' &&
            m.status.value == 'upcoming' &&
            m.schedule.startTime.isAfter(now) &&
            m.schedule.startTime.isBefore(thirtyDaysLater))
        .toList()
      ..sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));
  }

  /// 检查是否已 RSVP
  bool isRsvped(String meetupId) {
    return rsvpedMeetupIds.contains(meetupId);
  }

  /// 获取用户已 RSVP 的活动
  List<Meetup> get rsvpedMeetups {
    return meetups.where((m) => rsvpedMeetupIds.contains(m.id)).toList();
  }

  // ==================== 生命周期 ====================

  // SignalR 订阅
  final List<StreamSubscription> _signalRSubscriptions = [];

  @override
  void onInit() {
    super.onInit();
    log('🎬 MeetupStateController 初始化...');
    _setupLoginStateListener();
    _setupDataChangeListeners();
    _setupSignalRListeners();

    // ⚡ 优化：延迟加载数据，避免启动时阻塞
    // 数据将在活动页面显示时按需加载，或由 ensureDataLoaded() 触发
    log('🎬 MeetupStateController 初始化完成（延迟加载模式）');
  }

  /// 设置 SignalR 实时推送监听
  void _setupSignalRListeners() {
    try {
      // 获取或注册 SignalR 服务
      MeetupSignalRService signalRService;
      if (Get.isRegistered<MeetupSignalRService>()) {
        signalRService = Get.find<MeetupSignalRService>();
      } else {
        signalRService = Get.put(MeetupSignalRService(), permanent: true);
      }

      // 连接到 SignalR Hub
      signalRService.connect();

      // 订阅事件 - 接收完整数据，支持单点更新
      _signalRSubscriptions.add(
        signalRService.onMeetupCreated.listen((meetupJson) {
          log('📨 [SignalR] Meetup created with full data');
          _handleSignalRMeetupCreated(meetupJson);
        }),
      );

      _signalRSubscriptions.add(
        signalRService.onMeetupUpdated.listen((meetupJson) {
          log('📨 [SignalR] Meetup updated with full data');
          _handleSignalRMeetupUpdated(meetupJson);
        }),
      );

      _signalRSubscriptions.add(
        signalRService.onMeetupDeleted.listen((meetupId) {
          log('📨 [SignalR] Meetup deleted: $meetupId');
          _handleSignalRMeetupDeleted(meetupId);
        }),
      );

      _signalRSubscriptions.add(
        signalRService.onMeetupCancelled.listen((meetupJson) {
          log('📨 [SignalR] Meetup cancelled with full data');
          _handleSignalRMeetupCancelled(meetupJson);
        }),
      );

      _signalRSubscriptions.add(
        signalRService.onParticipantJoined.listen((event) {
          log('📨 [SignalR] Participant joined: meetup=${event.meetupId}, count=${event.newParticipantCount}');
          _handleSignalRParticipantJoined(event);
        }),
      );

      _signalRSubscriptions.add(
        signalRService.onParticipantLeft.listen((event) {
          log('📨 [SignalR] Participant left: meetup=${event.meetupId}, count=${event.newParticipantCount}');
          _handleSignalRParticipantLeft(event);
        }),
      );

      log('✅ [MeetupStateController] SignalR 监听器设置完成');
    } catch (e) {
      log('⚠️ [MeetupStateController] 设置 SignalR 监听失败: $e');
    }
  }

  /// 处理 SignalR Meetup 创建事件 - 单点添加到列表
  void _handleSignalRMeetupCreated(Map<String, dynamic> meetupJson) {
    try {
      final meetup = MeetupDto.fromJson(meetupJson).toDomain();
      // 检查是否已存在
      if (meetups.any((m) => m.id == meetup.id)) {
        log('📨 [SignalR] Meetup ${meetup.id} already exists, updating instead');
        _updateMeetupInList(meetup);
      } else {
        // 根据当前筛选条件决定是否添加
        if (_shouldShowMeetup(meetup)) {
          meetups.insert(0, meetup); // 新活动插入到列表头部
          meetups.refresh();
          log('✅ [SignalR] Meetup ${meetup.id} added to list');
        } else {
          log('📨 [SignalR] Meetup ${meetup.id} does not match current filter, skipped');
        }
      }
    } catch (e) {
      log('⚠️ [SignalR] Failed to handle MeetupCreated: $e');
      // 失败时回退到刷新整个列表
      refresh();
    }
  }

  /// 处理 SignalR Meetup 更新事件 - 单点更新
  void _handleSignalRMeetupUpdated(Map<String, dynamic> meetupJson) {
    try {
      final meetup = MeetupDto.fromJson(meetupJson).toDomain();
      _updateMeetupInList(meetup);
    } catch (e) {
      log('⚠️ [SignalR] Failed to handle MeetupUpdated: $e');
    }
  }

  /// 处理 SignalR Meetup 删除事件
  void _handleSignalRMeetupDeleted(String meetupId) {
    meetups.removeWhere((m) => m.id == meetupId);
    meetups.refresh();
    log('✅ [SignalR] Meetup $meetupId removed from list');
  }

  /// 处理 SignalR Meetup 取消事件 - 单点更新状态
  void _handleSignalRMeetupCancelled(Map<String, dynamic> meetupJson) {
    try {
      final meetup = MeetupDto.fromJson(meetupJson).toDomain();
      _updateMeetupInList(meetup);
      log('✅ [SignalR] Meetup ${meetup.id} cancelled status updated');
    } catch (e) {
      log('⚠️ [SignalR] Failed to handle MeetupCancelled: $e');
    }
  }

  /// 处理 SignalR 参与者加入事件 - 仅更新参与人数
  void _handleSignalRParticipantJoined(ParticipantChangeEvent event) {
    _updateMeetupParticipantCount(event.meetupId, event.newParticipantCount);
  }

  /// 处理 SignalR 参与者离开事件 - 仅更新参与人数
  void _handleSignalRParticipantLeft(ParticipantChangeEvent event) {
    _updateMeetupParticipantCount(event.meetupId, event.newParticipantCount);
  }

  /// 单点更新：更新列表中的单个 Meetup
  void _updateMeetupInList(Meetup meetup) {
    final index = meetups.indexWhere((m) => m.id == meetup.id);
    if (index != -1) {
      meetups[index] = meetup;
      meetups.refresh();
      log('✅ [SignalR] Meetup ${meetup.id} updated in list at index $index');
    } else {
      log('📨 [SignalR] Meetup ${meetup.id} not found in list');
    }
  }

  /// 单点更新：仅更新 Meetup 的参与人数
  void _updateMeetupParticipantCount(String meetupId, int newCount) {
    final index = meetups.indexWhere((m) => m.id == meetupId);
    if (index != -1) {
      final oldMeetup = meetups[index];
      // 创建新的 Meetup 对象，只更新参与人数
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
        isJoined: oldMeetup.isJoined,
        isOrganizer: oldMeetup.isOrganizer,
      );
      meetups.refresh();
      log('✅ [SignalR] Meetup $meetupId participant count updated to $newCount');
    }
  }

  /// 检查 Meetup 是否应该显示在当前筛选条件下
  bool _shouldShowMeetup(Meetup meetup) {
    // 如果有城市筛选，检查城市是否匹配
    if (currentCityId.value.isNotEmpty && meetup.location.cityId != currentCityId.value) {
      return false;
    }
    // 如果有状态筛选，检查状态是否匹配
    if (currentStatus.value.isNotEmpty && meetup.status.value != currentStatus.value) {
      return false;
    }
    return true;
  }

  /// 取消 SignalR 订阅
  void _cancelSignalRSubscriptions() {
    for (final subscription in _signalRSubscriptions) {
      subscription.cancel();
    }
    _signalRSubscriptions.clear();
    log('✅ [MeetupStateController] SignalR 订阅已取消');
  }

  /// 确保数据已加载（供页面调用）
  /// 如果数据未加载，则触发加载
  Future<void> ensureDataLoaded() async {
    if (meetups.isEmpty && !isLoading.value) {
      log('📦 MeetupStateController: 触发首次数据加载');
      await initialLoad();
    }
  }

  @override
  void onClose() {
    log('👋 MeetupStateController 关闭');
    _cancelSignalRSubscriptions();
    meetups.clear();
    rsvpedMeetupIds.clear();
    currentCityId.value = '';
    currentStatus.value = 'upcoming';
    super.onClose();
  }

  // ==================== 数据加载实现 ====================

  @override
  Future<PaginatedResult> loadPageData(int page, int pageSize) async {
    log('🔄 加载活动列表: 城市=${currentCityId.value}, 状态=${currentStatus.value}, 页码=$page');

    final loadedMeetups = await _getMeetupsUseCase.execute(
      status: currentStatus.value,
      cityId: currentCityId.value.isEmpty ? null : currentCityId.value,
      page: page,
      pageSize: pageSize,
    );

    log('✅ 成功加载 ${loadedMeetups.length} 个活动');

    return PaginatedResult(
      items: loadedMeetups,
      totalCount: loadedMeetups.length,
      hasMore: loadedMeetups.length >= pageSize,
    );
  }

  @override
  Future<void> onPageLoaded(List<dynamic> items, {required bool isRefresh}) async {
    final loadedMeetups = items.cast<Meetup>();

    if (isRefresh) {
      meetups.clear();
    }

    meetups.addAll(loadedMeetups);

    // 同步 RSVP 状态
    _syncRsvpStatus(loadedMeetups);

    log('📊 当前活动总数: ${meetups.length}');
  }

  // ==================== 私有方法 ====================

  /// 设置登录状态监听
  void _setupLoginStateListener() {
    try {
      final authController = Get.find<AuthStateController>();
      ever(authController.isAuthenticated, (isAuth) {
        if (isAuth) {
          log('🔄 用户已登录，刷新活动列表...');
          refresh();
        } else {
          log('👋 用户已退出，清空活动数据');
          meetups.clear();
          rsvpedMeetupIds.clear();
        }
      });
    } catch (e) {
      log('⚠️ 无法找到 AuthStateController: $e');
    }
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    DataEventBus.instance.on('meetup', _handleDataChanged);
    DataEventBus.instance.on('meetup_list', _handleDataChanged);
  }

  /// 处理数据变更事件
  /// 注意：SignalR 推送已经实现了单点更新，这里主要处理本地操作后的同步
  void _handleDataChanged(DataChangedEvent event) {
    log('🔔 收到 Meetup 数据变更通知: ${event.changeType}, entityId: ${event.entityId}');

    switch (event.changeType) {
      case DataChangeType.created:
        // 创建事件：本地 createMeetup 已经直接插入列表，无需再刷新
        // SignalR 推送也已经处理，这里只做日志记录
        log('📝 Meetup 创建事件，列表已更新');
        break;
      case DataChangeType.invalidated:
        // 缓存失效，需要刷新整个列表
        refresh();
        break;
      case DataChangeType.updated:
        // 更新事件：本地 updateMeetup 已经直接更新列表项，无需再调用 API
        // 只触发 UI 刷新
        if (event.entityId != null) {
          log('📝 Meetup 更新事件: ${event.entityId}，列表已更新');
          meetups.refresh(); // 确保 UI 刷新
        }
        break;
      case DataChangeType.deleted:
        if (event.entityId != null) {
          meetups.removeWhere((m) => m.id == event.entityId);
          meetups.refresh();
        }
        break;
    }
  }

  /// 同步 RSVP 状态
  void _syncRsvpStatus(List<Meetup> loadedMeetups) {
    final userController = Get.find<UserStateController>();
    final currentUserId = userController.currentUser.value?.id;

    for (final meetup in loadedMeetups) {
      final shouldBeJoined = meetup.isJoined || (currentUserId != null && meetup.organizer.id == currentUserId);

      if (shouldBeJoined) {
        if (!rsvpedMeetupIds.contains(meetup.id)) {
          rsvpedMeetupIds.add(meetup.id);
        }
      } else {
        rsvpedMeetupIds.remove(meetup.id);
      }
    }

    log('✅ 已同步 ${rsvpedMeetupIds.length} 个已加入的活动');
  }

  /// 刷新单个活动（备用方法，当 SignalR 推送数据不完整时使用）
  /// 目前 SignalR 推送完整数据，此方法暂不使用
  // ignore: unused_element
  Future<void> _refreshSingleMeetup(String meetupId) async {
    try {
      final meetup = await _meetupRepository.getMeetupById(meetupId);
      if (meetup != null) {
        final index = meetups.indexWhere((m) => m.id == meetupId);
        if (index != -1) {
          meetups[index] = meetup;
          meetups.refresh(); // 触发 Obx 更新
        }
      }
    } catch (e) {
      log('⚠️ 刷新单个活动失败: $e');
    }
  }

  /// 检查登录状态
  bool _requireLogin({String action = '此操作'}) {
    try {
      final authController = Get.find<AuthStateController>();
      if (!authController.isAuthenticated.value) {
        AppToast.warning('请先登录后再$action');
        return false;
      }
      return true;
    } catch (e) {
      AppToast.error('无法检查登录状态');
      return false;
    }
  }

  /// 从异常中提取友好的错误消息
  String _extractErrorMessage(dynamic e) {
    if (e is HttpException) {
      return e.message;
    }
    final errorStr = e.toString();
    if (errorStr.startsWith('HttpException: ')) {
      final parts = errorStr.substring('HttpException: '.length).split(' (Status Code:');
      return parts.first;
    }
    return errorStr;
  }

  // ==================== 公共业务方法 ====================

  /// 加载活动列表（兼容旧 API）
  Future<void> loadMeetups({
    String? cityId,
    String? status,
    bool isForceRefresh = false,
  }) async {
    currentCityId.value = cityId ?? '';
    currentStatus.value = status ?? 'upcoming';

    if (isForceRefresh) {
      await forceRefresh();
    } else {
      await initialLoad();
    }
  }

  /// 加载更多活动（使用基类方法）
  Future<void> loadMoreMeetups({
    String? cityId,
    String? status,
  }) async {
    await loadMore();
  }

  /// 按城市获取活动
  Future<List<Meetup>> getMeetupsByCity(String cityName) async {
    try {
      log('🔍 按城市获取活动: $cityName');
      final cityMeetups = await _getMeetupsByCityUseCase.executeByName(
        cityName: cityName,
        status: 'upcoming',
      );
      log('✅ 找到 ${cityMeetups.length} 个活动');
      return cityMeetups;
    } catch (e) {
      log('❌ 按城市获取活动失败: $e');
      return [];
    }
  }

  /// 按城市ID获取活动
  Future<List<Meetup>> getMeetupsByCityId(String cityId) async {
    try {
      log('🔍 按城市ID获取活动: $cityId');
      final cityMeetups = await _getMeetupsByCityUseCase.execute(
        cityId: cityId,
        status: 'upcoming',
      );
      log('✅ 找到 ${cityMeetups.length} 个活动');
      return cityMeetups;
    } catch (e) {
      log('❌ 按城市ID获取活动失败: $e');
      return [];
    }
  }

  /// 创建活动
  Future<Meetup?> createMeetup({
    required String title,
    required String description,
    required String cityId,
    required String venue,
    required String venueAddress,
    required MeetupType type,
    String? eventTypeId,
    required DateTime startTime,
    DateTime? endTime,
    required int maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
  }) async {
    if (!_requireLogin(action: '创建活动')) return null;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      log('🎨 创建活动: $title');

      final newMeetup = await _createMeetupUseCase.execute(
        title: title,
        description: description,
        cityId: cityId,
        venue: venue,
        venueAddress: venueAddress,
        type: type,
        eventTypeId: eventTypeId,
        startTime: startTime,
        endTime: endTime,
        maxAttendees: maxAttendees,
        imageUrl: imageUrl,
        images: images,
        tags: tags,
      );

      meetups.insert(0, newMeetup);

      // 通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'meetup',
        entityId: newMeetup.id,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.created,
      ));

      log('✅ 活动创建成功: ${newMeetup.id}');
      AppToast.success('活动创建成功!');
      return newMeetup;
    } catch (e) {
      errorMessage.value = '创建活动失败: $e';
      log('❌ 创建活动失败: $e');
      AppToast.error('创建活动失败: ${_extractErrorMessage(e)}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新活动
  Future<Meetup?> updateMeetup({
    required String meetupId,
    String? title,
    String? description,
    String? cityId,
    String? venue,
    String? venueAddress,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    int? maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    if (!_requireLogin(action: '更新活动')) return null;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      log('✏️ 更新活动: $meetupId');

      final updatedMeetup = await _updateMeetupUseCase.execute(
        meetupId: meetupId,
        title: title,
        description: description,
        cityId: cityId,
        venue: venue,
        venueAddress: venueAddress,
        category: category,
        startTime: startTime,
        endTime: endTime,
        maxAttendees: maxAttendees,
        imageUrl: imageUrl,
        images: images,
        tags: tags,
        latitude: latitude,
        longitude: longitude,
      );

      final index = meetups.indexWhere((m) => m.id == meetupId);
      if (index != -1) {
        meetups[index] = updatedMeetup;
        meetups.refresh(); // 触发 Obx 更新
      }

      // 通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'meetup',
        entityId: meetupId,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.updated,
      ));

      log('✅ 活动更新成功');
      AppToast.success('活动更新成功!');
      return updatedMeetup;
    } catch (e) {
      errorMessage.value = '更新活动失败: $e';
      log('❌ 更新活动失败: $e');
      AppToast.error('更新活动失败: ${_extractErrorMessage(e)}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// RSVP 参加活动
  Future<bool> rsvpToMeetup(String meetupId) async {
    if (!_requireLogin(action: '报名活动')) return false;

    try {
      log('📝 RSVP 活动: $meetupId');

      final result = await _rsvpToMeetupUseCase.execute(meetupId);
      rsvpedMeetupIds.add(meetupId);

      // 更新本地活动数据
      final index = meetups.indexWhere((m) => m.id == meetupId);
      if (index != -1) {
        final meetup = meetups[index];
        final newCapacity = Capacity(
          maxAttendees: meetup.capacity.maxAttendees,
          currentAttendees: meetup.capacity.currentAttendees + 1,
        );
        meetups[index] = Meetup(
          id: meetup.id,
          title: meetup.title,
          type: meetup.type,
          eventType: meetup.eventType,
          description: meetup.description,
          location: meetup.location,
          venue: meetup.venue,
          schedule: meetup.schedule,
          capacity: newCapacity,
          organizer: meetup.organizer,
          images: meetup.images,
          attendeeIds: meetup.attendeeIds,
          status: meetup.status,
          createdAt: meetup.createdAt,
          isJoined: true,
          isOrganizer: meetup.isOrganizer,
        );

        // 强制刷新列表，确保 UI 更新
        meetups.refresh();
      }

      log('✅ RSVP 成功');
      AppToast.success('报名成功!');
      return result;
    } catch (e) {
      log('❌ RSVP 失败: $e');
      AppToast.error('报名失败: ${_extractErrorMessage(e)}');
      return false;
    }
  }

  /// 取消 RSVP
  Future<bool> cancelRsvp(String meetupId) async {
    if (!_requireLogin(action: '取消报名')) return false;

    try {
      log('🚫 取消 RSVP: $meetupId');

      final result = await _cancelRsvpUseCase.execute(meetupId);
      rsvpedMeetupIds.remove(meetupId);

      // 更新本地活动数据
      final index = meetups.indexWhere((m) => m.id == meetupId);
      if (index != -1) {
        final meetup = meetups[index];
        final newCount = (meetup.capacity.currentAttendees - 1).clamp(0, meetup.capacity.maxAttendees);
        final newCapacity = Capacity(
          maxAttendees: meetup.capacity.maxAttendees,
          currentAttendees: newCount,
        );
        meetups[index] = Meetup(
          id: meetup.id,
          title: meetup.title,
          type: meetup.type,
          eventType: meetup.eventType,
          description: meetup.description,
          location: meetup.location,
          venue: meetup.venue,
          schedule: meetup.schedule,
          capacity: newCapacity,
          organizer: meetup.organizer,
          images: meetup.images,
          attendeeIds: meetup.attendeeIds,
          status: meetup.status,
          createdAt: meetup.createdAt,
          isJoined: false,
          isOrganizer: meetup.isOrganizer,
        );

        // 强制刷新列表，确保 UI 更新
        meetups.refresh();
      }

      log('✅ 取消 RSVP 成功');
      AppToast.success('已取消报名');
      return result;
    } catch (e) {
      log('❌ 取消 RSVP 失败: $e');
      AppToast.error('取消报名失败: ${_extractErrorMessage(e)}');
      return false;
    }
  }

  /// 取消活动
  Future<bool> cancelMeetup(String meetupId) async {
    if (!_requireLogin(action: '取消活动')) return false;

    try {
      log('🚫 取消活动: $meetupId');

      await _cancelMeetupUseCase.execute(meetupId);

      // 更新本地活动状态
      final index = meetups.indexWhere((m) => m.id == meetupId);
      if (index != -1) {
        final meetup = meetups[index];
        meetups[index] = Meetup(
          id: meetup.id,
          title: meetup.title,
          type: meetup.type,
          eventType: meetup.eventType,
          description: meetup.description,
          location: meetup.location,
          venue: meetup.venue,
          schedule: meetup.schedule,
          capacity: meetup.capacity,
          organizer: meetup.organizer,
          images: meetup.images,
          attendeeIds: meetup.attendeeIds,
          status: MeetupStatus.cancelled,
          createdAt: meetup.createdAt,
          isJoined: meetup.isJoined,
          isOrganizer: meetup.isOrganizer,
        );

        // 强制刷新列表，确保 UI 更新
        meetups.refresh();
      }

      // 通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'meetup',
        entityId: meetupId,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.updated,
      ));

      log('✅ 活动取消成功');
      AppToast.success('活动已取消');
      return true;
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败: ${_extractErrorMessage(e)}');
      return false;
    }
  }

  /// 根据ID获取活动详情
  Future<Meetup?> getMeetupById(String meetupId) async {
    try {
      log('🔍 获取活动详情: $meetupId');

      // 先检查本地缓存
      final cached = meetups.firstWhereOrNull((m) => m.id == meetupId);
      if (cached != null) {
        return cached;
      }

      // 从服务器获取
      final meetup = await _meetupRepository.getMeetupById(meetupId);
      return meetup;
    } catch (e) {
      log('❌ 获取活动详情失败: $e');
      return null;
    }
  }

  // ==================== 兼容旧 API ====================

  /// 刷新活动列表 - 兼容原控制器 API
  Future<void> refreshMeetups() async {
    log('🔄 刷新活动列表...');
    await forceRefresh();
  }

  /// 是否有更多数据 - 兼容原控制器
  bool get hasMoreData => hasMore.value;

  /// 邀请用户参加聚会 - 兼容原控制器 API
  Future<bool> inviteToMeetup({
    required String meetupId,
    required String inviteeId,
    String? message,
  }) async {
    try {
      isLoading.value = true;
      log('📨 发送聚会邀请: meetupId=$meetupId, inviteeId=$inviteeId');

      final result = await _meetupRepository.inviteToMeetup(
        meetupId: meetupId,
        inviteeId: inviteeId,
        message: message,
      );

      log('✅ 邀请发送成功: invitationId=${result.id}');
      AppToast.success('邀请已发送');
      return true;
    } catch (e) {
      String errorMsg = _extractErrorMessage(e);
      log('❌ 邀请发送异常: $errorMsg');
      AppToast.error(errorMsg);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
