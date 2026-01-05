import 'package:df_admin_mobile/controllers/add_innovation_page_controller.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_basic_info_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_business_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_image_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_market_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_problem_solution_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_progress_section.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_team_section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Add Innovation Project Page
/// 添加创意项目页面（支持编辑模式）
class AddInnovationPage extends StatelessWidget {
  /// 编辑模式下传入的项目数据，null 表示创建新项目
  final InnovationProject? project;

  const AddInnovationPage({super.key, this.project});

  /// 是否为编辑模式
  bool get isEditMode => project != null;

  String get _controllerTag => 'add_innovation_${project?.id ?? 'new'}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final tag = _controllerTag;
    final l10n = AppLocalizations.of(context)!;

    // 注册控制器
    Get.put(AddInnovationPageController(project: project), tag: tag);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 延迟清理，确保页面完全销毁后再删除 controller
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _cleanupController(tag);
          });
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context, l10n, tag),
        body: _buildBody(context, l10n, tag),
      ),
    );
  }

  void _cleanupController(String tag) {
    if (Get.isRegistered<AddInnovationPageController>(tag: tag)) {
      Get.delete<AddInnovationPageController>(tag: tag);
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n, String tag) {
    final controller = Get.find<AddInnovationPageController>(tag: tag);
    
    return AppBar(
      title: Text(isEditMode ? l10n.editProject : l10n.createInnovationProject),
      centerTitle: true,
      elevation: 0,
      actions: [
        Obx(() => controller.isSubmitting.value
            ? Container(
                padding: const EdgeInsets.all(16),
                child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(FontAwesomeIcons.check),
                onPressed: () => _handleSubmit(context, tag),
              )),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, String tag) {
    final controller = Get.find<AddInnovationPageController>(tag: tag);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片区域
            AddInnovationImageSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 基本信息
            _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
            const SizedBox(height: 12),
            AddInnovationBasicInfoSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 问题与解决方案
            _buildSectionTitle(l10n.problemAndSolution, FontAwesomeIcons.lightbulb),
            const SizedBox(height: 12),
            AddInnovationProblemSolutionSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 市场定位
            _buildSectionTitle(l10n.marketPositioning, FontAwesomeIcons.bullseye),
            const SizedBox(height: 12),
            AddInnovationMarketSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 竞争与商业
            _buildSectionTitle(l10n.competitionAndBusiness, FontAwesomeIcons.chartLine),
            const SizedBox(height: 12),
            AddInnovationBusinessSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 进展与需求
            _buildSectionTitle(l10n.progressAndNeeds, FontAwesomeIcons.flagCheckered),
            const SizedBox(height: 12),
            AddInnovationProgressSection(controllerTag: tag),
            const SizedBox(height: 24),

            // 团队成员
            AddInnovationTeamSection(controllerTag: tag),
            const SizedBox(height: 32),

            // 提交按钮
            _buildSubmitButton(context, l10n, tag),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n, String tag) {
    final controller = Get.find<AddInnovationPageController>(tag: tag);

    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : () => _handleSubmit(context, tag),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 12),
                  Text('提交中...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEditMode ? FontAwesomeIcons.floppyDisk : FontAwesomeIcons.paperPlane, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEditMode ? l10n.save : l10n.submit,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      )),
    );
  }

  Future<void> _handleSubmit(BuildContext context, String tag) async {
    final controller = Get.find<AddInnovationPageController>(tag: tag);
    
    final success = await controller.submitForm(context, isEditMode: isEditMode);
    
    if (success && context.mounted) {
      // 只执行导航，controller 的清理由 PopScope.onPopInvokedWithResult 处理
      Navigator.of(context).pop(true);
    }
  }
}
