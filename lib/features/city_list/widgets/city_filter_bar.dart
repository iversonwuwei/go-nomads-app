import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 城市筛选栏组件 - 包含搜索框和区域 Tab
class CityFilterBar extends GetView<CityListController> {
  final bool isMobile;

  const CityFilterBar({
    super.key,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索框
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 20,
              isMobile ? 12 : 16,
              isMobile ? 16 : 20,
              8,
            ),
            child: _buildSearchField(context, l10n),
          ),
          // 区域 Tab 栏
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _buildRegionTabs(l10n),
          ),
        ],
      ),
    );
  }

  /// 构建区域 Tab 栏
  Widget _buildRegionTabs(AppLocalizations l10n) {
    return Obx(() {
      final tabs = controller.regionTabs;

      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
          children: [
            // "全部" Tab
            _RegionTabChip(
              label: l10n.all,
              isSelected: controller.selectedRegion.value == null,
              onTap: () => controller.selectRegion(null),
            ),
            // 后端返回的区域 Tab
            for (final tab in tabs)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _RegionTabChip(
                  label: tab.label,
                  isSelected: controller.selectedRegion.value == tab.key,
                  onTap: () => controller.selectRegion(tab.key),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 10),
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
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 区域 Tab Chip 组件
class _RegionTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionTabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B7A78) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2B7A78) : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
