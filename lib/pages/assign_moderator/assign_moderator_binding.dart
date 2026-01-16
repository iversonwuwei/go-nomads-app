import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/user_management/domain/repositories/iuser_management_repository.dart';
import 'package:df_admin_mobile/pages/assign_moderator/assign_moderator_controller.dart';
import 'package:get/get.dart';

/// 指定版主页面绑定
class AssignModeratorBinding extends Bindings {
  @override
  void dependencies() {
    // 从路由参数获取城市信息
    final args = Get.arguments;

    String cityId = '';
    String cityName = '';

    if (args is City) {
      cityId = args.id;
      cityName = args.name;
    } else if (args is Map<String, dynamic>) {
      cityId = args['cityId'] as String? ?? '';
      cityName = args['cityName'] as String? ?? '';
    }

    Get.lazyPut<AssignModeratorController>(
      () => AssignModeratorController(
        cityId: cityId,
        cityName: cityName,
        userManagementRepository: Get.find<IUserManagementRepository>(),
        cityRepository: Get.find<ICityRepository>(),
      ),
    );
  }
}
