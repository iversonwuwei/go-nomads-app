import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:go_nomads_app/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/features/weather/presentation/controllers/weather_state_controller.dart';

/// 城市详情页 Binding
///
/// 确保所有共享状态控制器已注册，
/// 并重置它们的页面级别状态以确保数据全新。
class CityDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 验证必需的共享控制器是否已注册
    _ensureRegistered<CityDetailStateController>('CityDetailStateController');
    _ensureRegistered<UserCityContentStateController>('UserCityContentStateController');
    _ensureRegistered<ProsConsStateController>('ProsConsStateController');
    _ensureRegistered<AiStateController>('AiStateController');
    _ensureRegistered<WeatherStateController>('WeatherStateController');
    _ensureRegistered<CoworkingStateController>('CoworkingStateController');
    _ensureRegistered<CityRatingController>('CityRatingController');
    _ensureRegistered<MembershipStateController>('MembershipStateController');

    // 重置共享控制器的页面级状态，确保数据全新加载
    _resetSharedControllerStates();
  }

  /// 验证控制器是否已注册，如果未注册则打印警告
  void _ensureRegistered<T>(String name) {
    if (!Get.isRegistered<T>()) {
      log('⚠️ [CityDetailBinding] $name 未注册，请确保在 DependencyInjection 中注册');
    }
  }

  /// 重置共享控制器的页面级状态
  ///
  /// 共享控制器不会被删除/重建（它们是全局单例），
  /// 但每次进入城市详情页时需要重置它们上一次加载的页面级数据。
  void _resetSharedControllerStates() {
    // 重置 CityDetailStateController 的页面状态
    if (Get.isRegistered<CityDetailStateController>()) {
      final ctrl = Get.find<CityDetailStateController>();
      ctrl.currentTabIndex.value = 0;
      log('🔄 [CityDetailBinding] 已重置 CityDetailStateController 页面状态');
    }
  }
}
