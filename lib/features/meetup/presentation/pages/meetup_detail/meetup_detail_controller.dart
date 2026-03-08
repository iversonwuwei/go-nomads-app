import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:intl/intl.dart';

/// Meetup 详情页面 Controller
///
/// 遵循 GetX 标准实践:
/// - 使用 GetxController 管理状态
/// - 通过 Binding 注入依赖
/// - 提供响应式状态管理
/// - 使用统一的 NavigationResult 处理返回和数据刷新
class MeetupDetailController extends GetxController {
  // ==================== 依赖注入 ====================
  final IMeetupRepository _meetupRepository;
  final MeetupStateController _meetupStateController;
  final HttpService _httpService;

  MeetupDetailController({
    required IMeetupRepository meetupRepository,
    required MeetupStateController meetupStateController,
    required HttpService httpService,
  })  : _meetupRepository = meetupRepository,
        _meetupStateController = meetupStateController,
        _httpService = httpService;

  // ==================== 响应式状态 ====================

  /// 当前活动数据
  final Rx<Meetup?> meetup = Rx<Meetup?>(null);

  /// 加载状态
  final RxBool isLoading = true.obs;

  /// 参与者列表
  final RxList<Map<String, dynamic>> participants = <Map<String, dynamic>>[].obs;

  /// 数据是否有变更（用于返回时通知列表更新）
  final RxBool hasDataChanged = false.obs;

  /// 当前图片索引
  final RxInt currentImageIndex = 0.obs;

  /// 是否是管理员
  final RxBool isAdmin = false.obs;

  /// 图片轮播控制器
  final PageController imagePageController = PageController();

  /// 防止页面重复初始化触发多次详情请求
  bool _initialized = false;
  String? _requestedMeetupId;

  // ==================== 数据变更订阅 ====================
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  // ==================== 计算属性 ====================

  /// 当前用户是否已加入活动
  bool get isJoined => meetup.value != null && _meetupStateController.isRsvped(meetup.value!.id);

  /// 当前用户是否是组织者
  bool get isOrganizer => meetup.value?.isOrganizer ?? false;

  /// 活动是否已结束
  bool get isEnded => meetup.value?.isEnded ?? false;

  /// 活动是否已取消
  bool get isCancelled => meetup.value?.status == MeetupStatus.cancelled;

  /// 活动是否已满员
  bool get isFull => meetup.value?.capacity.isFull ?? false;

  /// 活动是否即将开始
  bool get isStartingSoon => meetup.value?.isStartingSoon ?? false;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
    _checkAdminStatus();
  }

  @override
  void onClose() {
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    imagePageController.dispose();
    super.onClose();
  }

  // ==================== 初始化方法 ====================

  /// 按需初始化活动数据
  void ensureMeetupLoaded({Meetup? initialMeetup, String? meetupId}) {
    if (initialMeetup != null) {
      if (_initialized && meetup.value?.id == initialMeetup.id) {
        return;
      }
      _initialized = true;
      _requestedMeetupId = initialMeetup.id;
      meetup.value = initialMeetup;
      loadEventDetails();
      return;
    }

    if (meetupId == null || meetupId.isEmpty) {
      return;
    }

    if (_initialized && _requestedMeetupId == meetupId) {
      return;
    }

    _initialized = true;
    _requestedMeetupId = meetupId;
    loadEventDetailsById(meetupId);
  }

  /// 检查管理员状态
  Future<void> _checkAdminStatus() async {
    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final role = await tokenService.getUserRole();
      isAdmin.value = role == 'admin' || role == 'super_admin';
    }
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('meetup', _handleDataChanged);
    log('✅ [MeetupDetailController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    if (meetup.value == null || event.entityId != meetup.value!.id) {
      return;
    }

    log('🔔 [MeetupDetailController] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        loadEventDetails();
        break;
      case DataChangeType.deleted:
        AppToast.info('该活动已被删除');
        break;
      case DataChangeType.invalidated:
        loadEventDetails();
        break;
      case DataChangeType.created:
        break;
    }
  }

  // ==================== 数据加载方法 ====================

  /// 从后端加载活动详情
  Future<void> loadEventDetails() async {
    if (meetup.value == null) return;

    await _loadMeetupFromApi(meetup.value!.id);
  }

  /// 通过活动 id 加载详情
  Future<void> loadEventDetailsById(String meetupId) async {
    await _loadMeetupFromApi(meetupId);
  }

  Future<void> _loadMeetupFromApi(String meetupId) async {
    try {
      isLoading.value = true;

      final response = await _httpService.get('/events/$meetupId');
      final data = response.data as Map<String, dynamic>;

      // 提取参与者列表
      if (data['participants'] != null) {
        final participantsList = data['participants'] as List<dynamic>;
        participants.value = participantsList.map((p) => p as Map<String, dynamic>).toList();
        log('✅ 成功加载 ${participants.length} 位参与者');
      }

      // 映射为 Meetup 实体
      final dto = MeetupDto.fromJson(data);
      final loadedMeetup = dto.toDomain();

      meetup.value = loadedMeetup;
      _requestedMeetupId = loadedMeetup.id;
      meetup.refresh();
      log('✅ 成功加载活动详情: ${loadedMeetup.title}, 参与者: ${loadedMeetup.capacity.currentAttendees}');
    } catch (e) {
      log('❌ 加载活动详情失败: $e');
      AppToast.error('加载活动详情失败');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== 业务操作方法 ====================

  /// 切换加入/退出活动
  Future<void> toggleJoin() async {
    if (meetup.value == null) return;

    try {
      final isJoining = !isJoined;

      // 使用 MeetupStateController 的方法，已实现单点更新列表
      bool success;
      if (isJoining) {
        success = await _meetupStateController.rsvpToMeetup(meetup.value!.id);
        log('✅ 成功加入活动: ${meetup.value!.title}');
      } else {
        success = await _meetupStateController.cancelRsvp(meetup.value!.id);
        log('✅ 成功退出活动: ${meetup.value!.title}');
      }

      if (success) {
        // 本地单点更新详情页数据，而不是重新加载整个详情
        _updateMeetupLocally(isJoining);
        hasDataChanged.value = true;
      }
    } catch (e) {
      log('❌ 加入/退出活动失败: $e');
      AppToast.error(isJoined ? '退出活动失败' : '加入活动失败');
    }
  }

  /// 本地更新 Meetup 数据（单点更新）
  void _updateMeetupLocally(bool isJoining) {
    final currentMeetup = meetup.value!;
    final newCount = isJoining
        ? currentMeetup.capacity.currentAttendees + 1
        : (currentMeetup.capacity.currentAttendees - 1).clamp(0, currentMeetup.capacity.maxAttendees);

    final newCapacity = Capacity(
      maxAttendees: currentMeetup.capacity.maxAttendees,
      currentAttendees: newCount,
    );

    // 创建新的 Meetup 对象，只更新参与人数和加入状态
    meetup.value = Meetup(
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
    final authController = Get.find<AuthStateController>();
    final currentUser = authController.currentUser.value;

    if (isJoining) {
      if (currentUser != null) {
        participants.add({
          'id': currentUser.id,
          'user': {
            'name': currentUser.name,
            'avatar': currentUser.avatar,
          },
          'userId': currentUser.id,
        });
      }
    } else {
      if (currentUser != null) {
        participants.removeWhere((p) => p['userId'] == currentUser.id || p['id'] == currentUser.id);
      }
    }

    meetup.refresh();
    log('📊 更新后数据 - currentAttendees: ${meetup.value!.capacity.currentAttendees}, participants: ${participants.length}');
  }

  /// 取消活动（仅组织者）
  Future<void> cancelMeetup(BuildContext context) async {
    if (meetup.value == null) return;

    final l10n = AppLocalizations.of(context)!;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('取消活动'),
        content: const Text('确定要取消这个活动吗？此操作无法撤销。'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _meetupRepository.cancelMeetup(meetup.value!.id);
      log('✅ 成功取消活动: ${meetup.value!.title}');
      AppToast.success('活动已取消', title: '成功');

      // 本地单点更新状态，而不是重新加载整个详情
      _updateMeetupStatusLocally(MeetupStatus.cancelled);

      hasDataChanged.value = true;
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败');
    }
  }

  /// 本地更新 Meetup 状态（单点更新）
  void _updateMeetupStatusLocally(MeetupStatus newStatus) {
    final currentMeetup = meetup.value!;

    meetup.value = Meetup(
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
      status: newStatus,
      createdAt: currentMeetup.createdAt,
      isJoined: currentMeetup.isJoined,
      isOrganizer: currentMeetup.isOrganizer,
    );

    meetup.refresh();
    log('📊 更新后状态 - status: ${meetup.value!.status.value}');
  }

  /// 删除活动（仅管理员）
  Future<bool> deleteMeetup() async {
    if (meetup.value == null) return false;

    try {
      log('🗑️ [MeetupDetailController] 删除活动: ${meetup.value!.id}');

      final result = await _meetupRepository.deleteMeetup(meetup.value!.id);

      if (result) {
        log('✅ [MeetupDetailController] 活动删除成功');
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'meetup',
          entityId: meetup.value!.id,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: DataChangeType.deleted,
        ));
        return true;
      }
      return false;
    } catch (e) {
      log('❌ [MeetupDetailController] 删除异常: $e');
      return false;
    }
  }

  // ==================== UI 辅助方法 ====================

  /// 图片切换回调
  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }

  /// 格式化日期时间
  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy \'at\' HH:mm').format(dateTime);
  }

  /// 创建基本的 User 实体用于跳转到详情页
  User createBasicUserModel(String id, String name, String? avatarUrl) {
    return User(
      id: id,
      name: name,
      username: name,
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

  // ==================== 统一的返回处理 ====================

  /// 处理返回
  ///
  /// 使用统一的 NavigationResult 模式：
  /// - 如果数据有变更，返回 NavigationResult.updated(meetup)
  /// - 如果数据未变更，返回 NavigationResult.unchanged()
  void handleBack({BuildContext? context}) {
    NavigationUtil.backFromDetail<Meetup>(
      entity: meetup.value,
      hasChanged: hasDataChanged.value,
      context: context,
    );
  }

  /// 删除后返回
  ///
  /// 使用统一的 NavigationResult.deleted 模式
  void handleBackAfterDelete({BuildContext? context}) {
    NavigationUtil.backAfterDelete(
      entityId: meetup.value?.id,
      context: context,
    );
  }

  /// 标记数据已变更
  void markDataChanged() {
    hasDataChanged.value = true;
  }
}
