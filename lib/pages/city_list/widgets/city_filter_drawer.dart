import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市筛选抽屉组件
class CityFilterDrawer extends StatelessWidget {
  final CityStateController controller;

  const CityFilterDrawer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
          _buildHeader(context, l10n),

          // 筛选选项（可滚动）
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 地区筛选
                  _buildRegionFilter(l10n),
                  const SizedBox(height: 24),

                  // 国家筛选
                  _buildCountryFilter(l10n),
                  const SizedBox(height: 24),

                  // 城市筛选
                  _buildCityFilter(l10n),
                  const SizedBox(height: 24),

                  // 价格筛选
                  _buildPriceFilter(l10n),
                  const SizedBox(height: 24),

                  // 网速筛选
                  _buildInternetFilter(l10n),
                  const SizedBox(height: 24),

                  // 评分筛选
                  _buildRatingFilter(l10n),
                  const SizedBox(height: 24),

                  // 气候筛选
                  _buildClimateFilter(l10n),
                  const SizedBox(height: 24),

                  // AQI筛选
                  _buildAqiFilter(context, l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 底部应用按钮
          _buildApplyButton(context, l10n),
        ],
      ),
    );
  }

  // 顶部栏
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.filters,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  controller.resetFilters();
                },
                child: Text(
                  l10n.reset,
                  style: const TextStyle(
                    color: Color(0xFFFF4458),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.xmark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 地区筛选
  Widget _buildRegionFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.region),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableRegions.map((region) {
                final isSelected = controller.selectedRegions.contains(region);
                return FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedRegions.add(region);
                    } else {
                      controller.selectedRegions.remove(region);
                    }
                  },
                  selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFFFF4458),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  // 国家筛选
  Widget _buildCountryFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.country),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableCountries.map((country) {
                final isSelected = controller.selectedCountries.contains(country);
                return FilterChip(
                  label: Text(country),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCountries.add(country);
                    } else {
                      controller.selectedCountries.remove(country);
                    }
                  },
                  selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFFFF4458),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  // 城市筛选
  Widget _buildCityFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.city),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableCities.map((city) {
                final isSelected = controller.selectedCities.contains(city);
                return FilterChip(
                  label: Text(city),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCities.add(city);
                    } else {
                      controller.selectedCities.remove(city);
                    }
                  },
                  selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFFFF4458),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  // 价格筛选
  Widget _buildPriceFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.monthlyCost),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${controller.minPrice.value.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${controller.maxPrice.value.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(
                    controller.minPrice.value,
                    controller.maxPrice.value,
                  ),
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  activeColor: const Color(0xFFFF4458),
                  inactiveColor: AppColors.borderLight,
                  onChanged: (values) {
                    controller.minPrice.value = values.start;
                    controller.maxPrice.value = values.end;
                  },
                ),
              ],
            )),
      ],
    );
  }

  // 网速筛选
  Widget _buildInternetFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.minimumInternetSpeed),
        const SizedBox(height: 12),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.minInternet.value.toInt()} Mbps',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Slider(
                  value: controller.minInternet.value,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: const Color(0xFFFF4458),
                  inactiveColor: AppColors.borderLight,
                  onChanged: (value) {
                    controller.minInternet.value = value;
                  },
                ),
              ],
            )),
      ],
    );
  }

  // 评分筛选
  Widget _buildRatingFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.minimumOverallRating),
        const SizedBox(height: 12),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      controller.minRating.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '⭐️',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Slider(
                  value: controller.minRating.value,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: const Color(0xFFFF4458),
                  inactiveColor: AppColors.borderLight,
                  onChanged: (value) {
                    controller.minRating.value = value;
                  },
                ),
              ],
            )),
      ],
    );
  }

  // 气候筛选
  Widget _buildClimateFilter(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.climate),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableClimates.map((climate) {
                final isSelected = controller.selectedClimates.contains(climate);
                return FilterChip(
                  label: Text(climate),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedClimates.add(climate);
                    } else {
                      controller.selectedClimates.remove(climate);
                    }
                  },
                  selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  checkmarkColor: const Color(0xFFFF4458),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  // AQI筛选
  Widget _buildAqiFilter(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.maximumAirQualityIndex),
        const SizedBox(height: 12),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AQI ${controller.maxAqi.value}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getAQILabel(controller.maxAqi.value, context),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: controller.maxAqi.value.toDouble(),
                  min: 0,
                  max: 500,
                  divisions: 10,
                  activeColor: const Color(0xFFFF4458),
                  inactiveColor: AppColors.borderLight,
                  onChanged: (value) {
                    controller.maxAqi.value = value.toInt();
                  },
                ),
              ],
            )),
      ],
    );
  }

  // 底部应用按钮
  Widget _buildApplyButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Obx(() {
        final count = controller.filteredCities.length;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.showCities(count),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _getAQILabel(int aqi, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (aqi <= 50) return l10n.aqiGood;
    if (aqi <= 100) return l10n.aqiModerate;
    if (aqi <= 150) return l10n.aqiUnhealthyForSensitive;
    if (aqi <= 200) return l10n.aqiUnhealthy;
    if (aqi <= 300) return l10n.aqiVeryUnhealthy;
    return l10n.aqiHazardous;
  }
}
