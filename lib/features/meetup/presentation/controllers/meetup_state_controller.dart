import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_state_controller.dart';
import '../../../user/presentation/controllers/user_state_controller.dart';
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

  MeetupStateController({
    required GetMeetupsUseCase getMeetupsUseCase,
    required GetMeetupsByCityUseCase getMeetupsByCityUseCase,
    required CreateMeetupUseCase createMeetupUseCase,
    required RsvpToMeetupUseCase rsvpToMeetupUseCase,
    required CancelRsvpUseCase cancelRsvpUseCase,
  })  : _getMeetupsUseCase = getMeetupsUseCase,
        _getMeetupsByCityUseCase = getMeetupsByCityUseCase,
        _createMeetupUseCase = createMeetupUseCase,
        _rsvpToMeetupUseCase = rsvpToMeetupUseCase,
        _cancelRsvpUseCase = cancelRsvpUseCase;

  // State Properties
  final RxList<Meetup> meetups = <Meetup>[].obs;
  final RxList<String> rsvpedMeetupIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters

  /// 获取即将到来的活动 (未来30天内)
  List<Meetup> get upcomingMeetups {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    return meetups
        .where((m) =>
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

      print('🔄 加载活动列表...');
      print('   cityId: $cityId, status: $status');

      final loadedMeetups = await _getMeetupsUseCase.execute(
        status: status ?? 'upcoming',
        cityId: cityId,
      );

      meetups.value = loadedMeetups;
      print('✅ 加载了 ${loadedMeetups.length} 个活动');
    } catch (e) {
      errorMessage.value = '加载活动失败: $e';
      print('❌ 加载活动失败: $e');
    } finally {
      isLoading.value = false;
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
      Get.snackbar(
        '错误',
        'RSVP 操作失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

    // 加载初始数据
    loadMeetups();
  }

  @override
  void onClose() {
    print('👋 MeetupStateController 关闭');
    super.onClose();
  }
}
