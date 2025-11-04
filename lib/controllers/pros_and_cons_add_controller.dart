import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/city_detail_model.dart';
import '../services/city_api_service.dart';
import '../widgets/app_toast.dart';

/// Pros & Cons 添加页面的 Controller
class ProsAndConsAddController extends GetxController {
  final String cityId;
  final String cityName;

  ProsAndConsAddController({
    required this.cityId,
    required this.cityName,
  });

  // API 服务
  final _cityApi = CityApiService();

  // 文本输入控制器
  final TextEditingController prosTextController = TextEditingController();
  final TextEditingController consTextController = TextEditingController();

  // 数据列表
  final RxList<ProsCons> prosList = <ProsCons>[].obs;
  final RxList<ProsCons> consList = <ProsCons>[].obs;

  // 加载状态
  final RxBool isLoadingPros = false.obs;
  final RxBool isLoadingCons = false.obs;
  final RxBool isAddingPros = false.obs;
  final RxBool isAddingCons = false.obs;

  // 是否有变更
  final RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProsCons();
  }

  @override
  void onClose() {
    prosTextController.dispose();
    consTextController.dispose();
    super.onClose();
  }

  /// 加载 Pros & Cons 数据
  Future<void> loadProsCons() async {
    isLoadingPros.value = true;
    isLoadingCons.value = true;

    try {
      print('📡 加载城市 Pros & Cons: $cityId');

      // 并行加载优点和挑战
      final results = await Future.wait([
        _cityApi.getCityProsCons(cityId: cityId, isPro: true),
        _cityApi.getCityProsCons(cityId: cityId, isPro: false),
      ]);

      prosList.value = results[0];
      consList.value = results[1];

      print('✅ 加载完成: ${prosList.length} 优点, ${consList.length} 挑战');
    } catch (e) {
      print('❌ 加载失败: $e');
      AppToast.error('加载失败');
    } finally {
      isLoadingPros.value = false;
      isLoadingCons.value = false;
    }
  }

  /// 添加优点
  Future<void> addPros() async {
    final text = prosTextController.text.trim();
    if (text.isEmpty) {
      AppToast.warning('请输入优点内容');
      return;
    }

    isAddingPros.value = true;

    try {
      print('➕ 添加优点: $text');

      // 调用后端 API 添加
      final result = await _cityApi.addProsCons(
        cityId: cityId,
        text: text,
        isPro: true,
      );

      prosList.insert(0, result);
      prosTextController.clear();
      hasChanges.value = true;

      AppToast.success('添加成功');
      print('✅ 优点添加成功');
    } catch (e) {
      print('❌ 添加失败: $e');
      AppToast.error('添加失败');
    } finally {
      isAddingPros.value = false;
    }
  }

  /// 添加挑战
  Future<void> addCons() async {
    final text = consTextController.text.trim();
    if (text.isEmpty) {
      AppToast.warning('请输入挑战内容');
      return;
    }

    isAddingCons.value = true;

    try {
      print('➕ 添加挑战: $text');

      // 调用后端 API 添加
      final result = await _cityApi.addProsCons(
        cityId: cityId,
        text: text,
        isPro: false,
      );

      consList.insert(0, result);
      consTextController.clear();
      hasChanges.value = true;

      AppToast.success('添加成功');
      print('✅ 挑战添加成功');
    } catch (e) {
      print('❌ 添加失败: $e');
      AppToast.error('添加失败');
    } finally {
      isAddingCons.value = false;
    }
  }
}
