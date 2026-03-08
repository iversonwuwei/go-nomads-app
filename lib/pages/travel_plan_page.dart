import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/async_task_progress_dialog.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/share_bottom_sheet.dart';
import 'package:go_nomads_app/widgets/share_button.dart';

/// 旅行计划详情页
class TravelPlanPage extends StatefulWidget {
  final TravelPlan? plan;
  final String? planId; // 从数据库加载时传入
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
    this.planId,
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

class _TravelPlanPageState extends State<TravelPlanPage> {
  TravelPlan? _plan;
  bool _isLoading = true;

  // 流式进度状态
  String _progressMessage = '正在准备...';
  int _progressValue = 0;

  // GetX 监听器
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();

    if (widget.plan != null) {
      _plan = widget.plan;
      _isLoading = false;
    } else if (widget.planId != null) {
      // 从数据库加载已保存的旅行计划
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPlanFromDatabase();
      });
    } else {
      // 延迟执行异步任务生成,避免在 initState 中显示对话框
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generatePlanAsync(); // 使用异步任务队列生成
      });
    }
  }

  @override
  void dispose() {
    // 取消所有 GetX 监听器
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    // 确保页面销毁时关闭任何可能残留的对话框
    AsyncTaskProgressDialog.dismiss();
    super.dispose();
  }

  /// 从数据库加载已保存的旅行计划
  Future<void> _loadPlanFromDatabase() async {
    final aiController = Get.find<AiStateController>();
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() {
        _isLoading = true;
        _progressMessage = '正在加载旅行计划...';
        _progressValue = 50;
      });

      final result = await aiController.getTravelPlanDetail(widget.planId!);

      if (result != null && mounted) {
        setState(() {
          _plan = result;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(l10n.travelPlanUnableToLoad);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ 加载旅行计划失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(l10n.travelPlanLoadFailedWithError(e.toString()));
        Navigator.of(context).pop();
      }
    }
  }

  /// 使用异步任务生成旅行计划
  /// 流程: Flutter -> AIService(创建任务) -> RabbitMQ -> MessageService -> SignalR -> Flutter
  Future<void> _generatePlanAsync() async {
    final aiController = Get.find<AiStateController>();
    final l10n = AppLocalizations.of(context)!;

    // 检查 AI 配额
    final canUse = await AiQuotaService().checkAndUseAI(featureName: '旅行计划生成');
    if (!canUse) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _progressMessage = '正在连接 AI 服务...';
        _progressValue = 0;
      });

      // 设置 GetX 监听器
      _setupListeners(aiController);

      // 使用异步任务方式生成（通过 SignalR 监听 RabbitMQ 消息）
      await aiController.generateTravelPlanStream(
        cityId: widget.cityId ?? '',
        cityName: widget.cityName ?? '',
        cityImage: '',
        duration: widget.duration ?? 7,
        budget: widget.budget ?? 'medium',
        travelStyle: widget.travelStyle ?? 'culture',
        interests: widget.interests ?? [],
        departureLocation: widget.departureLocation,
        departureDate: widget.departureDate,
      );
    } catch (e) {
      debugPrint('❌ 生成旅行计划失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(l10n.travelPlanGenerateErrorWithError(e.toString()));
        Navigator.of(context).pop();
      }
    }
  }

  /// 设置 GetX 监听器
  void _setupListeners(AiStateController aiController) {
    final l10n = AppLocalizations.of(context)!;
    // 清理之前的监听器
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // 监听进度更新
    _workers.add(ever(aiController.travelPlanGenerationProgressRx, (progress) {
      if (mounted) {
        setState(() => _progressValue = progress);
      }
    }));

    // 监听进度消息更新
    _workers.add(ever(aiController.travelPlanGenerationMessageRx, (message) {
      if (mounted) {
        setState(() => _progressMessage = message);
      }
    }));

    // 监听任务完成，获取计划
    _workers.add(ever(aiController.currentTravelPlanRx, (plan) {
      if (plan != null && mounted) {
        setState(() {
          _plan = plan;
          _isLoading = false;
        });
        AppToast.success(l10n.travelPlanGeneratedSuccess);
      }
    }));

    // 监听错误
    _workers.add(ever(aiController.travelPlanErrorRx, (error) {
      if (error != null && mounted) {
        setState(() => _isLoading = false);
        AppToast.error(l10n.travelPlanGenerateFailedWithError(error.toString()));
        Navigator.of(context).pop();
      }
    }));
  }

  /// 分享旅行计划
  void _shareTravelPlan(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_plan == null) {
      AppToast.warning(l10n.travelPlanNotReadyWarning);
      return;
    }

    final plan = _plan!;

    // 构建分享标题
    final String cityName = plan.destination.cityName;
    final int duration = plan.metadata.duration;
    final String title = '$cityName $duration天旅行计划';

    // 构建分享描述
    final StringBuffer descBuffer = StringBuffer();
    descBuffer.writeln('🗺️ AI 智能旅行规划');
    descBuffer.writeln('📍 目的地: $cityName');
    descBuffer.writeln('📅 行程天数: $duration天');
    descBuffer.writeln('💰 预算等级: ${plan.metadata.budgetLevel.displayName}');
    descBuffer.writeln('🎯 旅行风格: ${plan.metadata.style.emoji} ${plan.metadata.style.name}');
    if (plan.tips.isNotEmpty) {
      descBuffer.writeln('\n💡 小贴士: ${plan.tips.first}');
    }

    // 构建分享链接
    final String shareUrl = 'https://nomadcities.app/travel-plans/${plan.id}';

    // 显示分享底部抽屉
    ShareBottomSheet.show(
      context,
      title: title,
      description: descBuffer.toString(),
      shareUrl: shareUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _plan == null ? _buildErrorPage() : _buildPlanContent(_plan!);
    return AppLoadingSwitcher(
      isLoading: _isLoading,
      loading: _buildLoadingSkeleton(),
      child: content,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 进度提示
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    // AI 图标
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.containerMedium.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FontAwesomeIcons.wandMagicSparkles,
                        size: 40.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 进度文本
                    Text(
                      _progressMessage,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // 进度条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: _progressValue / 100,
                        minHeight: 8.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // 进度百分比
                    Text(
                      '$_progressValue%',
                      style: TextStyle(
                        fontSize: 14.sp,
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
              child: Builder(
                builder: (context) {
                  return SizedBox(
                    height: 360.h,
                    child: AppSceneLoading(
                      scene: AppLoadingScene.travelPlan,
                      fullScreen: true,
                      subtitleOverride: _progressMessage,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.travelPlan),
        leading: const AppBackButton(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 64.r,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.failedToGeneratePlan,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.pleaseTryAgain,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24.h),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          plan.destination.cityName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.map, color: AppColors.textPrimary),
            onPressed: () {
              final l10n = AppLocalizations.of(context)!;
              AppToast.info(
                l10n.asyncWithMap,
                title: l10n.info,
              );
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.download, color: AppColors.textPrimary),
            onPressed: () {
              final l10n = AppLocalizations.of(context)!;
              AppToast.success(
                l10n.planSaved,
                title: l10n.download,
              );
            },
          ),
          AppShareButton(
            onPressed: () => _shareTravelPlan(context),
            color: AppColors.textPrimary,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Plan Overview
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
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
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.wandMagicSparkles,
                          color: Color(0xFFFF4458),
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.aiGeneratedPlan,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.personalizedForYou,
                                  style: TextStyle(
                                    fontSize: 13.sp,
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
                  SizedBox(height: 16.h),
                  const Divider(),
                  SizedBox(height: 16.h),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      // 优先使用从数据库加载的 departureLocation，其次使用 widget 传入的
                      final departureLocation = plan.departureLocation ?? widget.departureLocation;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (departureLocation != null && departureLocation.isNotEmpty) ...[
                              _buildInfoChip(FontAwesomeIcons.plane, '${l10n.from}: $departureLocation'),
                              SizedBox(width: 12.w),
                            ],
                            _buildInfoChip(FontAwesomeIcons.calendar, '${plan.metadata.duration} ${l10n.days}'),
                            SizedBox(width: 12.w),
                            _buildInfoChip(FontAwesomeIcons.dollarSign, plan.metadata.budgetLevel.displayName),
                            SizedBox(width: 12.w),
                            _buildInfoChip(FontAwesomeIcons.paintbrush, plan.metadata.style.name),
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
                    children: plan.dailyItineraries.map((day) => _buildDayCard(day)).toList(),
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
                    children: plan.attractions.map((attraction) => _buildAttractionCard(attraction)).toList(),
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
                    children: plan.restaurants.map((restaurant) => _buildRestaurantCard(restaurant)).toList(),
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
                    children: plan.tips.map((tip) => _buildTipItem(tip)).toList(),
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
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
              Icon(icon, color: const Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: const Color(0xFFFF4458)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
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
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildBudgetRow(l10n.transportation, plan.budget.transportation),
              Divider(height: 24.h),
              _buildBudgetRow(l10n.accommodation, plan.budget.accommodation),
              Divider(height: 24.h),
              _buildBudgetRow(l10n.foodAndDining, plan.budget.food),
              Divider(height: 24.h),
              _buildBudgetRow(l10n.activities, plan.budget.activities),
              Divider(height: 24.h),
              _buildBudgetRow(l10n.miscellaneous, plan.budget.miscellaneous),
              Divider(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalEstimatedCost,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${plan.budget.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20.sp,
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
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 15.sp,
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
      final flightSection = arrivalDetails.substring(flightRecommendationIndex + 8);
      flights = flightSection.split('\n').where((line) => line.trim().isNotEmpty).toList();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.plane, color: Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                plan.transportation.arrival?.method ?? 'N/A',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            generalInfo,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),

          // 航班推荐卡片
          if (flights.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4458).withValues(alpha: 0.05),
                    const Color(0xFFFF6B7A).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.plane,
                        color: Color(0xFFFF4458),
                        size: 18.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '航班推荐',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4458),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${flights.length}个选择',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...flights.asMap().entries.map((entry) {
                    final index = entry.key;
                    final flight = entry.value;

                    // 解析航班信息：航空公司 航班号 (时段) - 价格, 时长 - 备注
                    final parts = flight.split(' - ');
                    if (parts.length < 2) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          flight,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }

                    // 解析第一部分：航空公司 航班号 (时段)
                    final firstPart = parts[0];
                    final timeSlotMatch = RegExp(r'\(([^)]+)\)').firstMatch(firstPart);
                    final timeSlot = timeSlotMatch?.group(1) ?? '';
                    final airlineAndFlight = firstPart.replaceAll(RegExp(r'\s*\([^)]+\)'), '').trim();

                    // 解析第二部分：价格, 时长
                    final secondPart = parts[1];
                    final priceDuration = secondPart.split(', ');
                    final price = priceDuration.isNotEmpty ? priceDuration[0].trim() : '';
                    final duration = priceDuration.length > 1 ? priceDuration[1].trim() : '';

                    // 备注（如果有第三部分）
                    final notes = parts.length > 2 ? parts.sublist(2).join(' - ') : '';

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index < flights.length - 1 ? 12 : 0,
                      ),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4.r,
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
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      airlineAndFlight.split(' ').skip(1).join(' '), // 航班号
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 时段标签
                              if (timeSlot.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTimeSlotColor(timeSlot),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    timeSlot,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          // 价格和时长
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 8.w,
                            children: [
                              _buildInfoTag(
                                icon: FontAwesomeIcons.dollarSign,
                                label: price,
                                iconColor: Colors.green[600],
                                backgroundColor: Colors.green.withValues(alpha: 0.08),
                              ),
                              _buildInfoTag(
                                icon: FontAwesomeIcons.clock,
                                label: duration,
                                iconColor: Colors.indigo[500],
                                backgroundColor: Colors.indigo.withValues(alpha: 0.07),
                              ),
                            ],
                          ),
                          // 备注信息
                          if (notes.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(FontAwesomeIcons.circleInfo, size: 14.r, color: Colors.blue[400]),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    notes,
                                    style: TextStyle(
                                      fontSize: 12.sp,
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

          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
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
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.trainSubway, color: Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                plan.transportation.localTransport?.method ?? 'N/A',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            plan.transportation.localTransport?.details ?? 'No details available',
            style: TextStyle(
              fontSize: 14.sp,
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

  Widget _buildInfoTag({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor ?? Colors.grey[700]),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationCard(TravelPlan plan) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  plan.accommodation.type.name,
                  style: TextStyle(
                    fontSize: 12.sp,
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
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4458),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            plan.accommodation.recommendation,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot, size: 14.r, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                plan.accommodation.recommendedArea,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: plan.accommodation.amenities
                .map((amenity) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.lightbulb, size: 16.r, color: Colors.blue),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    plan.accommodation.bookingTips ?? '',
                    style: TextStyle(fontSize: 12.sp),
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
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4458),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      l10n.dayNumber(dayItinerary.day),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      dayItinerary.theme,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...dayItinerary.activities.map((activity) => _buildActivityItem(activity)),
              if (dayItinerary.notes != null && dayItinerary.notes!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(FontAwesomeIcons.circleInfo, size: 16.r, color: Colors.amber),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          dayItinerary.notes!,
                          style: TextStyle(fontSize: 12.sp),
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              activity.time,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.locationDot, size: 12.r, color: Colors.grey[500]),
                    SizedBox(width: 4.w),
                    Text(
                      activity.location,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(FontAwesomeIcons.dollarSign, size: 12.r, color: Colors.grey[500]),
                    Text(
                      '\$${activity.estimatedCost.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11.sp,
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
            child: Image.network(
              attraction.image ?? '',
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.image),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    attraction.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.star, size: 12.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        attraction.rating.toString(),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      SizedBox(width: 12.w),
                      Icon(FontAwesomeIcons.dollarSign, size: 12.r, color: Color(0xFFFF4458)),
                      Text(
                        '\$${attraction.entryFee.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 11.sp),
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
            child: Image.network(
              restaurant.image ?? '',
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.utensils),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.specialty,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.star, size: 12.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        restaurant.rating.toString(),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        restaurant.priceSymbol,
                        style: TextStyle(
                          fontSize: 11.sp,
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
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4458),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
