import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/async_task_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 旅行计划详情页
class TravelPlanPage extends StatefulWidget {
  final TravelPlan? plan;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;
  final DateTime? departureDate;

  const TravelPlanPage({
    super.key,
    this.plan,
    this.cityId,
    this.cityName,
    this.duration,
    this.budget,
    this.travelStyle,
    this.interests,
    this.departureLocation,
    this.departureDate,
  });

  @override
  State<TravelPlanPage> createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage>
    with SingleTickerProviderStateMixin {
  TravelPlan? _plan;
  bool _isLoading = true;
  late AnimationController _shimmerController;

  // 流式进度状态
  final String _progressMessage = '正在准备...';
  final int _progressValue = 0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    if (widget.plan != null) {
      _plan = widget.plan;
      _isLoading = false;
    } else {
      // 延迟执行异步任务生成,避免在 initState 中显示对话框
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generatePlanAsync(); // 使用异步任务队列生成
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    // 确保页面销毁时关闭任何可能残留的对话框
    print('[TravelPlanPage] dispose: 关闭可能残留的对话框');
    AsyncTaskProgressDialog.dismiss();
    super.dispose();
  }

  /// 使用AI State Controller生成旅行计划
  Future<void> _generatePlanAsync() async {
    final aiController = Get.find<AiStateController>();

    try {
      setState(() => _isLoading = true);

      // 调用AI Controller生成旅行计划
      final plan = await aiController.generateTravelPlan(
        cityId: widget.cityId ?? '',
        cityName: widget.cityName ?? '',
        cityImage: '',
        duration: widget.duration ?? 7,
        budget: widget.budget ?? 'medium',
        travelStyle: widget.travelStyle ?? 'culture',
        interests: widget.interests ?? [],
        departureLocation: widget.departureLocation,
      );

      if (plan != null && mounted) {
        setState(() {
          _plan = plan;
          _isLoading = false;
        });
        AppToast.success('Travel plan generated successfully!');
      } else if (mounted) {
        // 生成失败
        setState(() => _isLoading = false);
        AppToast.error('Failed to generate travel plan');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ 生成旅行计划失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error('Error: $e');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_plan == null) {
      return _buildErrorPage();
    }

    return _buildPlanContent(_plan!);
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar Skeleton
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              leading: IconButton(
                icon: const Icon(FontAwesomeIcons.arrowLeft,
                    color: AppColors.backButtonLight),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[100]!,
                            Colors.grey[300]!,
                          ],
                          begin: Alignment(
                              -1.0 + _shimmerController.value * 2, -1.0),
                          end: Alignment(
                              1.0 + _shimmerController.value * 2, 1.0),
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 进度提示
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // AI 图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.containerMedium.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.wandMagicSparkles,
                        size: 40,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 进度文本
                    Text(
                      _progressMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 进度条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressValue / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 进度百分比
                    Text(
                      '$_progressValue%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Overview Card Skeleton with details
                    _buildDetailedSkeletonCard(height: 150),
                    const SizedBox(height: 16),
                    // Transportation Card Skeleton
                    _buildDetailedSkeletonCard(height: 200),
                    const SizedBox(height: 16),
                    // Accommodation Card Skeleton
                    _buildDetailedSkeletonCard(height: 180),
                    const SizedBox(height: 16),
                    // Itinerary Card Skeleton
                    _buildDetailedSkeletonCard(height: 300),
                    const SizedBox(height: 16),
                    // Loading indicator
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF4458)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.generatingAiPlan,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedSkeletonCard({required double height}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title bar
              Row(
                children: [
                  _buildShimmerBox(width: 24, height: 24, borderRadius: 6),
                  const SizedBox(width: 12),
                  _buildShimmerBox(width: 120, height: 20, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 16),
              // Content lines
              _buildShimmerBox(
                  width: double.infinity, height: 14, borderRadius: 4),
              const SizedBox(height: 10),
              _buildShimmerBox(
                  width: double.infinity, height: 14, borderRadius: 4),
              const SizedBox(height: 10),
              _buildShimmerBox(width: 200, height: 14, borderRadius: 4),
              const Spacer(),
              // Bottom info
              Row(
                children: [
                  _buildShimmerBox(width: 80, height: 12, borderRadius: 4),
                  const Spacer(),
                  _buildShimmerBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
          end: Alignment(1.0 + _shimmerController.value * 2, 0),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildErrorPage() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.travelPlan),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.circleExclamation,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToGeneratePlan,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseTryAgain,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent(TravelPlan plan) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft,
                  color: AppColors.backButtonLight),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plan.destination.cityName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    plan.destination.cityImage ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[300]);
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.map),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.info(
                    l10n.asyncWithMap,
                    title: l10n.info,
                  );
                },
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.download),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.success(
                    l10n.planSaved,
                    title: l10n.download,
                  );
                },
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.shareNodes),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.info(
                    l10n.sharingPlan,
                    title: l10n.share,
                  );
                },
              ),
            ],
          ),

          // Plan Overview
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          color: Color(0xFFFF4458),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.aiGeneratedPlan,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.personalizedForYou,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (widget.departureLocation != null &&
                                widget.departureLocation!.isNotEmpty) ...[
                              _buildInfoChip(FontAwesomeIcons.plane,
                                  '${l10n.from}: ${widget.departureLocation}'),
                              const SizedBox(width: 12),
                            ],
                            _buildInfoChip(FontAwesomeIcons.calendar,
                                '${plan.metadata.duration} ${l10n.days}'),
                            const SizedBox(width: 12),
                            _buildInfoChip(FontAwesomeIcons.dollarSign,
                                plan.metadata.budgetLevel.displayName),
                            const SizedBox(width: 12),
                            _buildInfoChip(FontAwesomeIcons.paintbrush,
                                plan.metadata.style.name),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Budget Breakdown
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.budgetBreakdown,
                  FontAwesomeIcons.wallet,
                  _buildBudgetCard(plan),
                );
              },
            ),
          ),

          // Transportation
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.transportation,
                  FontAwesomeIcons.plane,
                  _buildTransportationCard(plan),
                );
              },
            ),
          ),

          // Accommodation
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.accommodation,
                  FontAwesomeIcons.hotel,
                  _buildAccommodationCard(plan),
                );
              },
            ),
          ),

          // Daily Itinerary
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.dailyItinerary,
                  FontAwesomeIcons.noteSticky,
                  Column(
                    children: plan.dailyItineraries
                        .map((day) => _buildDayCard(day))
                        .toList(),
                  ),
                );
              },
            ),
          ),

          // Must-Visit Attractions
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.mustVisitAttractions,
                  FontAwesomeIcons.locationPin,
                  Column(
                    children: plan.attractions
                        .map((attraction) => _buildAttractionCard(attraction))
                        .toList(),
                  ),
                );
              },
            ),
          ),

          // Recommended Restaurants
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.recommendedRestaurants,
                  FontAwesomeIcons.utensils,
                  Column(
                    children: plan.restaurants
                        .map((restaurant) => _buildRestaurantCard(restaurant))
                        .toList(),
                  ),
                );
              },
            ),
          ),

          // Travel Tips
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _buildSection(
                  l10n.travelTips,
                  FontAwesomeIcons.lightbulb,
                  Column(
                    children:
                        plan.tips.map((tip) => _buildTipItem(tip)).toList(),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF4458)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(TravelPlan plan) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildBudgetRow(l10n.transportation, plan.budget.transportation),
              const Divider(height: 24),
              _buildBudgetRow(l10n.accommodation, plan.budget.accommodation),
              const Divider(height: 24),
              _buildBudgetRow(l10n.foodAndDining, plan.budget.food),
              const Divider(height: 24),
              _buildBudgetRow(l10n.activities, plan.budget.activities),
              const Divider(height: 24),
              _buildBudgetRow(l10n.miscellaneous, plan.budget.miscellaneous),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalEstimatedCost,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${plan.budget.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransportationCard(TravelPlan plan) {
    // 解析航班推荐信息
    final arrivalDetails = plan.transportation.arrival?.details ?? '';
    final flightRecommendationIndex = arrivalDetails.indexOf('\n\n航班推荐：\n');

    String generalInfo = arrivalDetails;
    List<String> flights = [];

    if (flightRecommendationIndex != -1) {
      generalInfo = arrivalDetails.substring(0, flightRecommendationIndex);
      final flightSection =
          arrivalDetails.substring(flightRecommendationIndex + 8);
      flights = flightSection
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.plane,
                  color: Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                plan.transportation.arrival?.method ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            generalInfo,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),

          // 航班推荐卡片
          if (flights.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4458).withValues(alpha: 0.05),
                    const Color(0xFFFF6B7A).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.plane,
                        color: Color(0xFFFF4458),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '航班推荐',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4458),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${flights.length}个选择',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...flights.asMap().entries.map((entry) {
                    final index = entry.key;
                    final flight = entry.value;

                    // 解析航班信息：航空公司 航班号 (时段) - 价格, 时长 - 备注
                    final parts = flight.split(' - ');
                    if (parts.length < 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          flight,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }

                    // 解析第一部分：航空公司 航班号 (时段)
                    final firstPart = parts[0];
                    final timeSlotMatch =
                        RegExp(r'\(([^)]+)\)').firstMatch(firstPart);
                    final timeSlot = timeSlotMatch?.group(1) ?? '';
                    final airlineAndFlight = firstPart
                        .replaceAll(RegExp(r'\s*\([^)]+\)'), '')
                        .trim();

                    // 解析第二部分：价格, 时长
                    final secondPart = parts[1];
                    final priceDuration = secondPart.split(', ');
                    final price =
                        priceDuration.isNotEmpty ? priceDuration[0].trim() : '';
                    final duration =
                        priceDuration.length > 1 ? priceDuration[1].trim() : '';

                    // 备注（如果有第三部分）
                    final notes =
                        parts.length > 2 ? parts.sublist(2).join(' - ') : '';

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index < flights.length - 1 ? 12 : 0,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 航空公司和航班号
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      airlineAndFlight.split(' ')[0], // 航空公司
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      airlineAndFlight
                                          .split(' ')
                                          .skip(1)
                                          .join(' '), // 航班号
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 时段标签
                              if (timeSlot.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTimeSlotColor(timeSlot),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    timeSlot,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 价格和时长
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.dollarSign,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                price,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(FontAwesomeIcons.clock,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                duration,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          // 备注信息
                          if (notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(FontAwesomeIcons.circleInfo,
                                    size: 14, color: Colors.blue[400]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    notes,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${l10n.estimatedCost}:'),
                    Text(
                      '\$${plan.transportation.arrival?.estimatedCost.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(FontAwesomeIcons.trainSubway,
                  color: Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                plan.transportation.localTransport?.method ?? 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.transportation.localTransport?.details ??
                'No details available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // 根据时段返回不同颜色
  Color _getTimeSlotColor(String timeSlot) {
    if (timeSlot.contains('早')) {
      return Colors.orange;
    } else if (timeSlot.contains('午')) {
      return Colors.blue;
    } else if (timeSlot.contains('晚')) {
      return Colors.purple;
    }
    return Colors.grey;
  }

  Widget _buildAccommodationCard(TravelPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.accommodation.type.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    '\$${plan.accommodation.pricePerNight.toStringAsFixed(0)}/${l10n.pricePerNight}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4458),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.accommodation.recommendation,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(FontAwesomeIcons.locationDot,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                plan.accommodation.recommendedArea,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.accommodation.amenities
                .map((amenity) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.lightbulb,
                    size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.accommodation.bookingTips ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyItinerary dayItinerary) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4458),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.dayNumber(dayItinerary.day),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dayItinerary.theme,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...dayItinerary.activities
                  .map((activity) => _buildActivityItem(activity)),
              if (dayItinerary.notes != null &&
                  dayItinerary.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(FontAwesomeIcons.circleInfo,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dayItinerary.notes!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(PlannedActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              activity.time,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.locationDot,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      activity.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(FontAwesomeIcons.dollarSign,
                        size: 12, color: Colors.grey[500]),
                    Text(
                      '\$${activity.estimatedCost.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(AttractionRecommendation attraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.network(
              attraction.image ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.image),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attraction.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.star,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        attraction.rating.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      const Icon(FontAwesomeIcons.dollarSign,
                          size: 12, color: Color(0xFFFF4458)),
                      Text(
                        '\$${attraction.entryFee.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(RestaurantRecommendation restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.network(
              restaurant.image ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.utensils),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.star,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        restaurant.priceSymbol,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4458),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
