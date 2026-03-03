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
/// 所有过滤（joined+created, 去重, 仅 upcoming/ongoing）由服务端完成
class MyMeetupsPageController extends GetxController implements IRefreshableList<Meetup> {
  final IMeetupRepository _meetupRepository = Get.find();

  final RxList<Meetup> meetups = <Meetup>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoadingMore = false.obs;

  late final ScrollController scrollController;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  // ==================== IRefreshableList 实现 ====================

  @override
  String getItemId(Meetup item) => item.id;

  @override
  Future<void> refreshList() => refreshAll();

  @override
  void addItem(Meetup item) {
    // 新建活动后插入头部
    meetups.insert(0, item);
  }

  @override
  void updateItem(Meetup item) {
    final idx = meetups.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      meetups[idx] = item;
    }
  }

  @override
  void removeItemById(String id) {
    meetups.removeWhere((m) => m.id == id);
  }

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
    _currentPage = 1;
    _hasMore = true;

    try {
      // 服务端已完成过滤：joined + created 合并去重，仅返回 upcoming/ongoing
      final result = await _meetupRepository.getJoinedMeetups(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (result.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage += 1;
      }

      meetups.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading.value) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value || !_hasMore) return;
    isLoadingMore.value = true;

    try {
      final nextPageMeetups = await _meetupRepository.getJoinedMeetups(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (nextPageMeetups.isEmpty) {
        _hasMore = false;
        return;
      }

      meetups.addAll(nextPageMeetups);

      if (nextPageMeetups.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage += 1;
      }
    } catch (_) {
      // 加载失败静默处理
    } finally {
      isLoadingMore.value = false;
    }
  }

  bool get showFooter => isLoadingMore.value && _hasMore;

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
