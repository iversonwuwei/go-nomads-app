import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 酒店详情页面
class HotelDetailPage extends StatefulWidget {
  final int hotelId;

  const HotelDetailPage({
    super.key,
    required this.hotelId,
  });

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  final HotelRepository _hotelRepository = HotelRepository(HttpService());
  final RxBool _isLoading = true.obs;
  final Rxn<Hotel> _hotel = Rxn<Hotel>();
  final RxString _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadHotel();
  }

  Future<void> _loadHotel() async {
    _isLoading.value = true;
    _error.value = '';

    final result = await _hotelRepository.getHotelById(widget.hotelId.toString());

    result.onSuccess((hotel) {
      _hotel.value = hotel;
      log('🏨 加载酒店详情成功: ${hotel.name}');
    }).onFailure((exception) {
      _error.value = exception.message;
      log('❌ 加载酒店详情失败: ${exception.message}');
    });

    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error.value.isNotEmpty) {
          return _buildErrorState();
        }

        final hotel = _hotel.value;
        if (hotel == null) {
          return _buildErrorState();
        }

        return _buildHotelDetail(hotel);
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.circleExclamation, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            _error.value.isNotEmpty ? _error.value : 'Hotel not found',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelDetail(Hotel hotel) {
    return CustomScrollView(
      slivers: [
        // 图片轮播 AppBar
        SliverAppBar(
          expandedHeight: 250.h,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              hotel.name,
              style: const TextStyle(
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
            background: hotel.images.isNotEmpty
                ? PageView.builder(
                    itemCount: hotel.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        hotel.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(FontAwesomeIcons.hotel, size: 64),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(FontAwesomeIcons.hotel, size: 64, color: Colors.grey[400]),
                    ),
                  ),
          ),
        ),

        // 酒店信息
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 评分和类别
                Row(
                  children: [
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '(${hotel.reviewCount} reviews)',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      '\$${hotel.pricePerNight.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      ' / night',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // 位置信息
                Row(
                  children: [
                    Icon(FontAwesomeIcons.locationDot, size: 16.w, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${hotel.address}, ${hotel.cityName}${hotel.country != null ? ', ${hotel.country}' : ''}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // 描述
                Text(
                  'Description',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  hotel.description,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 24.h),

                // 数字游民特性
                Text(
                  'Nomad Features',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                _buildNomadFeatures(hotel),
                SizedBox(height: 24.h),

                // 设施
                Text(
                  'Amenities',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                _buildAmenities(hotel),
                SizedBox(height: 24.h),

                // 联系方式
                if (hotel.phone != null || hotel.email != null || hotel.website != null) ...[
                  Text(
                    'Contact',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  _buildContactInfo(hotel),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNomadFeatures(Hotel hotel) {
    final features = <Map<String, dynamic>>[];

    if (hotel.hasWifi) {
      features.add({
        'icon': FontAwesomeIcons.wifi,
        'label': 'WiFi${hotel.wifiSpeed != null ? ' (${hotel.wifiSpeed} Mbps)' : ''}',
        'color': Colors.blue,
      });
    }
    if (hotel.hasWorkDesk) {
      features.add({'icon': FontAwesomeIcons.desktop, 'label': 'Work Desk', 'color': Colors.green});
    }
    if (hotel.hasCoworkingSpace) {
      features.add({'icon': FontAwesomeIcons.users, 'label': 'Coworking Space', 'color': Colors.purple});
    }
    if (hotel.hasLongStayDiscount) {
      features.add({
        'icon': FontAwesomeIcons.percent,
        'label':
            'Long Stay Discount${hotel.longStayDiscountPercent != null ? ' (${hotel.longStayDiscountPercent!.toStringAsFixed(0)}%)' : ''}',
        'color': Colors.orange,
      });
    }
    if (hotel.nomadScore > 0) {
      features.add({
        'icon': FontAwesomeIcons.laptopCode,
        'label': 'Nomad Score: ${hotel.nomadScore}',
        'color': Colors.teal,
      });
    }

    if (features.isEmpty) {
      return Text(
        'No nomad-specific features listed',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: features.map((feature) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: (feature['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: feature['color'] as Color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(feature['icon'] as IconData, size: 16.w, color: feature['color'] as Color),
              SizedBox(width: 6.w),
              Text(
                feature['label'] as String,
                style: TextStyle(fontSize: 12.sp, color: feature['color'] as Color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenities(Hotel hotel) {
    final amenityIcons = <String, IconData>{
      'WiFi': FontAwesomeIcons.wifi,
      'Air Conditioning': FontAwesomeIcons.snowflake,
      'Kitchen': FontAwesomeIcons.kitchenSet,
      'Laundry': FontAwesomeIcons.shirt,
      'Parking': FontAwesomeIcons.squareParking,
      'Pool': FontAwesomeIcons.personSwimming,
      'Gym': FontAwesomeIcons.dumbbell,
      '24h Reception': FontAwesomeIcons.clock,
      'Pet Friendly': FontAwesomeIcons.paw,
      'Work Desk': FontAwesomeIcons.desktop,
      'Coworking': FontAwesomeIcons.users,
    };

    if (hotel.amenities.isEmpty) {
      return Text(
        'No amenities listed',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: hotel.amenities.map((amenity) {
        final icon = amenityIcons[amenity] ?? FontAwesomeIcons.check;
        return Column(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 24.w, color: Colors.grey[700]),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: 60.w,
              child: Text(
                amenity,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(Hotel hotel) {
    return Column(
      children: [
        if (hotel.phone != null)
          ListTile(
            leading: Icon(FontAwesomeIcons.phone, color: Colors.blue),
            title: Text(hotel.phone!),
            contentPadding: EdgeInsets.zero,
          ),
        if (hotel.email != null)
          ListTile(
            leading: Icon(FontAwesomeIcons.envelope, color: Colors.blue),
            title: Text(hotel.email!),
            contentPadding: EdgeInsets.zero,
          ),
        if (hotel.website != null)
          ListTile(
            leading: Icon(FontAwesomeIcons.globe, color: Colors.blue),
            title: Text(hotel.website!),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
