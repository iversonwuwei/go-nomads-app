import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

/// 城市搜索和筛选页面
class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // 筛选条件
  String _selectedRegion = 'All';
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _minInternetSpeed = 0;
  String _selectedClimate = 'All';

  final List<String> _regions = [
    'All',
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];

  final List<String> _climates = [
    'All',
    'Tropical',
    'Dry',
    'Temperate',
    'Continental',
    'Polar',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft,
              color: AppColors.backButtonLight),
          onPressed: () => Get.back(),
        ),
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
                child: TextField(
                  controller: _searchController,
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(FontAwesomeIcons.xmark, color: Colors.white54),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
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
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _regions.map((region) {
                        final isSelected = _selectedRegion == region;
                        return FilterChip(
                          label: Text(region),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRegion = region;
                            });
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
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 价格范围
                  _buildFilterSection(
                    l10n.budget,
                    isMobile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 5000,
                          divisions: 50,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 网速筛选
                  _buildFilterSection(
                    l10n.internet,
                    isMobile,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_minInternetSpeed.round()} Mbps',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Slider(
                          value: _minInternetSpeed,
                          min: 0,
                          max: 300,
                          divisions: 30,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white.withValues(alpha: 0.2),
                          onChanged: (value) {
                            setState(() {
                              _minInternetSpeed = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 气候筛选
                  _buildFilterSection(
                    l10n.climate,
                    isMobile,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _climates.map((climate) {
                        final isSelected = _selectedClimate == climate;
                        return FilterChip(
                          label: Text(climate),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedClimate = climate;
                            });
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
                    ),
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
                      onPressed: () {
                        setState(() {
                          _selectedRegion = 'All';
                          _priceRange = const RangeValues(0, 5000);
                          _minInternetSpeed = 0;
                          _selectedClimate = 'All';
                          _searchController.clear();
                        });
                      },
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
