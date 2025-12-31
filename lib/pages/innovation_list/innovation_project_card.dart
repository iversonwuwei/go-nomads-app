import 'package:df_admin_mobile/controllers/innovation_list_page_controller.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as models;
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/direct_chat_page.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

  InnovationListPageController get _c =>
      Get.find<InnovationListPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
          top: 12,
          right: 12,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目名称
          Text(
            project.projectName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),

          const SizedBox(height: 8),

          // 一句话定位
          Text(
            project.elevatorPitch,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // 产品类型标签
          _buildTags(),

          const SizedBox(height: 12),

          // 创建者和时间
          _buildCreatorInfo(context),

          const SizedBox(height: 16),

          // 操作按钮
          _buildActionButtons(context, l10n),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(project.productType, const Color(0xFF8B5CF6)),
        ...project.keyFeatures
            .split("\n")
            .take(2)
            .map((feature) => _buildTag(feature, const Color(0xFF6366F1))),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
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
          backgroundColor: const Color(0xFF8B5CF6),
          backgroundImage: project.userAvatar != null && project.userAvatar!.isNotEmpty
              ? NetworkImage(project.userAvatar!)
              : null,
          child: project.userAvatar == null || project.userAvatar!.isEmpty
              ? Text(
                  (project.userName ?? '?').isNotEmpty
                      ? (project.userName ?? '?').substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          project.userName ?? 'Unknown',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Icon(FontAwesomeIcons.clock, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _c.formatDate(context, project.updatedAt ?? project.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
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
            icon: const Icon(FontAwesomeIcons.eye, size: 18),
            label: Text(l10n.viewDetails),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B5CF6),
              side: const BorderSide(color: Color(0xFF8B5CF6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 一对一聊天按钮
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateToChat(context),
            icon: const Icon(FontAwesomeIcons.comments, size: 18),
            label: Text(l10n.contactCreator),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToChat(BuildContext context) {
    final chatUser = models.User(
      id: project.userId.toString(),
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
        builder: (context) => DirectChatPage(user: chatUser),
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
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFF6366F1).withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 50,
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
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

  InnovationListPageController get _c =>
      Get.find<InnovationListPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFollowed = _c.isProjectFollowed(projectId, project);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _c.toggleFollow(context, projectId),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowed
                  ? const Color(0xFF8B5CF6)
                  : Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFollowed
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  size: 16,
                  color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 4),
                Text(
                  isFollowed ? '已关注' : '关注',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFollowed ? Colors.white : const Color(0xFF8B5CF6),
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
