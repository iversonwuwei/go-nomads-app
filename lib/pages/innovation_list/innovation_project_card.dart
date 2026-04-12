import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/innovation_list_page_controller.dart';
import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/innovation_detail/innovation_detail_page.dart';
import 'package:go_nomads_app/pages/tencent_im_direct_chat_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Project Card Widget
/// 创意项目卡片组件
class InnovationProjectCard extends StatelessWidget {
  final InnovationProject project;
  final String controllerTag;

  const InnovationProjectCard({
    super.key,
    required this.project,
    required this.controllerTag,
  });

  InnovationListPageController get _c => Get.find<InnovationListPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目封面
          _buildCoverImage(context),
          // 项目信息
          _buildProjectInfo(context, l10n),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: project.imageUrl != null && project.imageUrl!.isNotEmpty
              ? Image.network(
                  project.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultCover();
                  },
                )
              : _buildDefaultCover(),
        ),
        // 关注按钮 - 右上角
        Positioned(
          top: 12.h,
          right: 12.w,
          child: InnovationFollowButton(
            projectId: project.uuid ?? project.id.toString(),
            project: project,
            controllerTag: controllerTag,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目名称
          Text(
            project.projectName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          // 一句话定位
          Text(
            project.elevatorPitch,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12.h),

          // 产品类型标签
          _buildTags(),

          SizedBox(height: 12.h),

          // 创建者和时间
          _buildCreatorInfo(context),

          SizedBox(height: 16.h),

          // 操作按钮
          _buildActionButtons(context, l10n),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: [
        _buildTag(project.productType, AppColors.cityPrimary),
        ...project.keyFeatures
            .split("\n")
            .map((feature) => feature.trim())
            .where((feature) => feature.isNotEmpty)
            .take(2)
            .map((feature) => _buildTag(feature, AppColors.travelSky)),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCreatorInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.cityPrimaryLight,
          backgroundImage:
              project.userAvatar != null && project.userAvatar!.isNotEmpty ? NetworkImage(project.userAvatar!) : null,
          child: project.userAvatar == null || project.userAvatar!.isEmpty
              ? Text(
                  (project.userName ?? '?').isNotEmpty ? (project.userName ?? '?').substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.cityPrimary,
                    fontSize: 12.sp,
                  ),
                )
              : null,
        ),
        SizedBox(width: 8.w),
        Text(
          project.userName ?? 'Unknown',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Icon(FontAwesomeIcons.clock, size: 14.r, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          _c.formatDate(context, project.updatedAt ?? project.createdAt),
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    // 如果当前用户是创建者，不显示联系作者按钮
    final isCreator = project.canEdit;

    return Row(
      children: [
        // 查看详情按钮
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InnovationDetailPage(project: project),
                ),
              );
            },
            icon: Icon(FontAwesomeIcons.eye, size: 18.r),
            label: Text(l10n.viewDetails),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cityPrimary,
              side: const BorderSide(color: AppColors.cityPrimary),
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              ),
            ),
          ),
        ),
        // 一对一聊天按钮（仅非创建者显示）
        if (!isCreator) ...[
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToChat(context),
              icon: Icon(FontAwesomeIcons.comments, size: 18.r),
              label: Text(l10n.contactCreator),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToChat(BuildContext context) {
    // 使用 creatorUuid（创建者的真实 UUID）而不是 userId（hashCode）
    final creatorId = project.creatorUuid ?? project.userId.toString();
    final chatUser = models.User(
      id: creatorId,
      name: project.userName ?? 'Unknown',
      username: project.userName ?? 'unknown',
      avatarUrl: project.userAvatar,
      stats: models.TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0,
      ),
      joinedDate: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TencentIMDirectChatPage(user: chatUser),
      ),
    );
  }

  /// 构建默认封面占位图
  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cityPrimaryLight,
            AppColors.surfaceSubtle,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 50.r,
          color: AppColors.cityPrimary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// Innovation Follow Button Widget
/// 创意项目关注按钮组件
class InnovationFollowButton extends StatelessWidget {
  final String projectId;
  final InnovationProject project;
  final String controllerTag;

  const InnovationFollowButton({
    super.key,
    required this.projectId,
    required this.project,
    required this.controllerTag,
  });

  InnovationListPageController get _c => Get.find<InnovationListPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isFollowed = _c.isProjectFollowed(projectId, project);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _c.toggleFollow(context, projectId),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isFollowed ? AppColors.cityPrimary : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: AppUiTokens.softFloatingShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFollowed ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 16.r,
                  color: isFollowed ? Colors.white : AppColors.cityPrimary,
                ),
                SizedBox(width: 4.w),
                Text(
                  isFollowed ? l10n.following : l10n.follow,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isFollowed ? Colors.white : AppColors.cityPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
