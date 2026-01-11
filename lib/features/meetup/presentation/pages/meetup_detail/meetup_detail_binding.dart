import 'package:df_admin_mobile/features/meetup/domain/repositories/i_meetup_repository.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:df_admin_mobile/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:get/get.dart';

/// MeetupDetail 页面的依赖绑定
///
/// 遵循 GetX Binding 标准:
/// - 延迟加载 Controller
/// - 自动依赖注入
/// - 页面销毁时自动清理
class MeetupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetupDetailController>(
      () => MeetupDetailController(
        meetupRepository: Get.find<IMeetupRepository>(),
        meetupStateController: Get.find<MeetupStateController>(),
        httpService: Get.find<HttpService>(),
      ),
    );
  }
}
