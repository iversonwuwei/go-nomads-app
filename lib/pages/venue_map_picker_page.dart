import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';

/// Venue地图选择器页�?
///
/// 显示地图并展示餐厅、Coworking和酒店的锚点
/// 用户可以点击选择一个地点作为Meet Up的Venue
class VenueMapPickerPage extends StatefulWidget {
  final String? cityName;

  const VenueMapPickerPage({
    super.key,
    this.cityName,
  });

  @override
  State<VenueMapPickerPage> createState() => _VenueMapPickerPageState();
}

class _VenueMapPickerPageState extends State<VenueMapPickerPage> {
  String _selectedFilter = 'All'; // All, Restaurants, Coworking, Hotels
  String? _selectedVenue;
  int _mapViewId = 0;

  // 模拟POI数据(实际应该从后端获�?
  final List<Map<String, dynamic>> _venues = [
    // 餐厅
    {
      'name': 'Thip Samai',
      'type': 'Restaurant',
      'address': '313 Maha Chai Rd, Samran Rat',
      'rating': 4.5,
      'latitude': 13.7563,
      'longitude': 100.5018,
      'priceRange': '\$\$',
    },
    {
      'name': 'Jay Fai',
      'type': 'Restaurant',
      'address': '327 Maha Chai Rd, Samran Rat',
      'rating': 4.7,
      'latitude': 13.7573,
      'longitude': 100.5028,
      'priceRange': '\$\$\$',
    },
    {
      'name': 'Som Tam Nua',
      'type': 'Restaurant',
      'address': '392/14 Siam Square Soi 5',
      'rating': 4.3,
      'latitude': 13.7453,
      'longitude': 100.5318,
      'priceRange': '\$',
    },

    // Coworking Spaces
    {
      'name': 'Hubba Coworking',
      'type': 'Coworking',
      'address': '8 Sukhumvit 33 Alley, Khlong Tan',
      'rating': 4.6,
      'latitude': 13.7297,
      'longitude': 100.5650,
      'priceRange': '\$150/month',
    },
    {
      'name': 'AIS D.C.',
      'type': 'Coworking',
      'address': '23 Phaya Thai Rd, Pathum Wan',
      'rating': 4.4,
      'latitude': 13.7465,
      'longitude': 100.5329,
      'priceRange': '\$100/month',
    },
    {
      'name': 'The Hive',
      'type': 'Coworking',
      'address': 'Thonglor, Sukhumvit 55',
      'rating': 4.5,
      'latitude': 13.7308,
      'longitude': 100.5850,
      'priceRange': '\$200/month',
    },

    // 酒店
    {
      'name': 'Mandarin Oriental',
      'type': 'Hotel',
      'address': '48 Oriental Avenue, Bang Rak',
      'rating': 4.8,
      'latitude': 13.7243,
      'longitude': 100.5157,
      'priceRange': '\$\$\$\$',
    },
    {
      'name': 'The Peninsula',
      'type': 'Hotel',
      'address': '333 Charoennakorn Rd, Khlong San',
      'rating': 4.7,
      'latitude': 13.7210,
      'longitude': 100.5089,
      'priceRange': '\$\$\$\$',
    },
    {
      'name': 'Lub d Bangkok',
      'type': 'Hotel',
      'address': '4 Decho Rd, Si Lom, Bang Rak',
      'rating': 4.2,
      'latitude': 13.7238,
      'longitude': 100.5265,
      'priceRange': '\$\$',
    },
  ];

  List<Map<String, dynamic>> get _filteredVenues {
    if (_selectedFilter == 'All') return _venues;
    return _venues
        .where((v) => v['type'] == _selectedFilter.replaceAll('s', ''))
        .toList();
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'Restaurant':
        return const Color(0xFFFF4458);
      case 'Coworking':
        return const Color(0xFF4A90E2);
      case 'Hotel':
        return const Color(0xFF50C878);
      default:
        return Colors.grey;
    }
  }

  IconData _getMarkerIcon(String type) {
    switch (type) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Coworking':
        return Icons.work;
      case 'Hotel':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }

  @override
  void initState() {
    super.initState();
    _mapViewId = DateTime.now().millisecondsSinceEpoch;
    print('🗺️ VenueMapPicker: 初始化地图, viewId: $_mapViewId');
  }

  @override
  void dispose() {
    print('🗑️ VenueMapPicker: 销毁地图');
    super.dispose();
  }

  void _selectVenue(Map<String, dynamic> venue) {
    setState(() {
      _selectedVenue = venue['name'];
    });
  }

  void _confirmSelection() {
    if (_selectedVenue == null) {
      Get.snackbar(
        'No Selection',
        'Please select a venue first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final venue = _venues.firstWhere((v) => v['name'] == _selectedVenue);
    Get.back(result: {
      'name': venue['name'],
      'address': venue['address'],
      'type': venue['type'],
      'latitude': venue['latitude'],
      'longitude': venue['longitude'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select Venue',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 过滤�?
            _buildFilterChips(),

            // 地图视图 - 固定高度
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildMapPlaceholder(),
            ),

            // Venue列表 - 不使用Expanded,让它根据内容自适应高度
            _buildVenueList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Restaurants', 'Coworking', 'Hotels'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 真实的高德地�?- 让原生组件自己处理所有手�?
          PlatformViewLink(
            viewType: 'amap_city_view',
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  // ScaleGestureRecognizer 包含了平移和缩放功能
                  Factory<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                  ),
                  Factory<TapGestureRecognizer>(
                    () => TapGestureRecognizer(),
                  ),
                },
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: 'amap_city_view',
                layoutDirection: TextDirection.ltr,
                creationParams: {
                  'cityName': widget.cityName ?? 'Bangkok',
                  'viewId': _mapViewId,
                },
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          ),

          // 顶部遮罩显示城市信息
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_city,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.cityName ?? 'Bangkok',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 地图类型指示�?
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_filteredVenues.length} Venues',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示�?
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_filteredVenues.length} Venues',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Venue列表 - 使用 ListView.builder 配合 shrinkWrap �?NeverScrollableScrollPhysics
          ListView.builder(
            shrinkWrap: true, // �?ListView 根据内容自适应高度
            physics:
                const NeverScrollableScrollPhysics(), // 禁用 ListView 自己的滚�?使用外层 SingleChildScrollView
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            itemCount: _filteredVenues.length,
            itemBuilder: (context, index) {
              final venue = _filteredVenues[index];
              final isSelected = _selectedVenue == venue['name'];

              return _buildVenueCard(venue, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF4458).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMarkerColor(venue['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getMarkerIcon(venue['type']),
                color: _getMarkerColor(venue['type']),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['address'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        venue['rating'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        venue['priceRange'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 类型标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getMarkerColor(venue['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                venue['type'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getMarkerColor(venue['type']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
