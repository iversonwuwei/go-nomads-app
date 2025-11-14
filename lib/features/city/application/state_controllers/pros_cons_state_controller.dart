import 'package:get/get.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/city_detail.dart';
import '../../domain/repositories/i_city_repository.dart';

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

  /// 加载城市的所有优缺点
  Future<void> loadCityProsCons(String cityId) async {
    await Future.wait([
      loadPros(cityId),
      loadCons(cityId),
    ]);
  }

  /// 加载优点
  Future<void> loadPros(String cityId) async {
    isLoadingPros.value = true;
    error.value = null;

    try {
      print('📡 加载城市优点: $cityId');

      final result = await _repository.getCityProsCons(
        cityId: cityId,
        isPro: true,
      );

      result.fold(
        onSuccess: (pros) {
          prosList.value = pros;
          print('✅ 优点加载成功: ${pros.length} 条');
        },
        onFailure: (err) {
          error.value = err.message;
          print('❌ 优点加载失败: ${err.message}');
        },
      );
    } catch (e) {
      error.value = '加载优点失败: $e';
      print('❌ 异常: $e');
    } finally {
      isLoadingPros.value = false;
    }
  }

  /// 加载缺点
  Future<void> loadCons(String cityId) async {
    isLoadingCons.value = true;
    error.value = null;

    try {
      print('📡 加载城市缺点: $cityId');

      final result = await _repository.getCityProsCons(
        cityId: cityId,
        isPro: false,
      );

      result.fold(
        onSuccess: (cons) {
          consList.value = cons;
          print('✅ 缺点加载成功: ${cons.length} 条');
        },
        onFailure: (err) {
          error.value = err.message;
          print('❌ 缺点加载失败: ${err.message}');
        },
      );
    } catch (e) {
      error.value = '加载缺点失败: $e';
      print('❌ 异常: $e');
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
      print('📡 添加${isPro ? '优点' : '缺点'}: $text');

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
          print('✅ 添加成功');
          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          print('❌ 添加失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '添加失败: $e';
      print('❌ 异常: $e');
      return false;
    } finally {
      isAdding.value = false;
    }
  }

  /// 点赞
  Future<bool> upvote(String id, bool isPro) async {
    return await _vote(id: id, isUpvote: true, isPro: isPro);
  }

  /// 点踩
  Future<bool> downvote(String id, bool isPro) async {
    return await _vote(id: id, isUpvote: false, isPro: isPro);
  }

  /// 内部方法: 投票
  Future<bool> _vote({
    required String id,
    required bool isUpvote,
    required bool isPro,
  }) async {
    isVoting.value = true;
    error.value = null;

    try {
      print('📡 ${isUpvote ? '点赞' : '点踩'}: $id');

      final result = await _repository.voteProsCons(
        id: id,
        isUpvote: isUpvote,
      );

      return result.fold(
        onSuccess: (_) {
          // 更新本地数据
          final list = isPro ? prosList : consList;
          final index = list.indexWhere((item) => item.id == id);

          if (index != -1) {
            final item = list[index];
            final updatedItem = ProsCons(
              id: item.id,
              userId: item.userId,
              cityId: item.cityId,
              text: item.text,
              upvotes: isUpvote ? item.upvotes + 1 : item.upvotes,
              downvotes: !isUpvote ? item.downvotes + 1 : item.downvotes,
              isPro: item.isPro,
              createdAt: item.createdAt,
              updatedAt: DateTime.now(),
            );

            list[index] = updatedItem;
          }

          print('✅ 投票成功');
          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          print('❌ 投票失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '投票失败: $e';
      print('❌ 异常: $e');
      return false;
    } finally {
      isVoting.value = false;
    }
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
      print('📡 删除${isPro ? '优点' : '缺点'}: $id');

      final result = await _repository.deleteProsCons(cityId, id);

      return result.fold(
        onSuccess: (_) {
          // 从本地列表移除
          if (isPro) {
            prosList.removeWhere((item) => item.id == id);
          } else {
            consList.removeWhere((item) => item.id == id);
          }
          print('✅ 删除成功');
          return true;
        },
        onFailure: (err) {
          error.value = err.message;
          print('❌ 删除失败: ${err.message}');
          return false;
        },
      );
    } catch (e) {
      error.value = '删除失败: $e';
      print('❌ 异常: $e');
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
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}
