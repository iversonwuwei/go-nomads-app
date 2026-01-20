import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/data_sync_service.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_detail.dart';
import 'package:go_nomads_app/features/city/domain/repositories/i_city_repository.dart';

/// ProsCons State Controller - 城市优缺点状态管理
///
/// 负责管理城市优缺点的加载、添加和投票功能
class ProsConsStateController extends GetxController {
  final ICityRepository _repository;

  ProsConsStateController(this._repository);

  // 优点列表
  final RxList<ProsCons> prosList = <ProsCons>[].obs;

  // 缺点列表
  final RxList<ProsCons> consList = <ProsCons>[].obs;

  // 加载状态
  final RxBool isLoadingPros = false.obs;
  final RxBool isLoadingCons = false.obs;
  final RxBool isAdding = false.obs;
  final RxBool isVoting = false.obs;

  // 错误信息
  final RxnString error = RxnString();

  // 记录当前会话用户已投票的条目（仅用于会话内跟踪新投票）
  final RxSet<String> votedItemIds = <String>{}.obs;

  // 当前加载的城市ID
  String? _currentCityId;

  // 数据变更订阅
  StreamSubscription<DataChangedEvent>? _dataChangedSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupDataChangeListeners();
  }

  /// 设置数据变更监听器
  void _setupDataChangeListeners() {
    _dataChangedSubscription = DataEventBus.instance.on('city_pros_cons', _handleDataChanged);
    log('✅ [ProsConsStateController] 数据变更监听器已设置');
  }

  /// 处理数据变更事件
  void _handleDataChanged(DataChangedEvent event) {
    log('🔔 [ProsCons] 收到数据变更通知: ${event.changeType}, cityId: ${event.entityId}');

    // 只处理当前城市的变更
    if (event.entityId != null && event.entityId == _currentCityId) {
      switch (event.changeType) {
        case DataChangeType.created:
        case DataChangeType.updated:
        case DataChangeType.invalidated:
          // 重新加载优缺点列表
          loadCityProsCons(event.entityId!);
          break;
        case DataChangeType.deleted:
          // 删除操作已在本地处理
          break;
      }
    }
  }

  /// 检查用户是否已投票（优先使用后端返回的状态，其次使用会话状态）
  bool hasUserVoted(String id) {
    // 先检查会话内状态
    if (votedItemIds.contains(id)) return true;

    // 再检查后端返回的状态
    final item = _findItemById(id);
    return item?.currentUserVoted == true;
  }

  /// 根据 ID 查找条目
  ProsCons? _findItemById(String id) {
    try {
      return prosList.firstWhere((item) => item.id == id);
    } catch (_) {
      try {
        return consList.firstWhere((item) => item.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// 检查用户是否已登录
  bool _isUserLoggedIn() {
    try {
      final authController = Get.find<AuthStateController>();
      return authController.isAuthenticated.value;
    } catch (e) {
      return false;
    }
  }

  /// 加载城市的所有优缺点
  Future<void> loadCityProsCons(String cityId) async {
    // 如果用户未登录,跳过加载
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载优缺点');
      return;
    }

    // 记录当前城市ID
    _currentCityId = cityId;

    await Future.wait([
      loadPros(cityId),
      loadCons(cityId),
    ]);
  }

  /// 加载优点
  Future<void> loadPros(String cityId) async {
    // 如果用户未登录,跳过加载
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载优点');
      return;
    }

    isLoadingPros.value = true;
    error.value = null;
    prosList.clear(); // 先清空旧数据

    try {
      log('📡 加载城市优点: $cityId');

      final result = await _repository.getCityProsCons(
        cityId: cityId,
        isPro: true,
      );

      result.fold(
        onSuccess: (pros) {
          prosList.value = pros;
          log('✅ 优点加载成功: ${pros.length} 条');
        },
        onFailure: (err) {
          error.value = err.message;
          log('❌ 优点加载失败: ${err.message}');
        },
      );
    } catch (e) {
      error.value = '加载优点失败: $e';
      log('❌ 异常: $e');
    } finally {
      isLoadingPros.value = false;
    }
  }

  /// 加载缺点
  Future<void> loadCons(String cityId) async {
    // 如果用户未登录,跳过加载
    if (!_isUserLoggedIn()) {
      log('⚠️ 用户未登录,跳过加载缺点');
      return;
    }

    isLoadingCons.value = true;
    error.value = null;
    consList.clear(); // 先清空旧数据

    try {
      log('📡 加载城市缺点: $cityId');

      final result = await _repository.getCityProsCons(
        cityId: cityId,
        isPro: false,
      );

      result.fold(
        onSuccess: (cons) {
          consList.value = cons;
          log('✅ 缺点加载成功: ${cons.length} 条');
        },
        onFailure: (err) {
          error.value = err.message;
          log('❌ 缺点加载失败: ${err.message}');
        },
      );
    } catch (e) {
      error.value = '加载缺点失败: $e';
      log('❌ 异常: $e');
    } finally {
      isLoadingCons.value = false;
    }
  }

  /// 添加优点
  Future<bool> addPros({
    required String cityId,
    required String text,
  }) async {
    return await _addProsCons(
      cityId: cityId,
      text: text,
      isPro: true,
    );
  }

  /// 添加缺点
  Future<bool> addCons({
    required String cityId,
    required String text,
  }) async {
    return await _addProsCons(
      cityId: cityId,
      text: text,
      isPro: false,
    );
  }

  /// 内部方法: 添加优缺点
  Future<bool> _addProsCons({
    required String cityId,
    required String text,
    required bool isPro,
  }) async {
    if (text.trim().isEmpty) {
      error.value = '内容不能为空';
      return false;
    }

    isAdding.value = true;
    error.value = null;

    try {
      log('📡 添加${isPro ? '优点' : '缺点'}: $text');

      final result = await _repository.addProsCons(
        cityId: cityId,
        text: text,
        isPro: isPro,
      );

      return result.fold(
        onSuccess: (newItem) {
          // 添加到对应列表
          if (isPro) {
            prosList.insert(0, newItem);
          } else {
            consList.insert(0, newItem);
          }
          log('✅ 添加成功');

          // 发送数据变更事件通知其他组件
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'city_pros_cons',
            entityId: cityId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.created,
          ));
          log('✅ [ProsCons] 已发送数据变更事件');

          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          log('❌ 添加失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '添加失败: $e';
      log('❌ 异常: $e');
      return false;
    } finally {
      isAdding.value = false;
    }
  }

  /// 点赞（toggle 机制：已投票则取消，未投票则新增）
  Future<bool> upvote(String id, bool isPro) async {
    return await _vote(id: id, isUpvote: true, isPro: isPro);
  }

  /// 点踩
  Future<bool> downvote(String id, bool isPro) async {
    return await _vote(id: id, isUpvote: false, isPro: isPro);
  }

  /// 内部方法: 投票（toggle 机制）
  Future<bool> _vote({
    required String id,
    required bool isUpvote,
    required bool isPro,
  }) async {
    isVoting.value = true;
    error.value = null;

    // 判断是投票还是取消投票
    final wasVoted = hasUserVoted(id);

    try {
      log('📡 ${wasVoted ? '取消投票' : (isUpvote ? '点赞' : '点踩')}: $id');

      final result = await _repository.voteProsCons(
        id: id,
        isUpvote: isUpvote,
      );

      return result.fold(
        onSuccess: (_) {
          // 投票成功，更新本地状态
          _updateLocalVoteState(id: id, isPro: isPro, wasVoted: wasVoted, isUpvote: isUpvote);
          log('✅ ${wasVoted ? '取消投票' : '投票'}成功');
          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          log('❌ 投票失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '投票失败: $e';
      log('❌ 异常: $e');
      return false;
    } finally {
      isVoting.value = false;
    }
  }

  /// 更新本地投票状态（乐观更新）
  void _updateLocalVoteState({
    required String id,
    required bool isPro,
    required bool wasVoted,
    required bool isUpvote,
  }) {
    final list = isPro ? prosList : consList;
    final index = list.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final oldItem = list[index];

    if (wasVoted) {
      // 取消投票：减少投票数，从 votedItemIds 移除
      votedItemIds.remove(id);
      final newUpvotes = isUpvote ? (oldItem.upvotes - 1).clamp(0, 999999) : oldItem.upvotes;
      final newDownvotes = !isUpvote ? (oldItem.downvotes - 1).clamp(0, 999999) : oldItem.downvotes;

      final updatedItem = ProsCons(
        id: oldItem.id,
        userId: oldItem.userId,
        cityId: oldItem.cityId,
        text: oldItem.text,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
        isPro: oldItem.isPro,
        createdAt: oldItem.createdAt,
        updatedAt: oldItem.updatedAt,
        currentUserVoted: null, // 取消投票后设为 null
      );
      list[index] = updatedItem;
    } else {
      // 新增投票：增加投票数，添加到 votedItemIds
      votedItemIds.add(id);
      final newUpvotes = isUpvote ? oldItem.upvotes + 1 : oldItem.upvotes;
      final newDownvotes = !isUpvote ? oldItem.downvotes + 1 : oldItem.downvotes;

      final updatedItem = ProsCons(
        id: oldItem.id,
        userId: oldItem.userId,
        cityId: oldItem.cityId,
        text: oldItem.text,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
        isPro: oldItem.isPro,
        createdAt: oldItem.createdAt,
        updatedAt: oldItem.updatedAt,
        currentUserVoted: isUpvote, // 设置投票状态
      );
      list[index] = updatedItem;
    }

    // 触发响应式更新
    list.refresh();
  }

  /// 获取热门优点 (按投票数排序)
  List<ProsCons> get popularPros {
    final sorted = List<ProsCons>.from(prosList);
    sorted.sort((a, b) => b.netVotes.compareTo(a.netVotes));
    return sorted;
  }

  /// 获取热门缺点 (按投票数排序)
  List<ProsCons> get popularCons {
    final sorted = List<ProsCons>.from(consList);
    sorted.sort((a, b) => b.netVotes.compareTo(a.netVotes));
    return sorted;
  }

  /// 删除优缺点(逻辑删除)
  Future<bool> deleteProsCons(String cityId, String id, bool isPro) async {
    isAdding.value = true;
    error.value = null;

    try {
      log('📡 删除${isPro ? '优点' : '缺点'}: $id');

      final result = await _repository.deleteProsCons(cityId, id);

      return result.fold(
        onSuccess: (_) {
          // 从本地列表移除
          if (isPro) {
            prosList.removeWhere((item) => item.id == id);
          } else {
            consList.removeWhere((item) => item.id == id);
          }
          log('✅ 删除成功');

          // 发送数据变更事件通知其他组件
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'city_pros_cons',
            entityId: cityId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.deleted,
          ));
          log('✅ [ProsCons] 已发送删除数据变更事件');

          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          log('❌ 删除失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '删除失败: $e';
      log('❌ 异常: $e');
      return false;
    } finally {
      isAdding.value = false;
    }
  }

  /// 清空数据
  void clearData() {
    prosList.clear();
    consList.clear();
    error.value = null;
    votedItemIds.clear();
  }

  @override
  void onClose() {
    // 取消数据变更订阅
    _dataChangedSubscription?.cancel();

    // 清空所有响应式变量
    prosList.clear();
    consList.clear();

    // 重置加载状态
    isLoadingPros.value = false;
    isLoadingCons.value = false;
    isAdding.value = false;
    isVoting.value = false;

    // 清空错误信息
    error.value = null;
    votedItemIds.clear();

    super.onClose();
  }
}
