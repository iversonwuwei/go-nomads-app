import 'dart:developer';

import 'dart:io';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_state_controller_v2.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 高德地图全球页面 - 展示全球城市分布
/// 使用原生 Platform View 嵌入高德地图
class AmapGlobalPage extends StatefulWidget {
  const AmapGlobalPage({super.key});

  @override
  State<AmapGlobalPage> createState() => _AmapGlobalPageState();
}

class _AmapGlobalPageState extends State<AmapGlobalPage> {
  static const String _viewType = 'amap_global_view';

  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  bool _isLoading = true;
  String? _errorMessage;

  CityStateControllerV2? _cityControllerCache;
  CityStateControllerV2 get _cityController {
    _cityControllerCache ??= Get.find<CityStateControllerV2>();
    return _cityControllerCache!;
  }

  List<City> get _filteredCities {
    final cities = _cityController.cities;
    if (_searchKeyword.trim().isEmpty) return cities;
    final keyword = _searchKeyword.toLowerCase();
    return cities.where((city) {
      return city.name.toLowerCase().contains(keyword) ||
          (city.nameEn?.toLowerCase().contains(keyword) ?? false) ||
          (city.country?.toLowerCase().contains(keyword) ?? false);
    }).toList();
  }

  /// 获取有效坐标的城市列表
  List<City> get _citiesWithCoordinates {
    return _filteredCities.where((city) {
      return city.latitude != null && city.longitude != null;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_cityController.cities.isEmpty) {
        await _cityController.loadInitialCities(refresh: true);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // 地图层
          _buildMapView(),

          // 顶部面板
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopPanel(l10n),
          ),

          // 加载指示器
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // 错误提示
          if (_errorMessage != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildErrorBanner(),
            ),

          // 右下角控制按钮
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildControlButtons(),
          ),

          // 左下角统计信息
          Positioned(
            bottom: 24,
            left: 16,
            child: _buildStatsCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return const Center(
        child: Text('地图仅支持 iOS 和 Android 平台'),
      );
    }

    // 准备传递给原生的城市数据
    final citiesData = _citiesWithCoordinates
        .map((city) => {
              'id': city.id,
              'name': city.displayName,
              'latitude': city.latitude,
              'longitude': city.longitude,
              'country': city.country ?? '',
              'score': city.overallScore ?? 0.0,
            })
        .toList();

    final creationParams = {
      'cities': citiesData,
      'initialZoom': 4.0, // 使用较高的缩放级别确保底图可见
      'centerLatitude': 35.0, // 中国中心纬度
      'centerLongitude': 105.0, // 中国中心经度
    };

    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return AndroidView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int viewId) {
    log('🗺️ AMap Platform View created with id: $viewId');
  }

  Widget _buildTopPanel(AppLocalizations l10n) {
    final totalCities = _citiesWithCoordinates.length;
    final totalCountries =
        _citiesWithCoordinates.map((c) => c.country).where((c) => c != null && c.isNotEmpty).toSet().length;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xCCFFFFFF),
            Color(0x00FFFFFF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 返回按钮和标题
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 8),
              Text(
                'Global Nomads',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // 刷新按钮
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                onPressed: _loadCities,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 统计信息
          Row(
            children: [
              _buildSummaryChip('$totalCities', 'Cities'),
              const SizedBox(width: 8),
              _buildSummaryChip('$totalCountries', 'Countries'),
            ],
          ),
          const SizedBox(height: 12),
          // 搜索框
          _buildSearchField(l10n),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: l10n.searchCities,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchKeyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchKeyword = '';
                      _searchController.clear();
                    });
                  },
                ),
        ),
        onChanged: (value) {
          setState(() {
            _searchKeyword = value;
          });
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMapButton(
          icon: Icons.my_location,
          onPressed: _centerToUserLocation,
        ),
        const SizedBox(height: 12),
        _buildMapButton(
          icon: Icons.zoom_in,
          onPressed: () => _changeZoom(1),
        ),
        const SizedBox(height: 12),
        _buildMapButton(
          icon: Icons.zoom_out,
          onPressed: () => _changeZoom(-1),
        ),
        const SizedBox(height: 12),
        _buildMapButton(
          icon: Icons.explore,
          onPressed: _resetToWorld,
        ),
      ],
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final cities = _citiesWithCoordinates;
    if (cities.isEmpty) return const SizedBox.shrink();

    // 按区域统计
    final regionStats = <String, int>{};
    for (final city in cities) {
      final region = city.region ?? 'Other';
      regionStats[region] = (regionStats[region] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'By Region',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...regionStats.entries.take(4).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getRegionColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'asia':
        return Colors.red;
      case 'europe':
        return Colors.blue;
      case 'north america':
        return Colors.green;
      case 'south america':
        return Colors.orange;
      case 'africa':
        return Colors.purple;
      case 'oceania':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  void _centerToUserLocation() {
    // TODO: 实现定位到用户位置
    log('📍 Center to user location');
  }

  void _changeZoom(int delta) {
    // TODO: 通过 MethodChannel 调用原生缩放
    log('🔍 Change zoom: $delta');
  }

  void _resetToWorld() {
    // TODO: 通过 MethodChannel 重置视图
    log('🌍 Reset to world view');
  }
}
