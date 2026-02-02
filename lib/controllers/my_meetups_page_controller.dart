import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/core/navigation/navigation_result.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// MyMeetupsPage 控制器
///
/// 实现 [IRefreshableList] 接口，与 NavigationUtil 自动集成
class MyMeetupsPageController extends GetxController implements IRefreshableList<Meetup> {
  final IMeetupRepository _meetupRepository = Get.find();

  final RxList<Meetup> meetups = <Meetup>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoadingMore = false.obs;

  final List<Meetup> _createdMeetups = [];
  final List<Meetup> _joinedMeetups = [];
  late final ScrollController scrollController;

  int _joinedPage = 1;
  final int _pageSize = 20;
  bool _hasMoreJoined = true;

  // ==================== IRefreshableList 实现 ====================

  @override
  String getItemId(Meetup item) => item.id;

  @override
  Future<void> refreshList() => refreshAll();

  @override
  void addItem(Meetup item) {
    // 添加到头部并重新合并排序
    _createdMeetups.insert(0, item);
    _mergeMeetups();
  }

  @override
  void updateItem(Meetup item) {
    // 更新创建的活动列表
    final createdIdx = _createdMeetups.indexWhere((m) => m.id == item.id);
    if (createdIdx != -1) {
      _createdMeetups[createdIdx] = item;
    }
    // 更新参与的活动列表
    final joinedIdx = _joinedMeetups.indexWhere((m) => m.id == item.id);
    if (joinedIdx != -1) {
      _joinedMeetups[joinedIdx] = item;
    }
    _mergeMeetups();
  }

  @override
  void removeItemById(String id) {
    _createdMeetups.removeWhere((m) => m.id == id);
    _joinedMeetups.removeWhere((m) => m.id == id);
    meetups.removeWhere((m) => m.id == id);
  }

  // ==================== 生命周期 ====================

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    loadInitialData();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    await refreshAll();
    isLoading.value = false;
  }

  Future<void> refreshAll() async {
    errorMessage.value = '';
    _joinedPage = 1;
    _hasMoreJoined = true;
    _createdMeetups.clear();
    _joinedMeetups.clear();

    try {
      final createdFuture = _meetupRepository.getMyCreatedMeetups();
      final joinedFuture = _meetupRepository.getJoinedMeetups(
        page: _joinedPage,
        pageSize: _pageSize,
      );

      final created = await createdFuture;
      final joined = await joinedFuture;

      _createdMeetups.addAll(created);
      _joinedMeetups.addAll(joined);

      if (joined.length < _pageSize) {
        _hasMoreJoined = false;
      } else {
        _joinedPage += 1;
      }

      _mergeMeetups();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading.value) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMoreJoined();
    }
  }

  Future<void> _loadMoreJoined() async {
    if (isLoadingMore.value || !_hasMoreJoined) return;
    isLoadingMore.value = true;

    try {
      final nextPageMeetups = await _meetupRepository.getJoinedMeetups(
        page: _joinedPage,
        pageSize: _pageSize,
      );

      if (nextPageMeetups.isEmpty) {
        _hasMoreJoined = false;
        return;
      }

      _joinedMeetups.addAll(nextPageMeetups);

      if (nextPageMeetups.length < _pageSize) {
        _hasMoreJoined = false;
      } else {
        _joinedPage += 1;
      }

      _mergeMeetups();
    } catch (_) {
      // 加载失败静默处理
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _mergeMeetups() {
    final Map<String, Meetup> map = {};
    for (final meetup in [..._createdMeetups, ..._joinedMeetups]) {
      map[meetup.id] = meetup;
    }

    final merged = map.values.toList()..sort((a, b) => a.schedule.startTime.compareTo(b.schedule.startTime));

    meetups.assignAll(merged);
  }

  bool get showFooter => isLoadingMore.value && _hasMoreJoined;

  Future<void> cancelMeetup(String meetupId, AppLocalizations l10n) async {
    try {
      await _meetupRepository.cancelMeetup(meetupId);
      AppToast.success(l10n.cancelMeetupSuccess);
      await refreshAll();
    } catch (_) {
      AppToast.error(l10n.cancelMeetupFailed);
    }
  }

  Future<void> leaveMeetup(String meetupId, AppLocalizations l10n) async {
    try {
      await _meetupRepository.cancelRsvp(meetupId);
      AppToast.success(l10n.youLeftMeetup, title: l10n.leftMeetup);
      await refreshAll();
    } catch (_) {
      AppToast.error(l10n.leaveMeetupFailed);
    }
  }

  Color getStatusColor(MeetupStatus status) {
    switch (status) {
      case MeetupStatus.upcoming:
        return Colors.green;
      case MeetupStatus.ongoing:
        return Colors.blue;
      case MeetupStatus.completed:
        return Colors.grey;
      case MeetupStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(MeetupStatus status, AppLocalizations l10n) {
    switch (status) {
      case MeetupStatus.upcoming:
        return l10n.upcoming;
      case MeetupStatus.ongoing:
        return l10n.statusOngoing;
      case MeetupStatus.completed:
        return l10n.past;
      case MeetupStatus.cancelled:
        return l10n.statusCancelled;
      default:
        return l10n.past;
    }
  }
}
