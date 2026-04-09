import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_rating_controller.dart';

/// 城市评分卡片组件 - 小红书/现代轻量化风格
class CityRatingsCard extends StatefulWidget {
  final String cityId;

  const CityRatingsCard({
    super.key,
    required this.cityId,
  });

  @override
  State<CityRatingsCard> createState() => _CityRatingsCardState();
}

class _CityRatingsCardState extends State<CityRatingsCard> {
  bool _hasLoaded = false;
  String? _lastCityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(CityRatingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityId != widget.cityId) {
      log('🔄 [CityRatingsCard] cityId 变化: ${oldWidget.cityId} -> ${widget.cityId}');
      _hasLoaded = false;
      _lastCityId = null;
      _loadData();
    }
  }

  void _loadData() {
    if (_hasLoaded && _lastCityId == widget.cityId) {
      return;
    }
    log('📥 [CityRatingsCard] 开始加载数据: cityId=${widget.cityId}');
    final controller = Get.find<CityRatingController>();
    controller.loadCityRatings(widget.cityId);
    _hasLoaded = true;
    _lastCityId = widget.cityId;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CityRatingController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonLoader();
      }

      if (controller.statistics.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部装饰
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cityPrimary.withAlpha(20),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.solidStarHalfStroke,
                      size: 20.r,
                      color: AppColors.cityPrimary,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '游民综合评分', // You might want this localized eventually
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cityPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // 评分项列表
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h).copyWith(bottom: 20.h),
                itemCount: controller.statistics.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.grey[100], height: 1),
                ),
                itemBuilder: (context, index) {
                  final stat = controller.statistics[index];
                  return _buildModernRatingItem(context, controller, stat);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildModernRatingItem(
    BuildContext context,
    CityRatingController controller,
    dynamic stat,
  ) {
    final userRating = stat.userRating ?? 0;
    final averageRating = stat.averageRating;
    final isCompleted = controller.completedCategoryId.value == stat.categoryId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 图标和名称区域，具有轻微的背景色
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            _getIconData(stat.icon),
            size: 20.r,
            color: AppColors.cityPrimary.withAlpha(200),
          ),
        ),
        SizedBox(width: 16.w),

        // 文字与进度/星星
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.categoryName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  if (isCompleted)
                    ...List.generate(5, (index) {
                      final isFilled = index < averageRating.floor();
                      final isHalfFilled = index == averageRating.floor() && averageRating % 1 >= 0.5;
                      return Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: _buildStar(isActive: true, isFilled: isFilled, isHalfFilled: isHalfFilled),
                      );
                    })
                  else
                    ...List.generate(5, (index) {
                      final isActive = index < userRating;
                      final isFilled = index < averageRating.floor();
                      final isHalfFilled = index == averageRating.floor() && averageRating % 1 >= 0.5;
                      return GestureDetector(
                        onTap: () => controller.submitRating(stat.categoryId, index + 1),
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: _buildStar(isActive: isActive, isFilled: isFilled, isHalfFilled: isHalfFilled),
                        ),
                      );
                    }),

                  const Spacer(),

                  // 分数徽章
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.cityPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cityPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStar({
    required bool isActive,
    required bool isFilled,
    required bool isHalfFilled,
  }) {
    IconData icon;
    Color color;

    if (isFilled) {
      icon = FontAwesomeIcons.solidStar;
      color = const Color(0xFFFFB800); // 金黄色
    } else if (isHalfFilled) {
      icon = FontAwesomeIcons.starHalfStroke;
      color = const Color(0xFFFFB800);
    } else {
      icon = FontAwesomeIcons.star;
      color = Colors.grey[300]!; // 未填充为浅灰
    }

    // 如果用户点击了但还没有满分，稍微加深一下颜色
    if (isActive && !isFilled && !isHalfFilled) {
      color = const Color(0xFFFFD54F);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Icon(icon, size: 16.r, color: color),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: List.generate(
            3,
            (index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Row(
                    children: [
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12.r)),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100.w, height: 14.h, color: Colors.grey[200]),
                            SizedBox(height: 8.h),
                            Container(width: double.infinity, height: 14.h, color: Colors.grey[100]),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return FontAwesomeIcons.star;
    switch (iconName) {
      case 'wifi':
        return FontAwesomeIcons.wifi;
      case 'desktop':
        return FontAwesomeIcons.desktop;
      case 'users':
        return FontAwesomeIcons.users;
      case 'coffee':
        return FontAwesomeIcons.mugHot;
      case 'shield-halved':
        return FontAwesomeIcons.shieldHalved;
      case 'leaf':
        return FontAwesomeIcons.leaf;
      case 'sun':
        return FontAwesomeIcons.sun;
      case 'building':
        return FontAwesomeIcons.building;
      case 'burger':
        return FontAwesomeIcons.burger;
      case 'car':
        return FontAwesomeIcons.car;
      case 'money-bill':
        return FontAwesomeIcons.moneyBillWave;
      case 'heart-pulse':
        return FontAwesomeIcons.heartPulse;
      case 'hands-holding-child':
        return FontAwesomeIcons.peopleGroup;
      default:
        return FontAwesomeIcons.star;
    }
  }
}
