import 'package:get/get.dart';

import 'meetup_list_controller.dart';

/// Meetup List 页面绑定
class MeetupListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetupListController>(() => MeetupListController());
  }
}
