import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/membership/presentation/services/ai_quota_service.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Guide Tab - AI 数字游民指南
/// 使用 GetView 绑定 CityDetailController
class GuideTab extends GetView<CityDetailController> {
  @override
  final String? tag;

  const GuideTab({
    super.key,
    required this.tag,
  });

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
    if (!controller.hasInitializedGuide.value || 
        controller.lastGuideLoadedCityId.value != controller.cityId) {
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
      children: [
        // AI 操作栏
        _GuideActionBar(
          aiController: aiController,
          cityId: cityId,
          cityName: cityName,
        ),
        const SizedBox(height: 16),
        
        // 概述
        Text(
          l10n.overview,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          guide.overview,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 24),
        
        // 最佳区域
        const Text(
          'Best Areas to Stay',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...guide.bestAreas.map((area) => _BestAreaCard(area: area)),
        const SizedBox(height: 24),
        
        // 实用建议
        const Text(
          'Essential Tips',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.cloudArrowUp, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '☁️ 从后端加载',
              style: TextStyle(fontSize: 13, color: Colors.green[800]),
            ),
          ),
          Obx(() => Row(
            children: [
              TextButton.icon(
                onPressed: aiController.isGeneratingGuide || aiController.isLoadingGuide
                    ? null
                    : () => aiController.loadCityGuide(cityId: cityId, cityName: cityName),
                icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
                label: const Text('刷新'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cityPrimary,
                  disabledForegroundColor: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: aiController.isGeneratingGuide || aiController.isLoadingGuide
                    ? null
                    : () => _handleAIGenerate(context),
                icon: const Icon(FontAwesomeIcons.wandMagicSparkles, size: 18),
                label: const Text('AI 生成'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cityPrimary,
                  disabledForegroundColor: Colors.grey[400],
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
    _showAIGenerateProgressDialog(context);
  }

  void _showAIGenerateProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('AI 生成指南'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(aiController.guideGenerationMessage),
            const SizedBox(height: 8),
            Text('${aiController.guideGenerationProgress}%'),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    
    aiController.generateDigitalNomadGuideStream(cityId: cityId, cityName: cityName).then((_) {
      Navigator.pop(context);
    });
  }
}

/// 加载状态
class _GuideLoadingState extends StatelessWidget {
  final AiStateController aiController;

  const _GuideLoadingState({required this.aiController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Obx(() => Text(
            aiController.isGeneratingGuide ? '🤖 AI 正在生成旅游指南...' : '📖 正在加载旅游指南...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          )),
          if (aiController.isGeneratingGuide) ...[
            const SizedBox(height: 12),
            Obx(() => Text(
              aiController.guideGenerationMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 8),
            Obx(() => Text(
              '${aiController.guideGenerationProgress}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.cityPrimary,
              ),
            )),
          ],
        ],
      ),
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
            const Icon(FontAwesomeIcons.map, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(l10n.loadingGuide, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton.icon(
              onPressed: aiController.isGeneratingGuide
                  ? null
                  : () => _handleAIGenerate(context),
              icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
              label: const Text('AI 生成指南'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(FontAwesomeIcons.locationDot, color: AppColors.cityPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  area.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              area.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18, color: AppColors.cityPrimary)),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
