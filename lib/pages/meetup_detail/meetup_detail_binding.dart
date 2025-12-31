import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:get/get.dart';

/// Meetup 详情页面绑定
class MeetupDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 需要 Meetup 参数，所以使用 lazyPut 配合 fenix: true
    // 实际初始化在页面通过 Get.arguments 获取参数后完成
    Get.lazyPut<MeetupDetailPageController>(
      () {
        final meetup = Get.arguments as Meetup;
        return MeetupDetailPageController(initialMeetup: meetup);
      },
      fenix: true,
    );
  }
}
