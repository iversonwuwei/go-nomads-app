import 'package:go_nomads_app/controllers/innovation_detail_page_controller.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_page.dart';
import 'package:go_nomads_app/pages/tencent_im_direct_chat_page.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_app_bar.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_bottom_bar.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_creator_section.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_section.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_team_section.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Project Detail Page
/// 创意项目详情页面 - 使用小组件组合模式
class InnovationDetailPage extends StatelessWidget {
  final InnovationProject project;

  const InnovationDetailPage({super.key, required this.project});

  String get _controllerTag => 'innovation_detail_${project.uuid ?? project.id}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      InnovationDetailPageController(initialProject: project),
      tag: _controllerTag,
    );

    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(controller);
        }
      },
      child: Obx(() {
        // 加载中显示骨架屏
        if (controller.isLoading.value) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              surfaceTintColor: Colors.transparent,
              leading: SliverBackButton(onPressed: () => _handleBack(controller)),
              title: Text(project.projectName),
            ),
            body: const InnovationDetailSkeleton(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              InnovationDetailAppBar(
                controllerTag: _controllerTag,
                onEdit: () => _navigateToEdit(context, controller),
              ),

              // Content
              SliverPadding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildContentSections(context, controller, l10n),
                  ),
                ),
              ),
            ],
          ),
          // 底部栏
          bottomNavigationBar: InnovationDetailBottomBar(
            controllerTag: _controllerTag,
            onContact: () => _contactCreator(controller),
          ),
        );
      }),
    );
  }

  List<Widget> _buildContentSections(
    BuildContext context,
    InnovationDetailPageController controller,
    AppLocalizations l10n,
  ) {
    return [
      // 1. 一句话定位
      _buildOverviewCard(context, controller, l10n),

      SizedBox(height: 24.h),

      // 1. 一句话定位
      InnovationDetailSection(
        icon: FontAwesomeIcons.rocket,
        title: l10n.elevatorPitch,
        content: controller.project.elevatorPitch,
        color: AppColors.cityPrimary,
      ),

      SizedBox(height: 24.h),

      // 2. 要解决的问题
      InnovationDetailSection(
        icon: FontAwesomeIcons.circleExclamation,
        title: l10n.problem,
        content: controller.project.problem,
        color: AppColors.feedbackError,
      ),

      SizedBox(height: 24.h),

      // 3. 解决方案
      InnovationDetailSection(
        icon: FontAwesomeIcons.lightbulb,
        title: l10n.solution,
        content: controller.project.solution,
        color: AppColors.travelMint,
      ),

      SizedBox(height: 24.h),

      // 4. 目标用户
      InnovationDetailSection(
        icon: FontAwesomeIcons.users,
        title: l10n.targetAudience,
        content: controller.project.targetAudience,
        color: AppColors.travelSky,
      ),

      SizedBox(height: 24.h),

      // 5. 产品形态
      InnovationDetailSection(
        icon: FontAwesomeIcons.laptop,
        title: l10n.productType,
        content: controller.project.productType,
        color: AppColors.travelAmber,
      ),

      SizedBox(height: 24.h),

      // 6. 核心功能
      InnovationDetailListSection(
        icon: FontAwesomeIcons.star,
        title: l10n.keyFeatures,
        items: controller.project.keyFeatures.split('\n').where((s) => s.isNotEmpty).toList(),
        color: AppColors.cityPrimary,
      ),

      SizedBox(height: 24.h),

      // 7. 竞争优势
      InnovationDetailSection(
        icon: FontAwesomeIcons.chartLine,
        title: l10n.competitiveAdvantage,
        content: controller.project.competitiveAdvantage,
        color: AppColors.travelSky,
      ),

      SizedBox(height: 24.h),

      // 8. 商业模式
      InnovationDetailSection(
        icon: FontAwesomeIcons.dollarSign,
        title: l10n.businessModel,
        content: controller.project.businessModel,
        color: AppColors.travelMint,
      ),

      SizedBox(height: 24.h),

      // 9. 市场潜力
      InnovationDetailSection(
        icon: FontAwesomeIcons.chartLine,
        title: l10n.marketOpportunity,
        content: controller.project.marketOpportunity,
        color: AppColors.travelSky,
      ),

      SizedBox(height: 24.h),

      // 10. 当前进展
      InnovationDetailSection(
        icon: FontAwesomeIcons.clockRotateLeft,
        title: l10n.currentStatus,
        content: controller.project.currentStatus,
        color: AppColors.travelAmber,
      ),

      SizedBox(height: 24.h),

      // 11. 团队介绍
      InnovationDetailTeamSection(
        icon: FontAwesomeIcons.userGroup,
        title: l10n.team,
        team: controller.project.team,
        color: AppColors.cityPrimary,
      ),

      SizedBox(height: 24.h),

      // 12. 所需支持
      InnovationDetailSection(
        icon: FontAwesomeIcons.handshake,
        title: l10n.ask,
        content: controller.project.ask,
        color: AppColors.feedbackError,
      ),

      SizedBox(height: 32.h),

      // Footer - Creator Info
      InnovationDetailCreatorSection(controllerTag: _controllerTag),

      SizedBox(height: 32.h),

      // 底部留白,为底部栏留出空间
      SizedBox(height: 80.h),
    ];
  }

  Widget _buildOverviewCard(
    BuildContext context,
    InnovationDetailPageController controller,
    AppLocalizations l10n,
  ) {
    final currentProject = controller.project;
    final featureCount = _splitLines(currentProject.keyFeatures).length;

    return Container(
      padding: AppUiTokens.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.heroCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildSignalChip(
                icon: FontAwesomeIcons.laptop,
                label: l10n.productType,
                value: currentProject.productType,
                color: AppColors.cityPrimary,
              ),
              _buildSignalChip(
                icon: FontAwesomeIcons.clockRotateLeft,
                label: l10n.currentStatus,
                value: currentProject.currentStatus,
                color: AppColors.travelAmber,
              ),
              _buildSignalChip(
                icon: FontAwesomeIcons.userGroup,
                label: l10n.team,
                value: '${currentProject.teamSize}',
                color: AppColors.travelSky,
              ),
              _buildSignalChip(
                icon: FontAwesomeIcons.star,
                label: l10n.keyFeatures,
                value: '$featureCount',
                color: AppColors.travelMint,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            currentProject.elevatorPitch,
            style: TextStyle(
              fontSize: 18.sp,
              height: 1.55,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            currentProject.userName?.isNotEmpty == true
                ? '${currentProject.userName} · ${controller.formatDate(currentProject.createdAt)}'
                : controller.formatDate(currentProject.createdAt),
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: FontAwesomeIcons.eye,
                  label: 'Views',
                  value: '${currentProject.viewCount ?? 0}',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricTile(
                  icon: FontAwesomeIcons.heart,
                  label: 'Likes',
                  value: '${currentProject.likeCount ?? 0}',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricTile(
                  icon: FontAwesomeIcons.commentDots,
                  label: 'Comments',
                  value: '${currentProject.commentCount ?? 0}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(width: 6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 148.w),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: AppColors.textSecondary),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _handleBack(InnovationDetailPageController controller) {
    _cleanupController();
    Navigator.pop(Get.context!);
  }

  /// 跳转到编辑页面
  Future<void> _navigateToEdit(
    BuildContext context,
    InnovationDetailPageController controller,
  ) async {
    await NavigationUtil.toWithCallback<bool>(
      page: () => AddInnovationPage(project: controller.project),
      onResult: (result) {
        // 如果返回需要刷新，说明编辑成功，刷新数据
        if (result.needsRefresh) {
          controller.loadFullProject();
        }
      },
    );
  }

  /// 联系创建者
  void _contactCreator(InnovationDetailPageController controller) {
    Get.to(() => TencentIMDirectChatPage(user: controller.creatorUser));
  }

  void _cleanupController() {
    if (Get.isRegistered<InnovationDetailPageController>(tag: _controllerTag)) {
      Get.delete<InnovationDetailPageController>(tag: _controllerTag);
    }
  }
}
