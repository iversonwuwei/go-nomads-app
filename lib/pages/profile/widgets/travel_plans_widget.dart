import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// 旅行计划部分组件
class TravelPlansWidget extends StatelessWidget {
  final bool isMobile;

  const TravelPlansWidget({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aiController = Get.find<AiStateController>();

    return Obx(() {
      final latestPlan = aiController.latestTravelPlan;
      final isLoading = aiController.isLoadingUserPlans;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.wandMagicSparkles,
                color: Color(0xFFFF4458),
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'My Travel Plans',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (latestPlan != null) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.cityList),
                  icon: Icon(FontAwesomeIcons.plus, size: 16.r),
                  label: Text(l10n.createNew),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4458),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          if (isLoading)
            const _LoadingPlanCard()
          else if (latestPlan == null)
            _EmptyPlansCard(l10n: l10n)
          else
            _LatestPlanCard(plan: latestPlan),
        ],
      );
    });
  }
}

/// 加载中的计划卡片
class _LoadingPlanCard extends StatelessWidget {
  const _LoadingPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(child: AppLoadingWidget(fullScreen: false)),
    );
  }
}

/// 空计划卡片
class _EmptyPlansCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyPlansCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.earthAmericas,
              size: 48.r,
              color: Color(0xFFFF4458),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Travel Plans Yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Generate AI-powered travel plans from city detail pages',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.cityList),
            icon: Icon(FontAwesomeIcons.compass, size: 18.r),
            label: Text(l10n.exploreCities),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 最新旅行计划卡片
class _LatestPlanCard extends StatelessWidget {
  final TravelPlanSummary plan;

  const _LatestPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.travelPlan,
          arguments: {
            'planId': plan.id,
            'cityId': plan.cityId,
            'cityName': plan.cityName,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  _CityImage(imageUrl: plan.cityImage),
                  _GradientOverlay(),
                  _CityNameOverlay(plan: plan),
                  const _AiTag(),
                ],
              ),
            ),
            // 计划详情
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.w,
                    children: [
                      _PlanTag(
                        icon: FontAwesomeIcons.calendarDays,
                        label: '${plan.duration} days',
                      ),
                      _PlanTag(
                        icon: FontAwesomeIcons.dollarSign,
                        label: plan.budgetLevelDisplay,
                      ),
                      _PlanTag(
                        icon: FontAwesomeIcons.paintbrush,
                        label: plan.travelStyleDisplay,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 12.r,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Created ${plan.formattedCreatedAt}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        FontAwesomeIcons.chevronRight,
                        size: 14.r,
                        color: Colors.grey[400],
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

/// 城市图片
class _CityImage extends StatelessWidget {
  final String? imageUrl;

  const _CityImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 120.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _PlaceholderImage();
        },
      );
    }
    return _PlaceholderImage();
  }
}

/// 占位图片
class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      color: const Color(0xFFFF4458).withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          FontAwesomeIcons.city,
          size: 40.r,
          color: Color(0xFFFF4458),
        ),
      ),
    );
  }
}

/// 渐变遮罩
class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
      ),
    );
  }
}

/// 城市名称覆盖层
class _CityNameOverlay extends StatelessWidget {
  final TravelPlanSummary plan;

  const _CityNameOverlay({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        children: [
          Text(
            plan.cityName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.r,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          if (plan.departureDate != null) ...[
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.planeDeparture,
                    size: 11.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    plan.formattedDepartureDate!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2.r,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// AI 标签
class _AiTag extends StatelessWidget {
  const _AiTag();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.h,
      right: 12.w,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4458),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.wandMagicSparkles,
              size: 12.r,
              color: Colors.white,
            ),
            SizedBox(width: 4.w),
            Text(
              'AI Generated',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 计划标签
class _PlanTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlanTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: const Color(0xFFFF4458)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
