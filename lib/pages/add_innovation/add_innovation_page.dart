import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/add_innovation_page_controller.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_basic_info_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_business_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_image_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_market_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_problem_solution_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_progress_section.dart';
import 'package:go_nomads_app/pages/add_innovation/add_innovation_team_section.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Add Innovation Project Page
/// 添加创意项目页面（支持编辑模式）
class AddInnovationPage extends StatefulWidget {
  /// 编辑模式下传入的项目数据，null 表示创建新项目
  final InnovationProject? project;

  const AddInnovationPage({super.key, this.project});

  @override
  State<AddInnovationPage> createState() => _AddInnovationPageState();
}

class _AddInnovationPageState extends State<AddInnovationPage> {
  /// 是否为编辑模式
  bool get isEditMode => widget.project != null;

  /// tag 在 State 创建时固定，后续 rebuild 不会改变
  late final String _controllerTag =
      'add_innovation_${widget.project?.id ?? 'new'}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    // 在 initState 中注册控制器，确保只注册一次
    Get.put(AddInnovationPageController(project: widget.project), tag: _controllerTag);
  }

  @override
  void dispose() {
    _cleanupController(_controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tag = _controllerTag;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(context, l10n, tag),
      body: _buildBody(context, l10n, tag),
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
                padding: EdgeInsets.all(16.w),
                child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)),
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片区域
            AddInnovationImageSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 基本信息
            _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
            SizedBox(height: 12.h),
            AddInnovationBasicInfoSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 问题与解决方案
            _buildSectionTitle(l10n.problemAndSolution, FontAwesomeIcons.lightbulb),
            SizedBox(height: 12.h),
            AddInnovationProblemSolutionSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 市场定位
            _buildSectionTitle(l10n.marketPositioning, FontAwesomeIcons.bullseye),
            SizedBox(height: 12.h),
            AddInnovationMarketSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 竞争与商业
            _buildSectionTitle(l10n.competitionAndBusiness, FontAwesomeIcons.chartLine),
            SizedBox(height: 12.h),
            AddInnovationBusinessSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 进展与需求
            _buildSectionTitle(l10n.progressAndNeeds, FontAwesomeIcons.flagCheckered),
            SizedBox(height: 12.h),
            AddInnovationProgressSection(controllerTag: tag),
            SizedBox(height: 24.h),

            // 团队成员
            AddInnovationTeamSection(controllerTag: tag),
            SizedBox(height: 32.h),

            // 提交按钮
            _buildSubmitButton(context, l10n, tag),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withAlpha(25),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.r, color: const Color(0xFF8B5CF6)),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 12.w),
                      Text(l10n.submitting, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEditMode ? FontAwesomeIcons.floppyDisk : FontAwesomeIcons.paperPlane, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(
                    isEditMode ? l10n.save : l10n.submit,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
