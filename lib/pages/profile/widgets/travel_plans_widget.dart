import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
              const Icon(
                FontAwesomeIcons.wandMagicSparkles,
                color: Color(0xFFFF4458),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'My Travel Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (latestPlan != null) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.cityList),
                  icon: const Icon(FontAwesomeIcons.plus, size: 16),
                  label: Text(l10n.createNew),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4458),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
        ),
      ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.earthAmericas,
              size: 48,
              color: Color(0xFFFF4458),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Travel Plans Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate AI-powered travel plans from city detail pages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.cityList),
            icon: const Icon(FontAwesomeIcons.compass, size: 18),
            label: Text(l10n.exploreCities),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Created ${plan.formattedCreatedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
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
        height: 120,
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
      height: 120,
      color: const Color(0xFFFF4458).withValues(alpha: 0.1),
      child: const Center(
        child: Icon(
          FontAwesomeIcons.city,
          size: 40,
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
        height: 60,
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
      bottom: 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Text(
            plan.cityName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          if (plan.departureDate != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.planeDeparture,
                    size: 11,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.formattedDepartureDate!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
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
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4458),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.wandMagicSparkles,
              size: 12,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'AI Generated',
              style: TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFFF4458)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
