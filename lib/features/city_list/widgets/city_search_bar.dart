import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city_list/city_list_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市搜索栏组件
class CitySearchBar extends GetView<CityListController> {
  const CitySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              decoration: InputDecoration(
                hintText: l10n.searchCityOrCountry,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.search(value);
                } else {
                  controller.clearSearch();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // 清除按钮
          Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: controller.clearSearch,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  FontAwesomeIcons.xmark,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
          // 搜索按钮
          InkWell(
            onTap: () {
              final searchText = controller.searchTextController.text.trim();
              if (searchText.isNotEmpty) {
                controller.search(searchText);
              } else {
                controller.clearSearch();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.search,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
