import 'dart:developer';

import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:go_nomads_app/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/features/weather/presentation/controllers/weather_state_controller.dart';
import 'package:get/get.dart';

/// 城市详情页 Binding
///
/// 此 Binding 主要用于验证依赖是否已在全局注入模块中注册
/// 所有状态控制器应在 app 启动时由 DependencyInjection 注册
class CityDetailBinding extends Bindings {
  @override
  void dependencies() {
    // 验证必需的控制器是否已注册
    _ensureRegistered<CityDetailStateController>('CityDetailStateController');
    _ensureRegistered<UserCityContentStateController>('UserCityContentStateController');
    _ensureRegistered<ProsConsStateController>('ProsConsStateController');
    _ensureRegistered<AiStateController>('AiStateController');
    _ensureRegistered<WeatherStateController>('WeatherStateController');
    _ensureRegistered<CoworkingStateController>('CoworkingStateController');
    _ensureRegistered<CityRatingController>('CityRatingController');
    _ensureRegistered<MembershipStateController>('MembershipStateController');
  }

  /// 验证控制器是否已注册，如果未注册则打印警告
  void _ensureRegistered<T>(String name) {
    if (!Get.isRegistered<T>()) {
      log('⚠️ [CityDetailBinding] $name 未注册，请确保在 DependencyInjection 中注册');
    }
  }
}
