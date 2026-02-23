import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';
import 'package:go_nomads_app/pages/map_picker/widgets/map_picker_bottom_card.dart';
import 'package:go_nomads_app/pages/map_picker/widgets/map_picker_map_view.dart';
import 'package:go_nomads_app/pages/map_picker/widgets/map_picker_search_bar.dart';
import 'package:go_nomads_app/pages/map_picker/widgets/map_picker_search_results.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// 地图选点页面（GetView + GetX 架构）
/// 高德地图风格：拖动地图选择位置，中心点固定标记
///
/// 使用方式:
/// ```dart
/// final result = await Get.to(
///   () => const MapPickerPage(),
///   arguments: {
///     'initialLatitude': 39.9,
///     'initialLongitude': 116.4,
///     'searchQuery': '北京市',
///     'country': 'China',
///     'city': '北京',
///   },
/// );
/// if (result != null) {
///   final lat = result['latitude'] as double;
///   final lng = result['longitude'] as double;
///   final address = result['address'] as String;
/// }
/// ```
class MapPickerPage extends GetView<MapPickerController> {
  const MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.backButtonDark),
        title: Text(
          l10n.selectLocation,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          const MapPickerSearchBar(),
          // 地图 + 搜索结果 + 底部卡片（Stack 布局）
          Expanded(
            child: Stack(
              children: const [
                // 地图视图（含中心标记和定位按钮）
                MapPickerMapView(),
                // 搜索结果列表（覆盖在地图上方）
                MapPickerSearchResults(),
                // 底部信息卡片 + 确认按钮
                MapPickerBottomCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// MapPickerPage 的 GetX Binding
/// 用于通过 Get.to() 导航时自动注入 Controller
class MapPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapPickerController>(() => MapPickerController());
  }
}
