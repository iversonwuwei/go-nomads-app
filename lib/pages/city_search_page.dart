import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/city_search_page_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市搜索和筛选页面
class CitySearchPage extends StatelessWidget {
  const CitySearchPage({super.key});

  static const String _tag = 'CitySearchPage';

  CitySearchPageController get _controller {
    if (!Get.isRegistered<CitySearchPageController>(tag: _tag)) {
      Get.put(CitySearchPageController(), tag: _tag);
    }
    return Get.find<CitySearchPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final controller = _controller;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Text(
          l10n.search,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const AppBackButton(color: AppColors.backButtonLight),
      ),
      body: CustomScrollView(
        slivers: [
          // 搜索栏
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Obx(() => TextField(
                  controller: controller.searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(FontAwesomeIcons.xmark, color: Colors.white54),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (_) {},
                )),
              ),
            ),
          ),

          // 筛选标题
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 8,
              ),
              child: Text(
                l10n.filter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 筛选选项
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 地区筛选
                  _buildFilterSection(
                    l10n.region,
                    isMobile,
                    child: Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.regions.map((region) {
                        final isSelected = controller.selectedRegion.value == region;
                        return FilterChip(
                          label: Text(region),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.setRegion(region);
                          },
                          backgroundColor: const Color(0xFF1a1a1a),
                          selectedColor: Colors.orange.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.orange
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        );
                      }).toList(),
                    )),
                  ),

                  const SizedBox(height: 24),

                  // 价格范围
                  _buildFilterSection(
                    l10n.budget,
                    isMobile,
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${controller.priceRange.value.start.round()} - \$${controller.priceRange.value.end.round()}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RangeSlider(
                          values: controller.priceRange.value,
                          min: 0,
                          max: 5000,
                          divisions: 50,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: controller.setPriceRange,
                        ),
                      ],
                    )),
                  ),

                  const SizedBox(height: 24),

                  // 网速筛选
                  _buildFilterSection(
                    l10n.internet,
                    isMobile,
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.minInternetSpeed.value.round()} Mbps',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Slider(
                          value: controller.minInternetSpeed.value,
                          min: 0,
                          max: 300,
                          divisions: 30,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: controller.setMinInternetSpeed,
                        ),
                      ],
                    )),
                  ),

                  const SizedBox(height: 24),

                  // 气候筛选
                  _buildFilterSection(
                    l10n.climate,
                    isMobile,
                    child: Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.climates.map((climate) {
                        final isSelected = controller.selectedClimate.value == climate;
                        return FilterChip(
                          label: Text(climate),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.setClimate(climate);
                          },
                          backgroundColor: const Color(0xFF1a1a1a),
                          selectedColor: Colors.orange.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.orange
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        );
                      }).toList(),
                    )),
                  ),

                  const SizedBox(height: 32),

                  // 应用筛选按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final l10n = AppLocalizations.of(context)!;
                        // 应用筛选逻辑
                        AppToast.success(
                          l10n.showingResults,
                          title: l10n.filtersApplied,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.filter,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 重置按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.resetFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16 : 20,
                        ),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.reset,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    bool isMobile, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
