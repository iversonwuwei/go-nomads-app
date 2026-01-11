import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/infrastructure/models/meetup_dto.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MeetupDetailPageController extends GetxController {
  final Meetup initialMeetup;

  MeetupDetailPageController({required this.initialMeetup});

  // State
  late final Rx<Meetup> meetup;
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> participants = <Map<String, dynamic>>[].obs;
  final RxBool hasDataChanged = false.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool isAdmin = false.obs;

  final PageController imagePageController = PageController();

  late final IMeetupRepository _meetupRepository;
  late final MeetupStateController _meetupController;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  bool get isJoined => _meetupController.isRsvped(meetup.value.id);

  bool get isOrganizer => meetup.value.isOrganizer;

  @override
  void onInit() {
    super.onInit();
    _meetupRepository = Get.find<IMeetupRepository>();
    _meetupController = Get.find<MeetupStateController>();
    meetup = Rx<Meetup>(initialMeetup);
    _setupDataChangeListeners();
    _loadEventDetails();
    _checkAdminStatus();
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

  /// 删除活动（仅管理员）
  Future<bool> deleteMeetup() async {
    try {
      log('🗑️ [MeetupDetailPageController] 删除活动: ${meetup.value.id}');

      final result = await _meetupRepository.deleteMeetup(meetup.value.id);

      if (result) {
        log('✅ [MeetupDetailPageController] 活动删除成功');
        // 通知列表刷新
        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'meetup',
          entityId: meetup.value.id,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: DataChangeType.deleted,
        ));
        return true;
      }
      return false;
    } catch (e) {
      log('❌ [MeetupDetailPageController] 删除异常: $e');
      return false;
    }
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('meetup', _handleDataChanged);
    log('✅ [MeetupDetailPageController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    // 只处理当前活动的变更
    if (event.entityId != meetup.value.id) {
      return;
    }

    log('🔔 [活动详情] 收到数据变更通知: ${event.entityId} (${event.changeType})');

    switch (event.changeType) {
      case DataChangeType.updated:
        // 活动数据更新，重新加载详情
        _loadEventDetails();
        break;
      case DataChangeType.deleted:
        // 活动被删除，可以显示提示或返回列表页
        AppToast.info('该活动已被删除');
        break;
      case DataChangeType.invalidated:
        // 缓存失效，重新加载
        _loadEventDetails();
        break;
      case DataChangeType.created:
        // 新建活动通常不影响详情页
        break;
    }
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();
    _dataChangedSubscription = null;
    imagePageController.dispose();
    super.onClose();
  }

  /// 从后端加载活动详情
  Future<void> loadEventDetails() async => _loadEventDetails();

  Future<void> _loadEventDetails() async {
    try {
      isLoading.value = true;

      final httpService = Get.find<HttpService>();
      final response = await httpService.get('/events/${initialMeetup.id}');
      final data = response.data as Map<String, dynamic>;

      if (data['participants'] != null) {
        final participantsList = data['participants'] as List<dynamic>;
        participants.value = participantsList.map((p) => p as Map<String, dynamic>).toList();
        log('✅ 成功加载 ${participants.length} 位参与者');
      }

      final dto = MeetupDto.fromJson(data);
      final loadedMeetup = dto.toDomain();

      meetup.value = loadedMeetup;
      meetup.refresh();
      log('✅ 成功加载活动详情: ${loadedMeetup.title}, 参与者: ${loadedMeetup.capacity.currentAttendees}');
    } catch (e) {
      log('❌ 加载活动详情失败: $e');
      AppToast.error('加载活动详情失败');
    } finally {
      isLoading.value = false;
    }
  }

  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }

  void markDataChanged() {
    hasDataChanged.value = true;
  }

  Future<void> toggleJoin(BuildContext context) async {
    try {
      final isJoining = !isJoined;

      // 使用 MeetupStateController 的方法，已实现单点更新列表
      bool success;
      if (isJoining) {
        success = await _meetupController.rsvpToMeetup(meetup.value.id);
        log('✅ 成功加入活动: ${meetup.value.title}');
      } else {
        success = await _meetupController.cancelRsvp(meetup.value.id);
        log('✅ 成功退出活动: ${meetup.value.title}');
      }

      if (success) {
        // 本地单点更新详情页数据，而不是重新加载整个详情
        final currentMeetup = meetup.value;
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
          // 添加当前用户到参与者列表
          if (currentUser != null) {
            participants.add({
              'id': currentUser.id,
              'name': currentUser.name,
              'avatarUrl': currentUser.avatar,
            });
          }
        } else {
          // 从参与者列表移除当前用户
          if (currentUser != null) {
            participants.removeWhere((p) => p['id'] == currentUser.id);
          }
        }

        // 强制刷新 UI
        meetup.refresh();

        hasDataChanged.value = true;
        // 无需调用 refreshMeetups()，rsvpToMeetup/cancelRsvp 已经单点更新了列表
      }
    } catch (e) {
      log('❌ 加入/退出活动失败: $e');
      AppToast.error(isJoined ? '退出活动失败' : '加入活动失败');
    }
  }

  Future<void> cancelMeetup(BuildContext context) async {
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
      await _meetupRepository.cancelMeetup(meetup.value.id);
      log('✅ 成功取消活动: ${meetup.value.title}');
      AppToast.success('活动已取消', title: '成功');
      await _loadEventDetails();
      hasDataChanged.value = true;
    } catch (e) {
      log('❌ 取消活动失败: $e');
      AppToast.error('取消活动失败');
    }
  }

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
}
