import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../generated/app_localizations.dart';
import '../models/travel_plan_model.dart';
import '../services/ai_api_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/async_task_progress_dialog.dart';

/// 旅行计划详情�?
class TravelPlanPage extends StatefulWidget {
  final TravelPlan? plan;
  final String? cityId;
  final String? cityName;
  final int? duration;
  final String? budget;
  final String? travelStyle;
  final List<String>? interests;
  final String? departureLocation;

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
  String _progressMessage = '正在准备...';
  int _progressValue = 0;

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
    super.dispose();
  }

  /// 使用异步任务队列生成旅行计划 (推荐)
  Future<void> _generatePlanAsync() async {
    final controller = Get.find<CityDetailController>();

    // 显示前先确保没有残留的进度对话框
    print('[LOG] 尝试关闭残留进度对话框...');
    AsyncTaskProgressDialog.dismiss();

    try {
      print('[LOG] 显示进度对话框');
      AsyncTaskProgressDialog.show(
        title: 'Generating Travel Plan',
        progress: controller.taskProgress,
        message: controller.taskProgressMessage,
      );

      // 调用异步任务生成
      final planId = await controller.generateTravelPlanAsync(
        duration: widget.duration ?? 7,
        budget: widget.budget ?? 'medium', // "low", "medium", "high"
        travelStyle: widget.travelStyle ??
            'culture', // "adventure", "relaxation", "culture", "nightlife"
        interests: widget.interests ?? [],
        onProgress: (progress, message) {
          // 进度已通过 controller.taskProgress 和 taskProgressMessage 响应式更新
          print('📊 进度: $progress% - $message');
        },
      );

      if (planId != null) {
        print('✅ 旅行计划生成成功! planId: $planId');

        // 从后端 API 获取完整的旅行计划数据
        try {
          print('📥 开始获取旅行计划详情...');

          final aiService = AiApiService();
          final plan = await aiService.getTravelPlanById(planId);

          print('✅ 成功获取旅行计划数据');
          print('   城市: ${plan.cityName}');
          print('   天数: ${plan.duration}');
          print('   景点数: ${plan.attractions.length}');

          print('[LOG] 关闭进度对话框（成功分支）');
          AsyncTaskProgressDialog.dismiss();

          // 重置进度值
          controller.taskProgress.value = 0;
          controller.taskProgressMessage.value = '';

          if (mounted) {
            setState(() {
              _plan = plan;
              _isLoading = false;
            });

            AppToast.success('Travel plan loaded successfully!');
          }
        } catch (e) {
          print('❌ 获取旅行计划详情失败: $e');

          print('[LOG] 关闭进度对话框（获取详情失败分支）');
          AsyncTaskProgressDialog.dismiss();

          // 重置进度值
          controller.taskProgress.value = 0;
          controller.taskProgressMessage.value = '';

          // 如果获取失败,降级使用模拟数据
          if (mounted) {
            setState(() {
              _plan = controller.generateMockTravelPlan(
                duration: widget.duration ?? 7,
                budget: widget.budget ?? 'medium',
                travelStyle: widget.travelStyle ?? 'culture',
                interests: widget.interests ?? [],
              );
              _isLoading = false;
            });

            AppToast.warning(
                'Failed to load plan data, using mock data: ${e.toString()}');
          }
        }
      } else {
        print('[LOG] 关闭进度对话框（planId==null分支）');
        AsyncTaskProgressDialog.dismiss();

        // 重置进度值
        controller.taskProgress.value = 0;
        controller.taskProgressMessage.value = '';

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          AppToast.error('Failed to generate travel plan');
        }
      }
    } catch (e) {
      print('❌ 异步生成旅行计划失败: $e');

      print('[LOG] 关闭进度对话框（catch分支）');
      AsyncTaskProgressDialog.dismiss();

      // 重置进度值
      controller.taskProgress.value = 0;
      controller.taskProgressMessage.value = '';

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppToast.error('生成失败: ${e.toString()}');
      }
    }
  }

  /// 使用流式 API 生成旅行计划 (备用方案)
  Future<void> _generatePlanStream() async {
    final controller = Get.find<CityDetailController>();

    try {
      await controller.generateTravelPlanStream(
        duration: widget.duration ?? 7,
        budget: widget.budget ?? 'medium',
        travelStyle: widget.travelStyle ?? 'culture',
        interests: widget.interests ?? [],
        departureLocation: widget.departureLocation,
        onProgress: (String message, int progress) {
          // 实时更新进度
          if (mounted) {
            setState(() {
              _progressMessage = message;
              _progressValue = progress;
            });
          }
        },
        onData: (TravelPlan plan) {
          // 接收到完整数据
          if (mounted) {
            setState(() {
              _plan = plan;
              _isLoading = false;
            });
          }
        },
        onError: (String error) {
          // 处理错误
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            AppToast.error(error);
            Get.back();
          }
        },
      );
    } catch (e) {
      print('❌ 生成旅行计划异常: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        AppToast.error('生成失败,请稍后重试');
        Get.back();
      }
    }
  }

  /// 旧的同步生成方法 (保留作为备用)
  Future<void> _generatePlan() async {
    final controller = Get.find<CityDetailController>();
    final plan = await controller.generateTravelPlan(
      duration: widget.duration ?? 7,
      budget: widget.budget ?? 'medium',
      travelStyle: widget.travelStyle ?? 'culture',
      interests: widget.interests ?? [],
      departureLocation: widget.departureLocation,
    );

    if (mounted) {
      setState(() {
        _plan = plan;
        _isLoading = false;
      });
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
      body: CustomScrollView(
        slivers: [
          // App Bar Skeleton
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined,
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
                        end: Alignment(1.0 + _shimmerController.value * 2, 1.0),
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
                      color: AppColors.containerMedium.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
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
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
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
              icon: const Icon(Icons.arrow_back_outlined,
                  color: AppColors.backButtonLight),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plan.cityName,
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
                    plan.cityImage,
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
                icon: const Icon(Icons.map_outlined),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.info(
                    l10n.asyncWithMap,
                    title: l10n.info,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  AppToast.success(
                    l10n.planSaved,
                    title: l10n.download,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
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
                          Icons.auto_awesome,
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
                              _buildInfoChip(Icons.flight_takeoff,
                                  '${l10n.from}: ${widget.departureLocation}'),
                              const SizedBox(width: 12),
                            ],
                            _buildInfoChip(Icons.calendar_today,
                                '${plan.duration} ${l10n.days}'),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                                Icons.attach_money, plan.budget.toUpperCase()),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.style, plan.travelStyle),
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
                  Icons.account_balance_wallet,
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
                  Icons.flight,
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
                  Icons.hotel,
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
                  Icons.event_note,
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
                  Icons.place,
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
                  Icons.restaurant,
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
                  Icons.lightbulb_outline,
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
              _buildBudgetRow(
                  l10n.transportation, plan.budgetBreakdown.transportation),
              const Divider(height: 24),
              _buildBudgetRow(
                  l10n.accommodation, plan.budgetBreakdown.accommodation),
              const Divider(height: 24),
              _buildBudgetRow(l10n.foodAndDining, plan.budgetBreakdown.food),
              const Divider(height: 24),
              _buildBudgetRow(l10n.activities, plan.budgetBreakdown.activities),
              const Divider(height: 24),
              _buildBudgetRow(
                  l10n.miscellaneous, plan.budgetBreakdown.miscellaneous),
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
                    '\$${plan.budgetBreakdown.total.toStringAsFixed(0)}',
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
              const Icon(Icons.flight_takeoff,
                  color: Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                plan.transportation.arrivalMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.transportation.arrivalDetails,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
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
                      '\$${plan.transportation.estimatedCost.toStringAsFixed(0)}',
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
              const Icon(Icons.directions_subway,
                  color: Color(0xFFFF4458), size: 20),
              const SizedBox(width: 8),
              Text(
                plan.transportation.localTransport,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.transportation.localTransportDetails,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
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
                  plan.accommodation.type,
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
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                plan.accommodation.area,
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
                const Icon(Icons.tips_and_updates,
                    size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.accommodation.bookingTips,
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
              if (dayItinerary.notes.isNotEmpty) ...[
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
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dayItinerary.notes,
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

  Widget _buildActivityItem(Activity activity) {
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
                    Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      activity.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.attach_money, size: 12, color: Colors.grey[500]),
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

  Widget _buildAttractionCard(Attraction attraction) {
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
              attraction.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
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
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        attraction.rating.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.attach_money,
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

  Widget _buildRestaurantCard(Restaurant restaurant) {
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
              restaurant.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant),
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
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        restaurant.priceRange,
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
