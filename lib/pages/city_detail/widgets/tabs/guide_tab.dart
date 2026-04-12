import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_quota_service.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

/// Guide Tab - AI 数字游民指南
/// 使用 GetView 绑定 CityDetailController
class GuideTab extends GetView<CityDetailController> {
  final String? _tag;

  const GuideTab({
    super.key,
    required String? tag,
  }) : _tag = tag;

  @override
  String? get tag => _tag;

  @override
  Widget build(BuildContext context) {
    final aiController = Get.find<AiStateController>();

    // 首次加载或城市变化时请求数据
    _initializeGuideData(aiController);

    return Obx(() {
      log('🔍 [GuideTab] Rebuilding... cityId=${controller.cityId}');

      final guide = aiController.currentGuide;

      // 显示指南内容
      if (guide != null && guide.cityId == controller.cityId) {
        return _GuideContent(
          guide: guide,
          aiController: aiController,
          cityId: controller.cityId,
          cityName: controller.cityName,
        );
      }

      // 显示加载或生成状态
      if (aiController.isLoadingGuide || aiController.isGeneratingGuide) {
        return _GuideLoadingState(aiController: aiController);
      }

      // 空状态
      return _GuideEmptyState(
        aiController: aiController,
        cityId: controller.cityId,
        cityName: controller.cityName,
      );
    });
  }

  void _initializeGuideData(AiStateController aiController) {
    if (!controller.hasInitializedGuide.value || controller.lastGuideLoadedCityId.value != controller.cityId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentGuide = aiController.currentGuide;

        if (currentGuide != null && currentGuide.cityId != controller.cityId) {
          aiController.resetGuideState();
        }

        if (!aiController.isGeneratingGuide && !aiController.isLoadingGuide) {
          final shouldLoad = currentGuide == null || currentGuide.cityId != controller.cityId;
          if (shouldLoad) {
            aiController.loadCityGuide(
              cityId: controller.cityId,
              cityName: controller.cityName,
            );
          }
        }

        controller.hasInitializedGuide.value = true;
        controller.lastGuideLoadedCityId.value = controller.cityId;
      });
    }
  }
}

/// 指南内容组件
class _GuideContent extends StatelessWidget {
  final dynamic guide;
  final AiStateController aiController;
  final String cityId;
  final String cityName;

  const _GuideContent({
    required this.guide,
    required this.aiController,
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 96.h),
      children: [
        // AI 操作栏
        _GuideActionBar(
          aiController: aiController,
          cityId: cityId,
          cityName: cityName,
        ),
        SizedBox(height: 16.h),

        // 概述
        Text(
          l10n.overview,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          guide.overview,
          style: TextStyle(fontSize: 15.sp, color: Colors.grey[700], height: 1.5),
        ),
        SizedBox(height: 24.h),

        // 最佳区域
        Text(
          'Best Areas to Stay',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...guide.bestAreas.map((area) => _BestAreaCard(area: area)),
        SizedBox(height: 24.h),

        // 实用建议
        Text(
          'Essential Tips',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...guide.tips.map((tip) => _TipItem(tip: tip)),
      ],
    );
  }
}

/// 指南操作栏
class _GuideActionBar extends StatelessWidget {
  final AiStateController aiController;
  final String cityId;
  final String cityName;

  const _GuideActionBar({
    required this.aiController,
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.travelMint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              FontAwesomeIcons.cloudArrowUp,
              color: AppColors.feedbackSuccessDark,
              size: 16.r,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '☁️ 从后端加载',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(() => Row(
                children: [
                  TextButton.icon(
                    onPressed: aiController.isGeneratingGuide || aiController.isLoadingGuide
                        ? null
                        : () => aiController.loadCityGuide(cityId: cityId, cityName: cityName),
                    icon: Icon(FontAwesomeIcons.arrowsRotate, size: 18.r),
                    label: Text(l10n.refresh),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cityPrimary,
                      disabledForegroundColor: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  TextButton.icon(
                    onPressed: aiController.isGeneratingGuide || aiController.isLoadingGuide
                        ? null
                        : () => _handleAIGenerate(context),
                    icon: Icon(FontAwesomeIcons.wandMagicSparkles, size: 18.r),
                    label: Text(l10n.guideTabAiGenerate),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cityPrimary,
                      disabledForegroundColor: AppColors.textTertiary,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _handleAIGenerate(BuildContext context) async {
    // 使用统一的 AiQuotaService 检查配额
    final canUse = await AiQuotaService().checkAndUseAI(
      featureName: '数字游民指南生成',
      showUpgradeDialog: true,
    );

    if (!canUse) return;
    if (!context.mounted) return;
    _showAIGenerateProgressDialog(context);
  }

  void _showAIGenerateProgressDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AppBottomDrawer.show<void>(
      context,
      title: l10n.guideTabAiGenerateGuide,
      maxHeightFactor: 0.46,
      showHandle: false,
      isDismissible: false,
      enableDrag: false,
      child: Obx(() {
        final progress = aiController.guideGenerationProgress;
        final message = aiController.guideGenerationMessage;
        final isCompleted = aiController.isGuideCompleted;

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress / 100 : null,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : AppColors.cityPrimary,
                    ),
                  ),
                ),
                if (progress > 0)
                  Text(
                    '$progress%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              message.isNotEmpty ? message : '后端运行中...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              '⏳ 请耐心等待，AI 正在生成内容',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        );
      }),
    );

    aiController.generateDigitalNomadGuideStream(cityId: cityId, cityName: cityName).then((_) {
      if (context.mounted && Get.isBottomSheetOpen == true) {
        Get.back<void>();
      }
    });
  }
}

/// 加载状态
class _GuideLoadingState extends StatelessWidget {
  final AiStateController aiController;

  const _GuideLoadingState({required this.aiController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => AppLoadingWidget(
                        fullScreen: false,
                        cardWidth: 280,
                        cardHeight: 180,
                        title: aiController.isGeneratingGuide ? 'AI 正在生成旅游指南' : '正在加载旅游指南',
                        subtitle: aiController.isGeneratingGuide ? 'Generating guide...' : 'Loading guide...',
                        icon: Icons.menu_book_rounded,
                        accentColor: AppColors.cityPrimary,
                      )),
                  if (aiController.isGeneratingGuide) ...[
                    SizedBox(height: 12.h),
                    Obx(() => Text(
                          aiController.guideGenerationMessage,
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(height: 8.h),
                    Obx(() => Text(
                          '${aiController.guideGenerationProgress}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cityPrimary,
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 空状态
class _GuideEmptyState extends StatelessWidget {
  final AiStateController aiController;
  final String cityId;
  final String cityName;

  const _GuideEmptyState({
    required this.aiController,
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.map, size: 60.r, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(l10n.loadingGuide, style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
            SizedBox(height: 16.h),
            Obx(() => ElevatedButton.icon(
                  onPressed: aiController.isGeneratingGuide ? null : () => _handleAIGenerate(context),
                  icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
                  label: Text(l10n.guideTabAiGenerateGuide),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAIGenerate(BuildContext context) async {
    // 使用统一的 AiQuotaService 检查配额
    final canUse = await AiQuotaService().checkAndUseAI(
      featureName: '数字游民指南生成',
      showUpgradeDialog: true,
    );

    if (!canUse) return;

    aiController.generateDigitalNomadGuideStream(cityId: cityId, cityName: cityName);
  }
}

/// 最佳区域卡片
class _BestAreaCard extends StatelessWidget {
  final dynamic area;

  const _BestAreaCard({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.locationDot, color: AppColors.cityPrimary, size: 18.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    area.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              area.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 建议项
class _TipItem extends StatelessWidget {
  final String tip;

  const _TipItem({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FontAwesomeIcons.lightbulb, size: 18.r, color: AppColors.travelAmber),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
