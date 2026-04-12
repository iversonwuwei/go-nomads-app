import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/innovation_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/admin_delete_button.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/report_button.dart';
import 'package:go_nomads_app/widgets/report_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Detail App Bar Section
/// 创意项目详情页 - AppBar 区域
class InnovationDetailAppBar extends StatelessWidget {
  final String controllerTag;
  final VoidCallback? onEdit;

  const InnovationDetailAppBar({
    super.key,
    required this.controllerTag,
    this.onEdit,
  });

  InnovationDetailPageController get _c => Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => SliverAppBar(
          expandedHeight: 280.h,
          pinned: true,
          titleSpacing: 0,
          backgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: const SliverBackButton(),
          title: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Text(
              _c.project.projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          actions: [
            // 管理员删除按钮
            if (_c.isAdmin.value)
              AdminDeleteButton(
                isAdmin: true,
                entityName: '创新项目',
                onDelete: () => _c.deleteInnovationProject(),
              ),
            // 编辑按钮 - 仅当 canEdit 为 true 时显示
            if (_c.project.canEdit)
              IconButton(
                icon: Icon(FontAwesomeIcons.penToSquare, color: AppColors.textPrimary, size: 20.r),
                onPressed: onEdit,
                tooltip: l10n.edit,
              ),
            // 举报按钮 - 非创建者且非管理员可见
            if (!_c.project.canEdit && !_c.isAdmin.value)
              SliverReportButton(
                onPressed: () {
                  ReportDialog.show(
                    context: context,
                    contentType: ReportContentType.innovationProject,
                    targetId: _c.project.uuid ?? '',
                    targetName: _c.project.projectName,
                  );
                },
                tooltip: l10n.report,
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildBackground(context),
          ),
        ));
  }

  Widget _buildBackground(BuildContext context) {
    final imageUrl = _c.project.imageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultHeader();
            },
          )
        else
          _buildDefaultHeader(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.06),
                Colors.black.withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 24.h,
          child: _buildHeroContent(context),
        ),
      ],
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final project = _c.project;
    final featureCount = project.keyFeatures
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .length;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildHeroChip(
                icon: FontAwesomeIcons.laptop,
                value: project.productType,
              ),
              _buildHeroChip(
                icon: FontAwesomeIcons.clockRotateLeft,
                value: project.currentStatus,
              ),
              _buildHeroChip(
                icon: FontAwesomeIcons.userGroup,
                value: '${project.teamSize} ${l10n.team}',
              ),
              _buildHeroChip(
                icon: FontAwesomeIcons.star,
                value: '$featureCount ${l10n.keyFeatures}',
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            project.projectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            project.elevatorPitch,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: Colors.white),
          SizedBox(width: 6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建默认的 Header 背景
  Widget _buildDefaultHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cityPrimary.withValues(alpha: 0.85),
            AppColors.travelAmber.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 80.r,
          color: Colors.white.withValues(alpha: 0.26),
        ),
      ),
    );
  }
}
