import 'package:get/get.dart';
import 'package:go_nomads_app/core/lifecycle/binding_helper.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';

/// 首页 Binding - GetX 依赖注入
///
/// 每次进入首页时确保控制器为全新状态，
/// 数据从服务端重新加载。
class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    BindingHelper.putFresh<HomePageController>(
      () => HomePageController(),
    );
  }
}
