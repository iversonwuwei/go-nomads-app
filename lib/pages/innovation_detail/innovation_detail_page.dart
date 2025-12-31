import 'package:df_admin_mobile/controllers/innovation_detail_page_controller.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_page.dart';
import 'package:df_admin_mobile/pages/direct_chat_page.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_app_bar.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_bottom_bar.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_creator_section.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_section.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_team_section.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF8B5CF6),
              leading: SliverBackButton(onPressed: () => _handleBack(controller)),
              title: Text(project.projectName),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
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
      InnovationDetailSection(
        icon: FontAwesomeIcons.rocket,
        title: l10n.elevatorPitch,
        content: controller.project.elevatorPitch,
        color: const Color(0xFF8B5CF6),
      ),

      const SizedBox(height: 24),

      // 2. 要解决的问题
      InnovationDetailSection(
        icon: FontAwesomeIcons.circleExclamation,
        title: l10n.problem,
        content: controller.project.problem,
        color: const Color(0xFFEF4444),
      ),

      const SizedBox(height: 24),

      // 3. 解决方案
      InnovationDetailSection(
        icon: FontAwesomeIcons.lightbulb,
        title: l10n.solution,
        content: controller.project.solution,
        color: const Color(0xFF10B981),
      ),

      const SizedBox(height: 24),

      // 4. 目标用户
      InnovationDetailSection(
        icon: FontAwesomeIcons.users,
        title: l10n.targetAudience,
        content: controller.project.targetAudience,
        color: const Color(0xFF3B82F6),
      ),

      const SizedBox(height: 24),

      // 5. 产品形态
      InnovationDetailSection(
        icon: FontAwesomeIcons.laptop,
        title: l10n.productType,
        content: controller.project.productType,
        color: const Color(0xFFF59E0B),
      ),

      const SizedBox(height: 24),

      // 6. 核心功能
      InnovationDetailListSection(
        icon: FontAwesomeIcons.star,
        title: l10n.keyFeatures,
        items: controller.project.keyFeatures
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        color: const Color(0xFF8B5CF6),
      ),

      const SizedBox(height: 24),

      // 7. 竞争优势
      InnovationDetailSection(
        icon: FontAwesomeIcons.chartLine,
        title: l10n.competitiveAdvantage,
        content: controller.project.competitiveAdvantage,
        color: const Color(0xFF6366F1),
      ),

      const SizedBox(height: 24),

      // 8. 商业模式
      InnovationDetailSection(
        icon: FontAwesomeIcons.dollarSign,
        title: l10n.businessModel,
        content: controller.project.businessModel,
        color: const Color(0xFF10B981),
      ),

      const SizedBox(height: 24),

      // 9. 市场潜力
      InnovationDetailSection(
        icon: FontAwesomeIcons.chartLine,
        title: l10n.marketOpportunity,
        content: controller.project.marketOpportunity,
        color: const Color(0xFF3B82F6),
      ),

      const SizedBox(height: 24),

      // 10. 当前进展
      InnovationDetailSection(
        icon: FontAwesomeIcons.clockRotateLeft,
        title: l10n.currentStatus,
        content: controller.project.currentStatus,
        color: const Color(0xFFF59E0B),
      ),

      const SizedBox(height: 24),

      // 11. 团队介绍
      InnovationDetailTeamSection(
        icon: FontAwesomeIcons.userGroup,
        title: l10n.team,
        team: controller.project.team,
        color: const Color(0xFF8B5CF6),
      ),

      const SizedBox(height: 24),

      // 12. 所需支持
      InnovationDetailSection(
        icon: FontAwesomeIcons.handshake,
        title: l10n.ask,
        content: controller.project.ask,
        color: const Color(0xFFEF4444),
      ),

      const SizedBox(height: 32),

      // Footer - Creator Info
      InnovationDetailCreatorSection(controllerTag: _controllerTag),

      const SizedBox(height: 32),

      // 底部留白,为底部栏留出空间
      const SizedBox(height: 80),
    ];
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddInnovationPage(project: controller.project),
      ),
    );
    // 如果返回 true，说明编辑成功，刷新数据
    if (result == true) {
      controller.loadFullProject();
    }
  }

  /// 联系创建者
  void _contactCreator(InnovationDetailPageController controller) {
    Get.to(() => DirectChatPage(user: controller.creatorUser));
  }

  void _cleanupController() {
    if (Get.isRegistered<InnovationDetailPageController>(tag: _controllerTag)) {
      Get.delete<InnovationDetailPageController>(tag: _controllerTag);
    }
  }
}
