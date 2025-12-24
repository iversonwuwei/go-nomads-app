import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../features/hotel/presentation/hotel_detail_page.dart' as hotel_detail;

/// 酒店列表页面（简化版，用于城市详情页的Hotels标签）
class HotelListPage extends StatefulWidget {
  final String? cityId; // 可选：指定城市ID进行过滤
  final String? cityName; // 可选：城市名称显示
  final String? countryName; // 可选：国家名称

  const HotelListPage({
    super.key,
    this.cityId,
    this.cityName,
    this.countryName,
  });

  @override
  State<HotelListPage> createState() => HotelListPageState();
}

class HotelListPageState extends State<HotelListPage> {
  final RxBool _isLoading = false.obs;
  final RxList<Hotel> _hotels = <Hotel>[].obs;
  final RxBool _canManageHotels = false.obs;

  // 搜索条件
  final RxString _searchQuery = ''.obs;

  final HotelRepository _hotelRepository = HotelRepository(HttpService());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() {
      _loadHotels();
      _checkPermissions();
    });
  }

  /// 公开的刷新方法，供外部调用
  void refresh() {
    _loadHotels();
  }

  Future<void> _checkPermissions() async {
    // 检查用户是否为管理员或版主
    final isAdmin = await TokenStorageService().isAdmin();
    _canManageHotels.value = isAdmin;
    log('🏨 Hotel管理权限: isAdmin=$isAdmin, canManage=${_canManageHotels.value}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 加载酒店数据
  Future<void> _loadHotels() async {
    _isLoading.value = true;
    try {
      log('🏨 HotelListPage - cityId: ${widget.cityId}, cityName: ${widget.cityName}');

      List<Hotel> hotels = [];

      // 如果有城市ID，加载该城市的酒店
      if (widget.cityId != null) {
        log('🏨 正在加载城市 ID ${widget.cityId} 的酒店...');
        final result = await _hotelRepository.getHotelsByCity(widget.cityId!);

        result.fold(
          onSuccess: (data) {
            hotels = data;
            log('🏨 找到 ${hotels.length} 个酒店');
          },
          onFailure: (exception) {
            // 酒店服务暂未实现，静默处理错误，显示空状态
            log('⚠️ 酒店服务暂不可用: ${exception.message}');
          },
        );
      } else {
        // 加载所有酒店
        final result = await _hotelRepository.getHotels();

        result.fold(
          onSuccess: (data) {
            hotels = data;
            log('🏨 找到 ${hotels.length} 个酒店');
          },
          onFailure: (exception) {
            // 酒店服务暂未实现，静默处理错误，显示空状态
            log('⚠️ 酒店服务暂不可用: ${exception.message}');
          },
        );
      }

      // 如果有搜索查询，过滤结果
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        hotels = hotels.where((hotel) {
          final name = hotel.name.toLowerCase();
          final description = hotel.description.toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }

      // 按评分排序
      hotels.sort((a, b) => b.rating.compareTo(a.rating));

      _hotels.value = hotels;
    } catch (e) {
      // 酒店服务暂未实现，静默处理错误，显示空状态
      log('⚠️ 酒店服务暂不可用: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 搜索栏
        _buildSearchBar(),

        // 酒店列表
        Expanded(
          child: Obx(() {
            if (_isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_hotels.isEmpty) {
              return _buildEmptyState(l10n);
            }

            return RefreshIndicator(
              onRefresh: _loadHotels,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _hotels.length,
                itemBuilder: (context, index) {
                  return _buildHotelCard(_hotels[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // 搜索输入框
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search hotels...',
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(FontAwesomeIcons.xmark),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery.value = '';
                          _loadHotels();
                        },
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (value) {
                _searchQuery.value = value;
                if (value.isEmpty || value.length >= 3) {
                  _loadHotels();
                }
              },
            ),
          ),
          // 添加按钮
          SizedBox(width: 12.w),
          IconButton(
            icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.black54),
            onPressed: _navigateToAddHotel,
            tooltip: 'Add Hotel',
          ),
        ],
      ),
    );
  }

  // 酒店卡片
  Widget _buildHotelCard(Hotel hotel) {
    return GestureDetector(
      onTap: () async {
        // 跳转到酒店详情页面
        final result = await Get.to<Hotel?>(() => hotel_detail.HotelDetailPage(hotel: hotel));
        // 如果详情页返回了更新后的酒店数据，更新列表中的数据
        if (result != null) {
          final index = _hotels.indexWhere((h) => h.id == result.id);
          if (index != -1) {
            _hotels[index] = result;
          }
        }
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒店图片
            Stack(
              children: [
                hotel.images.isNotEmpty
                    ? Image.network(
                        hotel.images.first,
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200.h,
                            color: Colors.grey[300],
                            child: const Icon(FontAwesomeIcons.hotel, size: 64),
                          );
                        },
                      )
                    : Container(
                        height: 200.h,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(FontAwesomeIcons.hotel, size: 64, color: Colors.grey[400]),
                        ),
                      ),
                // 精选标签
                if (hotel.isFeatured)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.star, size: 16.w, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 酒店信息
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 酒店名称
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // 城市名称
                  if (hotel.cityName.isNotEmpty)
                    Text(
                      hotel.cityName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  SizedBox(height: 8.h),

                  // 评分和类别
                  Row(
                    children: [
                      // 评分
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.star, size: 14.w, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              hotel.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 评论数
                      Text(
                        '(${hotel.reviewCount} reviews)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 类别
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          hotel.category,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // 价格
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 空状态显示
  Widget _buildEmptyState(AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadHotels,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.hotel,
                    size: 48.w,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No hotels yet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Help build the community',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                // 添加按钮 - 所有用户都可以看到，点击时会检查权限
                InkWell(
                  onTap: _navigateToAddHotel,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.plus,
                          size: 20.w,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add First Hotel',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 导航到添加酒店页面
  void _navigateToAddHotel() async {
    log('🏨 [HotelList] _navigateToAddHotel - cityId: ${widget.cityId}, cityName: ${widget.cityName}, countryName: ${widget.countryName}');
    final result = await Get.toNamed(AppRoutes.addHotel, arguments: {
      'cityId': widget.cityId,
      'cityName': widget.cityName,
      'countryName': widget.countryName,
    });
    if (result == true) {
      log('🏨 [HotelList] 酒店创建成功，刷新列表');
      _loadHotels();
    }
  }
}
