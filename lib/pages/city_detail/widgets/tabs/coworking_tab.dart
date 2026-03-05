import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_page.dart';
import 'package:go_nomads_app/widgets/coworking_verification_badge.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import '../../../../features/coworking/domain/entities/coworking_space.dart' as coworking;
import '../../../../features/coworking/presentation/controllers/coworking_state_controller.dart';
import '../../city_detail_controller.dart';

/// Coworking Tab - GetView 实现
///
/// 显示城市的共享办公空间列表
class CoworkingTab extends GetView<CityDetailController> {
  const CoworkingTab({
    super.key,
    required this.tag,
    required this.onAddCoworkingPressed,
  });

  @override
  final String? tag;
  final VoidCallback onAddCoworkingPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return Obx(() {
      // 显示加载状态
      if (coworkingController.isLoading.value) {
        return const CoworkingTabSkeleton();
      }

      // 显示空状态
      if (coworkingController.coworkingSpaces.isEmpty) {
        return _EmptyCoworkingState(
          cityId: controller.cityId,
          onAddPressed: onAddCoworkingPressed,
        );
      }

      // 显示共享办公空间列表
      return _CoworkingList(
        cityId: controller.cityId,
        spaces: coworkingController.coworkingSpaces,
        isAdminOrModerator: controller.isAdmin.value || controller.isModerator.value,
        onAddCoworkingPressed: onAddCoworkingPressed,
      );
    });
  }
}

/// 空状态组件
class _EmptyCoworkingState extends StatelessWidget {
  const _EmptyCoworkingState({
    required this.cityId,
    required this.onAddPressed,
  });

  final String cityId;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return RefreshIndicator(
      onRefresh: () => coworkingController.loadCoworkingSpacesByCity(cityId),
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
                    'No coworking spaces yet',
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
                  _buildAddButton(),
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
            const Color(0xFFFF4458).withValues(alpha: 0.08),
            const Color(0xFFFF4458).withValues(alpha: 0.02),
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
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
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
                color: const Color(0xFFFF4458).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            FontAwesomeIcons.building,
            size: 80.r,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddPressed,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.plus, size: 20.r, color: Colors.grey[700]),
            SizedBox(width: 8.w),
            Text(
              'Add First Space',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[700],
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

/// 共享办公空间列表
class _CoworkingList extends StatelessWidget {
  const _CoworkingList({
    required this.cityId,
    required this.spaces,
    required this.isAdminOrModerator,
    required this.onAddCoworkingPressed,
  });

  final String cityId;
  final List<coworking.CoworkingSpace> spaces;
  final bool isAdminOrModerator;
  final VoidCallback onAddCoworkingPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return RefreshIndicator(
      onRefresh: () => coworkingController.loadCoworkingSpacesByCity(cityId),
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 96.h),
        itemCount: spaces.length,
        itemBuilder: (context, index) {
          final space = spaces[index];
          return _CoworkingSpaceCard(space: space);
        },
      ),
    );
  }
}

/// 共享办公空间卡片 - Hero 风格（信息覆盖在图片上）
class _CoworkingSpaceCard extends StatelessWidget {
  const _CoworkingSpaceCard({required this.space});

  final coworking.CoworkingSpace space;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => Get.to(() => CoworkingDetailPage(space: space)),
          borderRadius: BorderRadius.circular(16.r),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Stack(
      children: [
        // 背景图片
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            space.spaceInfo.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(FontAwesomeIcons.building, size: 48.r, color: Colors.grey),
                ),
              );
            },
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        // 右上角：验证徽章
        Positioned(
          top: 12.h,
          right: 12.w,
          child: CoworkingVerificationBadge(
            space: space,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          ),
        ),
        // 底部信息面板
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 名称
          Text(
            space.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 地址
          if (space.location.address.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 11.r,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    space.location.address,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.8),
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
                  value: space.spaceInfo.rating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
                SizedBox(width: 8.w),
                // WiFi 速度
                _HeroPill(
                  icon: FontAwesomeIcons.wifi,
                  value: '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                ),
                // 月租价格
                if (space.pricing.monthlyRate != null) ...[
                  SizedBox(width: 8.w),
                  _HeroPill(
                    icon: FontAwesomeIcons.dollarSign,
                    value: '${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
                  ),
                ],
                // 24/7 开放
                if (space.amenities.has24HourAccess) ...[
                  SizedBox(width: 8.w),
                  const _HeroPill(
                    icon: FontAwesomeIcons.clock,
                    value: '24/7',
                    color: Colors.orange,
                  ),
                ],
                // 免费试用
                if (space.pricing.hasFreeTrial) ...[
                  SizedBox(width: 8.w),
                  const _HeroPill(
                    icon: FontAwesomeIcons.tag,
                    value: 'Free Trial',
                    color: Color(0xFFFF4458),
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

/// Hero 样式的信息标签
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
    final pillColor = color ?? Colors.white;
    final hasCustomColor = color != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: hasCustomColor ? pillColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: hasCustomColor ? pillColor : Colors.white.withValues(alpha: 0.9),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: hasCustomColor ? pillColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
