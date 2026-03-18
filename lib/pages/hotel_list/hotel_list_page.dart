import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/hotel_list_page_controller.dart';
import 'package:go_nomads_app/pages/hotel_list/hotel_card.dart';
import 'package:go_nomads_app/pages/hotel_list/hotel_empty_state.dart';
import 'package:go_nomads_app/pages/hotel_list/hotel_search_bar.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// 酒店列表页面（简化版，用于城市详情页的Hotels标签）
class HotelListPage extends StatelessWidget {
  final String? cityId; // 可选：指定城市ID进行过滤
  final String? cityName; // 可选：城市名称显示
  final String? countryName; // 可选：国家名称
  final double? latitude; // 可选：城市纬度，用于第三方酒店搜索
  final double? longitude; // 可选：城市经度，用于第三方酒店搜索

  const HotelListPage({
    super.key,
    this.cityId,
    this.cityName,
    this.countryName,
    this.latitude,
    this.longitude,
  });

  String get _tag => 'hotel_list_${cityId ?? 'all'}';

  @override
  Widget build(BuildContext context) {
    // 注册 Controller
    final controller = Get.put(
      HotelListPageController(
        cityId: cityId,
        cityName: cityName,
        countryName: countryName,
        latitude: latitude,
        longitude: longitude,
      ),
      tag: _tag,
    );

    return RefreshIndicator(
      onRefresh: controller.loadHotels,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 搜索栏
          SliverToBoxAdapter(
            child: HotelSearchBar(controllerTag: _tag),
          ),

          // 酒店列表或状态
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                hasScrollBody: true,
                child: HotelListSkeleton(),
              );
            }

            if (controller.hotels.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: HotelEmptyState(controllerTag: _tag),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return HotelCard(
                      controllerTag: _tag,
                      hotel: controller.hotels[index],
                    );
                  },
                  childCount: controller.hotels.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 公开的刷新方法，供外部调用
  void refresh() {
    final controller = Get.find<HotelListPageController>(tag: _tag);
    controller.refresh();
  }
}

/// 保持原有 State 类的公开方法接口，用于兼容性
/// 注意：这个类只是为了兼容旧代码，新代码应该直接使用 HotelListPage
class HotelListPageState {
  final String _tag;

  HotelListPageState(String? cityId) : _tag = 'hotel_list_${cityId ?? 'all'}';

  void refresh() {
    try {
      final controller = Get.find<HotelListPageController>(tag: _tag);
      controller.refresh();
    } catch (e) {
      // Controller not found, ignore
    }
  }
}
