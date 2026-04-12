import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';

import '../../../../controllers/hotel_list_page_controller.dart';
import '../../../../features/city/presentation/controllers/city_detail_state_controller.dart';
import '../../../../features/hotel/domain/entities/hotel.dart';
import '../../../../features/hotel/presentation/hotel_detail_page.dart' as hotel_detail;
import '../../../../utils/navigation_util.dart';
import '../../../../widgets/app_loading_widget.dart';
import '../../../../widgets/skeletons/skeletons.dart';
import '../../../hotel_list/hotel_search_bar.dart';
import '../../city_detail_controller.dart';

/// Hotels Tab - 原生实现
///
/// 显示城市的酒店列表，包含搜索栏、Hero 风格卡片列表和空状态
class HotelsTab extends GetView<CityDetailController> {
  const HotelsTab({super.key, required String tag}) : _tag = tag;

  final String _tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final cityDetailController = Get.find<CityDetailStateController>();

    return Obx(() {
      final city = cityDetailController.currentCity.value;
      final nomadSummary = cityDetailController.currentNomadSummary.value;
      final featuredStays = nomadSummary?.recommendedStays.length ?? 0;

      // 注册酒店控制器
      final hotelTag = controller.hotelListTag;
      final hotelController = Get.put(
        HotelListPageController(
          cityId: controller.cityId,
          cityName: controller.cityName,
          countryName: city?.country,
          latitude: city?.latitude,
          longitude: city?.longitude,
        ),
        tag: hotelTag,
      );

      final content = hotelController.hotels.isEmpty
          ? _EmptyHotelState(
              controllerTag: hotelTag,
            )
          : _HotelList(
              controllerTag: hotelTag,
              hotels: hotelController.hotels,
            );

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: _HotelsContextHeader(
              cityName: controller.cityName,
              featuredStays: featuredStays,
              countryName: city?.country,
            ),
          ),
          // 搜索栏
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: HotelSearchBar(controllerTag: hotelTag),
          ),
          Expanded(
            child: AppLoadingSwitcher(
              isLoading: hotelController.isLoading.value,
              loading: const HotelListSkeleton(),
              child: content,
            ),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Context Header
// ---------------------------------------------------------------------------

class _HotelsContextHeader extends StatelessWidget {
  const _HotelsContextHeader({
    required this.cityName,
    required this.featuredStays,
    required this.countryName,
  });

  final String cityName;
  final int featuredStays;
  final String? countryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF), Color(0xFFFFF8F4)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _HeaderPill(
                icon: FontAwesomeIcons.bed,
                label: featuredStays > 0 ? '$featuredStays curated stays' : 'Stay scouting mode',
              ),
              if (countryName != null && countryName!.isNotEmpty)
                _HeaderPill(
                  icon: FontAwesomeIcons.locationDot,
                  label: countryName!,
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Sleep base for $cityName',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Compare price, work setup, and long-stay leverage before you commit the next stop.',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: AppColors.travelSky),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyHotelState extends StatelessWidget {
  const _EmptyHotelState({required this.controllerTag});

  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);

    return RefreshIndicator(
      onRefresh: controller.loadHotels,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = (constraints.maxHeight - 120).clamp(0.0, double.infinity);
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIllustration(),
                  SizedBox(height: 40.h),
                  Text(
                    'No hotels yet',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[800],
                      letterSpacing: 0.5.sp,
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
                      letterSpacing: 0.2.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  _buildAddButton(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200.w,
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.travelSky.withValues(alpha: 0.12),
            AppColors.surfaceSubtle,
          ],
        ),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40.h,
            right: 40.w,
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: AppColors.travelSky.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 50.h,
            left: 30.w,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.travelSky.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            FontAwesomeIcons.hotel,
            size: 80.r,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(HotelListPageController controller) {
    return InkWell(
      onTap: controller.navigateToAddHotel,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border.all(
            color: AppColors.cityPrimary.withValues(alpha: 0.22),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: AppUiTokens.softFloatingShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.plus, size: 20.r, color: AppColors.cityPrimary),
            SizedBox(width: 8.w),
            Text(
              'Add First Hotel',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hotel List
// ---------------------------------------------------------------------------

class _HotelList extends StatelessWidget {
  const _HotelList({
    required this.controllerTag,
    required this.hotels,
  });

  final String controllerTag;
  final List<Hotel> hotels;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);

    return RefreshIndicator(
      onRefresh: controller.loadHotels,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 96.h),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return _HotelCard(
            hotel: hotels[index],
            controllerTag: controllerTag,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hotel Card — Hero 风格（信息覆盖在图片上）
// ---------------------------------------------------------------------------

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel, required this.controllerTag});

  final Hotel hotel;
  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x120F172A),
            blurRadius: 18.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(16.r),
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(BuildContext context) async {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);
    await NavigationUtil.toWithCallback<Hotel>(
      page: () => hotel_detail.HotelDetailPage(hotel: hotel),
      onResult: (result) {
        if (result.hasData) {
          controller.updateHotelInList(result.data!);
        }
      },
    );
  }

  Widget _buildCardContent() {
    return Stack(
      children: [
        // 背景图片
        AspectRatio(
          aspectRatio: 16 / 10,
          child: hotel.images.isNotEmpty
              ? Image.network(
                  hotel.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(FontAwesomeIcons.hotel, size: 48.r, color: Colors.grey),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(FontAwesomeIcons.hotel, size: 48.r, color: Colors.grey[400]),
                  ),
                ),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.04),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.16),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        // 左上角：精选标签
        if (hotel.isFeatured)
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.travelAmber.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.travelAmber.withValues(alpha: 0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.star, size: 12.r, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // 右上角：来源标识
        Positioned(
          top: 12.h,
          right: 12.w,
          child: _SourceBadge(hotel: hotel),
        ),
        // 底部：信息面板
        Positioned(
          left: 12.w,
          right: 12.w,
          bottom: 12.h,
          child: _buildHeroInfoPanel(),
        ),
      ],
    );
  }

  Widget _buildHeroInfoPanel() {
    final priceLabel = hotel.currency.isNotEmpty
        ? '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}'
        : hotel.pricePerNight.toStringAsFixed(0);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 名称
          Text(
            hotel.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 地址
          if (hotel.address.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 11.r,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    hotel.address,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.h),
          // 指标 Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 评分
                _HeroPill(
                  icon: FontAwesomeIcons.star,
                  value: hotel.rating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
                SizedBox(width: 8.w),
                // 价格
                _HeroPill(
                  icon: FontAwesomeIcons.dollarSign,
                  value: '$priceLabel/night',
                ),
                // WiFi 速度
                if (hotel.hasWifi && (hotel.wifiSpeed ?? 0) > 0) ...[
                  SizedBox(width: 8.w),
                  _HeroPill(
                    icon: FontAwesomeIcons.wifi,
                    value: '${hotel.wifiSpeed} Mbps',
                  ),
                ],
                // 长住折扣
                if (hotel.hasLongStayDiscount) ...[
                  SizedBox(width: 8.w),
                  _HeroPill(
                    icon: FontAwesomeIcons.tag,
                    value: '${hotel.longStayDiscountPercent?.toStringAsFixed(0) ?? ''}% off',
                    color: const Color(0xFFFF4458),
                  ),
                ],
                // 游民友好
                if (hotel.isNomadFriendly) ...[
                  SizedBox(width: 8.w),
                  const _HeroPill(
                    icon: FontAwesomeIcons.laptopCode,
                    value: 'Nomad',
                    color: Colors.teal,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Source Badge
// ---------------------------------------------------------------------------

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final isBooking = hotel.isBookingHotel;
    final backgroundColor =
        isBooking ? AppColors.travelSky.withValues(alpha: 0.9) : AppColors.travelAmber.withValues(alpha: 0.9);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        hotel.sourceLabel,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Pill
// ---------------------------------------------------------------------------

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? AppColors.textPrimary;
    final hasCustomColor = color != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: hasCustomColor ? pillColor.withValues(alpha: 0.12) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasCustomColor ? pillColor.withValues(alpha: 0.18) : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: hasCustomColor ? pillColor : AppColors.textPrimary,
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: hasCustomColor ? pillColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
