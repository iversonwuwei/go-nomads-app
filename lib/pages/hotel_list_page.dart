import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'room_type_list_page.dart';

/// 酒店列表页面（简化版，用于城市详情页的Hotels标签）
class HotelListPage extends StatefulWidget {
  final int? cityId; // 可选：指定城市ID进行过滤
  final String? cityName; // 可选：城市名称显示

  const HotelListPage({
    super.key,
    this.cityId,
    this.cityName,
  });

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  final RxBool _isLoading = false.obs;
  final RxList<Hotel> _hotels = <Hotel>[].obs;

  // 搜索条件
  final RxString _searchQuery = ''.obs;

  final HotelRepository _hotelRepository = HotelRepository(HttpService());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() => _loadHotels());
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
      print(
          '🏨 HotelListPage - cityId: ${widget.cityId}, cityName: ${widget.cityName}');

      List<Hotel> hotels = [];

      // 如果有城市ID，加载该城市的酒店
      if (widget.cityId != null) {
        print('🏨 正在加载城市 ID ${widget.cityId} 的酒店...');
        final result =
            await _hotelRepository.getHotelsByCity(widget.cityId.toString());

        result.fold(
          onSuccess: (data) {
            hotels = data;
            print('🏨 找到 ${hotels.length} 个酒店');
          },
          onFailure: (exception) {
            print('❌ 加载酒店失败: ${exception.message}');
            AppToast.error('加载酒店失败');
          },
        );
      } else {
        // 加载所有酒店
        final result = await _hotelRepository.getHotels();

        result.fold(
          onSuccess: (data) {
            hotels = data;
            print('🏨 找到 ${hotels.length} 个酒店');
          },
          onFailure: (exception) {
            print('❌ 加载酒店失败: ${exception.message}');
            AppToast.error('加载酒店失败');
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
      print('加载酒店失败: $e');
      AppToast.error('加载酒店失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.hotel, size: 48.w, color: Colors.grey),
                    SizedBox(height: 12.h),
                    Text(
                      'No hotels found',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
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
    );
  }

  // 酒店卡片
  Widget _buildHotelCard(Hotel hotel) {
    return GestureDetector(
      onTap: () {
        // 跳转到房型列表页面
        Get.to(() => RoomTypeListPage(
              hotelId: int.parse(hotel.id),
              hotelName: hotel.name,
            ));
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
                Image.network(
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
                ),
                // 精选标签
                if (hotel.isFeatured)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
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
}
