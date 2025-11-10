import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_state_controller.dart';
import '../../../user/presentation/controllers/user_state_controller.dart';
import '../../application/use_cases/cancel_meetup_use_case.dart';
import '../../application/use_cases/cancel_rsvp_use_case.dart';
import '../../application/use_cases/create_meetup_use_case.dart';
import '../../application/use_cases/get_meetups_by_city_use_case.dart';
import '../../application/use_cases/get_meetups_use_case.dart';
import '../../application/use_cases/rsvp_to_meetup_use_case.dart';
import '../../domain/entities/meetup.dart';

/// Meetup 状态管理 Controller
/// 从 DataServiceController 迁移活动相关功能
class MeetupStateController extends GetxController {
  // Dependencies
  final GetMeetupsUseCase _getMeetupsUseCase;
  final GetMeetupsByCityUseCase _getMeetupsByCityUseCase;
  final CreateMeetupUseCase _createMeetupUseCase;
  final RsvpToMeetupUseCase _rsvpToMeetupUseCase;
  final CancelRsvpUseCase _cancelRsvpUseCase;
  final CancelMeetupUseCase _cancelMeetupUseCase;

  MeetupStateController({
    required GetMeetupsUseCase getMeetupsUseCase,
    required GetMeetupsByCityUseCase getMeetupsByCityUseCase,
    required CreateMeetupUseCase createMeetupUseCase,
    required RsvpToMeetupUseCase rsvpToMeetupUseCase,
    required CancelRsvpUseCase cancelRsvpUseCase,
    required CancelMeetupUseCase cancelMeetupUseCase,
  })  : _getMeetupsUseCase = getMeetupsUseCase,
        _getMeetupsByCityUseCase = getMeetupsByCityUseCase,
        _createMeetupUseCase = createMeetupUseCase,
        _rsvpToMeetupUseCase = rsvpToMeetupUseCase,
        _cancelRsvpUseCase = cancelRsvpUseCase,
        _cancelMeetupUseCase = cancelMeetupUseCase;

  // State Properties
  final RxList<Meetup> meetups = <Meetup>[].obs;
  final RxList<String> rsvpedMeetupIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs; // 加载更多状态
  final RxString errorMessage = ''.obs;

  // 分页相关
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final int pageSize = 20;

  // Getters

  /// 获取即将到来的活动 (未来30天内)
  List<Meetup> get upcomingMeetups {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    return meetups
        .where((m) =>
            m.status.value != 'cancelled' && // 明确排除已取消的活动
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

  // Methods

  /// 加载活动列表
  Future<void> loadMeetups({
    String? cityId,
    String? status,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && isLoading.value) {
        print('⏸️ 正在加载中,跳过重复请求');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1; // 重置页码
      hasMoreData.value = true; // 重置是否有更多数据

      print('🔄 加载活动列表...');
      print(
          '   cityId: $cityId, status: $status, page: 1, pageSize: $pageSize');

      final loadedMeetups = await _getMeetupsUseCase.execute(
        status: status ?? 'upcoming',
        cityId: cityId,
        page: 1,
        pageSize: pageSize,
      );

      meetups.value = loadedMeetups;

      // 同步 isJoined 状态到 rsvpedMeetupIds
      // 清除现有的 RSVP 列表(可选,根据业务需求)
      // rsvpedMeetupIds.clear();

      print('🔍 开始同步 RSVP 状态...');
      print('   当前 rsvpedMeetupIds: ${rsvpedMeetupIds.toList()}');

      // 获取当前用户 ID
      final userController = Get.find<UserStateController>();
      final currentUserId = userController.currentUser.value?.id;
      print('   当前用户 ID: $currentUserId');

      // 将后端返回的 isJoined=true 的活动添加到 rsvpedMeetupIds
      for (final meetup in loadedMeetups) {
        print(
            '   检查活动: ${meetup.title} (${meetup.id}), isJoined=${meetup.isJoined}, organizerId=${meetup.organizer.id}');

        // 检查是否应该标记为已加入:
        // 1. 后端返回 isJoined=true
        // 2. 用户是活动的组织者(后端可能没有正确返回 isJoined)
        final shouldBeJoined = meetup.isJoined ||
            (currentUserId != null && meetup.organizer.id == currentUserId);

        if (shouldBeJoined) {
          if (!rsvpedMeetupIds.contains(meetup.id)) {
            rsvpedMeetupIds.add(meetup.id);
            print(
                '   ✅ 添加到 rsvpedMeetupIds: ${meetup.title} (${meetup.id})${meetup.organizer.id == currentUserId ? ' [组织者]' : ''}');
          } else {
            print('   ℹ️ 已存在于 rsvpedMeetupIds: ${meetup.title} (${meetup.id})');
          }
        } else {
          // 如果后端返回 isJoined=false 且不是组织者,从列表中移除(如果存在)
          if (rsvpedMeetupIds.contains(meetup.id)) {
            rsvpedMeetupIds.remove(meetup.id);
            print('   🔄 从 rsvpedMeetupIds 移除: ${meetup.title} (${meetup.id})');
          }
        }
      }

      print('✅ 已同步 ${rsvpedMeetupIds.length} 个已加入的活动');
      print('   最终 rsvpedMeetupIds: ${rsvpedMeetupIds.toList()}');

      // 如果返回的数据少于 pageSize，说明没有更多数据了
      if (loadedMeetups.length < pageSize) {
        hasMoreData.value = false;
      }

      print('✅ 加载了 ${loadedMeetups.length} 个活动');
    } catch (e) {
      errorMessage.value = '加载活动失败: $e';
      print('❌ 加载活动失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多活动
  Future<void> loadMoreMeetups({
    String? cityId,
    String? status,
  }) async {
    // 如果已经在加载或没有更多数据，直接返回
    if (isLoadingMore.value || !hasMoreData.value) {
      print(
          '⏸️ 跳过加载更多: isLoadingMore=${isLoadingMore.value}, hasMoreData=${hasMoreData.value}');
      return;
    }

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      print('🔄 加载更多活动...');
      print(
          '   cityId: $cityId, status: $status, page: $nextPage, pageSize: $pageSize');

      final moreMeetups = await _getMeetupsUseCase.execute(
        status: status ?? 'upcoming',
        cityId: cityId,
        page: nextPage,
        pageSize: pageSize,
      );

      if (moreMeetups.isNotEmpty) {
        meetups.addAll(moreMeetups);
        currentPage.value = nextPage;

        print('🔍 开始同步更多活动的 RSVP 状态...');

        // 获取当前用户 ID
        final userController = Get.find<UserStateController>();
        final currentUserId = userController.currentUser.value?.id;

        // 同步新加载活动的 isJoined 状态到 rsvpedMeetupIds
        for (final meetup in moreMeetups) {
          print(
              '   检查活动: ${meetup.title} (${meetup.id}), isJoined=${meetup.isJoined}, organizerId=${meetup.organizer.id}');

          // 检查是否应该标记为已加入:
          // 1. 后端返回 isJoined=true
          // 2. 用户是活动的组织者(后端可能没有正确返回 isJoined)
          final shouldBeJoined = meetup.isJoined ||
              (currentUserId != null && meetup.organizer.id == currentUserId);

          if (shouldBeJoined) {
            if (!rsvpedMeetupIds.contains(meetup.id)) {
              rsvpedMeetupIds.add(meetup.id);
              print(
                  '   ✅ 添加到 rsvpedMeetupIds: ${meetup.title} (${meetup.id})${meetup.organizer.id == currentUserId ? ' [组织者]' : ''}');
            } else {
              print(
                  '   ℹ️ 已存在于 rsvpedMeetupIds: ${meetup.title} (${meetup.id})');
            }
          } else {
            if (rsvpedMeetupIds.contains(meetup.id)) {
              rsvpedMeetupIds.remove(meetup.id);
              print(
                  '   🔄 从 rsvpedMeetupIds 移除: ${meetup.title} (${meetup.id})');
            }
          }
        }

        print('✅ 同步完成,当前共 ${rsvpedMeetupIds.length} 个已加入的活动');

        // 如果返回的数据少于 pageSize，说明没有更多数据了
        if (moreMeetups.length < pageSize) {
          hasMoreData.value = false;
        }

        print('✅ 加载了更多 ${moreMeetups.length} 个活动，当前总数: ${meetups.length}');
      } else {
        hasMoreData.value = false;
        print('✅ 没有更多活动了');
      }
    } catch (e) {
      print('❌ 加载更多活动失败: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 按城市获取活动
  Future<List<Meetup>> getMeetupsByCity(String cityName) async {
    try {
      print('🔍 按城市获取活动: $cityName');

      final cityMeetups = await _getMeetupsByCityUseCase.executeByName(
        cityName: cityName,
        status: 'upcoming',
      );

      print('✅ 找到 ${cityMeetups.length} 个活动');
      return cityMeetups;
    } catch (e) {
      print('❌ 按城市获取活动失败: $e');
      return [];
    }
  }

  /// 按城市ID获取活动
  Future<List<Meetup>> getMeetupsByCityId(String cityId) async {
    try {
      print('🔍 按城市ID获取活动: $cityId');

      final cityMeetups = await _getMeetupsByCityUseCase.execute(
        cityId: cityId,
        status: 'upcoming',
      );

      print('✅ 找到 ${cityMeetups.length} 个活动');
      return cityMeetups;
    } catch (e) {
      print('❌ 按城市ID获取活动失败: $e');
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
    required DateTime startTime,
    DateTime? endTime,
    required int maxAttendees,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      // 检查登录状态
      if (!_requireLogin(action: '创建活动')) {
        return null;
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('🎨 创建活动: $title');

      final newMeetup = await _createMeetupUseCase.execute(
        title: title,
        description: description,
        cityId: cityId,
        venue: venue,
        venueAddress: venueAddress,
        type: type,
        startTime: startTime,
        endTime: endTime,
        maxAttendees: maxAttendees,
        imageUrl: imageUrl,
        images: images,
        tags: tags,
      );

      // 添加到列表
      meetups.insert(0, newMeetup);

      // 创建者自动 RSVP
      rsvpedMeetupIds.add(newMeetup.id);

      print('✅ 活动创建成功: ${newMeetup.id}');
      Get.snackbar(
        '成功',
        '活动创建成功!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return newMeetup;
    } catch (e) {
      errorMessage.value = '创建活动失败: $e';
      print('❌ 创建活动失败: $e');
      Get.snackbar(
        '错误',
        '创建活动失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换 RSVP 状态
  Future<void> toggleRsvp(String meetupId) async {
    try {
      // 检查登录状态
      if (!_requireLogin(action: 'RSVP活动')) {
        return;
      }

      final isCurrentlyRsvped = rsvpedMeetupIds.contains(meetupId);

      print(
          '🔄 切换 RSVP: $meetupId (当前: ${isCurrentlyRsvped ? "已RSVP" : "未RSVP"})');

      bool success;
      if (isCurrentlyRsvped) {
        // 取消 RSVP
        success = await _cancelRsvpUseCase.execute(meetupId);
        if (success) {
          rsvpedMeetupIds.remove(meetupId);
          _updateAttendeeCount(meetupId, -1);
          print('✅ 已取消 RSVP');
        }
      } else {
        // RSVP
        success = await _rsvpToMeetupUseCase.execute(meetupId);
        if (success) {
          rsvpedMeetupIds.add(meetupId);
          _updateAttendeeCount(meetupId, 1);
          print('✅ RSVP 成功');
        }
      }
    } catch (e) {
      print('❌ 切换 RSVP 失败: $e');

      // 特殊处理:如果后端返回"已经参加"错误,说明状态不同步,需要修正
      final errorMessage = e.toString();
      if (errorMessage.contains('已经参加') ||
          errorMessage.contains('already joined')) {
        // 后端说已经参加了,但前端认为没参加,修正状态
        if (!rsvpedMeetupIds.contains(meetupId)) {
          rsvpedMeetupIds.add(meetupId);
          print('🔄 修正 RSVP 状态: 已将 $meetupId 标记为已参加');
        }
        Get.snackbar(
          '提示',
          '您已经参加了这个活动',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (errorMessage.contains('未参加') ||
          errorMessage.contains('not joined')) {
        // 后端说未参加,但前端认为参加了,修正状态
        if (rsvpedMeetupIds.contains(meetupId)) {
          rsvpedMeetupIds.remove(meetupId);
          print('🔄 修正 RSVP 状态: 已将 $meetupId 标记为未参加');
        }
        Get.snackbar(
          '提示',
          '您还未参加这个活动',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // 其他错误,显示错误信息
        Get.snackbar(
          '错误',
          'RSVP 操作失败: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// 取消活动 (组织者专用)
  Future<bool> cancelMeetup(String meetupId) async {
    try {
      // 检查登录状态
      if (!_requireLogin(action: '取消活动')) {
        return false;
      }

      print('🔄 取消活动: $meetupId');

      final success = await _cancelMeetupUseCase.execute(meetupId);

      if (success) {
        // 更新本地状态 - 将活动标记为已取消
        final index = meetups.indexWhere((m) => m.id == meetupId);
        if (index != -1) {
          final meetup = meetups[index];
          final updatedMeetup = Meetup(
            id: meetup.id,
            title: meetup.title,
            type: meetup.type,
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
          meetups[index] = updatedMeetup;
        }

        print('✅ 活动已取消');
        Get.snackbar(
          '成功',
          '活动已取消',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }

      return false;
    } catch (e) {
      print('❌ 取消活动失败: $e');
      Get.snackbar(
        '错误',
        '取消活动失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// 刷新活动列表
  Future<void> refreshMeetups() async {
    print('🔄 刷新活动列表...');
    await loadMeetups(forceRefresh: true);
  }

  // Private Methods

  /// 更新参与人数
  void _updateAttendeeCount(String meetupId, int delta) {
    final index = meetups.indexWhere((m) => m.id == meetupId);
    if (index != -1) {
      final meetup = meetups[index];
      final newCount = meetup.capacity.currentAttendees + delta;

      // 创建新的 Capacity
      final updatedCapacity = Capacity(
        maxAttendees: meetup.capacity.maxAttendees,
        currentAttendees: newCount < 0 ? 0 : newCount,
      );

      // 创建新的 Meetup
      final updatedMeetup = Meetup(
        id: meetup.id,
        title: meetup.title,
        type: meetup.type,
        description: meetup.description,
        location: meetup.location,
        venue: meetup.venue,
        schedule: meetup.schedule,
        capacity: updatedCapacity,
        organizer: meetup.organizer,
        images: meetup.images,
        attendeeIds: meetup.attendeeIds,
        status: meetup.status,
        createdAt: meetup.createdAt,
      );

      meetups[index] = updatedMeetup;
      print('📊 更新参与人数: $newCount/${meetup.capacity.maxAttendees}');
    }
  }

  /// 检查登录状态
  bool _requireLogin({String? action}) {
    try {
      final authController = Get.find<AuthStateController>();
      if (!authController.isAuthenticated.value) {
        final actionText = action ?? '此操作';
        print('⚠️ 需要登录: $actionText');
        Get.snackbar(
          '需要登录',
          '请先登录后再$actionText',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
      return true;
    } catch (e) {
      print('⚠️ 无法检查登录状态: $e');
      return false;
    }
  }

  /// 设置登录状态监听
  void _setupLoginStateListener() {
    try {
      final userController = Get.find<UserStateController>();

      // 监听 currentUser 变化
      ever(userController.currentUser, (user) {
        if (user != null) {
          print('👤 用户已登录,刷新活动数据...');
          refreshMeetups();
        } else {
          print('👤 用户已登出,清空活动数据...');
          _clearData();
        }
      });
    } catch (e) {
      print('⚠️ 无法设置登录状态监听: $e');
    }
  }

  /// 清空数据
  void _clearData() {
    meetups.clear();
    rsvpedMeetupIds.clear();
    errorMessage.value = '';
    print('🧹 活动数据已清空');
  }

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    print('🎬 MeetupStateController 初始化...');

    // 设置登录状态监听
    _setupLoginStateListener();

    // 不在这里自动加载，由页面决定何时加载
    // loadMeetups();
  }

  @override
  void onClose() {
    print('👋 MeetupStateController 关闭');
    super.onClose();
  }
}
