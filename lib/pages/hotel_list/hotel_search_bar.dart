import 'package:go_nomads_app/controllers/hotel_list_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 搜索栏组件
class HotelSearchBar extends StatelessWidget {
  final String controllerTag;

  const HotelSearchBar({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // 搜索输入框
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(FontAwesomeIcons.xmark),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          // 添加按钮
          SizedBox(width: 12.w),
          IconButton(
            icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.black54),
            onPressed: controller.navigateToAddHotel,
            tooltip: 'Add Hotel',
          ),
        ],
      ),
    );
  }
}
