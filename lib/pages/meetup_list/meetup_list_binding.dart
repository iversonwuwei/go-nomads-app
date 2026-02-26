import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';

import 'meetup_list_controller.dart';

/// Meetup List 页面绑定
///
/// 每次进入页面时创建全新控制器，确保数据全新加载。
class MeetupListBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<MeetupListController>(
      () => MeetupListController(),
    );
  }
}
