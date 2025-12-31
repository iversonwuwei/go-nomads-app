import 'package:df_admin_mobile/controllers/innovation_list_page_controller.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as models;
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/innovation_detail/innovation_detail_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'add_innovation/add_innovation_page.dart';
import 'direct_chat_page.dart';

/// Innovation Projects List Page
/// 创意项目列表页面
class InnovationListPage extends StatelessWidget {
  const InnovationListPage({super.key});

  static const String _tag = 'InnovationListPage';

  InnovationListPageController _useController() {
    if (Get.isRegistered<InnovationListPageController>(tag: _tag)) {
      return Get.find<InnovationListPageController>(tag: _tag);
    }
    return Get.put(InnovationListPageController(), tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: Color(0xFF1a1a1a)),
        title: Text(
          l10n.innovation,
          style: const TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          if (!controller.controllerInitialized.value) {
            return _buildContent(context, controller, l10n, isMobile, controller.displayProjects);
          }

          final stateController = controller.stateController;
          if (stateController == null) {
            return _buildContent(context, controller, l10n, isMobile, controller.displayProjects);
          }

          if (stateController.isLoading.value && stateController.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stateController.errorMessage.value != null && stateController.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    stateController.errorMessage.value!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadProjects(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return _buildContent(context, controller, l10n, isMobile, controller.displayProjects);
        }),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    InnovationListPageController controller,
    AppLocalizations l10n,
    bool isMobile,
    List<InnovationProject> projects,
  ) {
    return ListView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      children: [
        // Create Project Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddInnovationPage(),
                ),
              );

              // 如果添加成功,刷新数据
              if (result == true) {
                await controller.refreshData();
              }
            },
            icon: const Icon(FontAwesomeIcons.circlePlus, size: 24),
            label: Text(
              l10n.createMyInnovation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Section Title
        Row(
          children: [
            const Icon(
              FontAwesomeIcons.compass,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.exploreInnovations,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Projects List
        if (projects.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Icon(FontAwesomeIcons.lightbulb, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无创意项目',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '成为第一个分享创意的人吧！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          )
        else
          ...projects.map((project) => _buildProjectCard(context, controller, project, isMobile, l10n)),
      ],
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    InnovationListPageController controller,
    InnovationProject project,
    bool isMobile,
    AppLocalizations l10n,
  ) {
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
          Stack(
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
                child: _buildFollowButton(context, controller, project.uuid ?? project.id.toString(), project),
              ),
            ],
          ),

          Padding(
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(project.productType, const Color(0xFF8B5CF6)),
                    ...project.keyFeatures
                        .split("\n")
                        .take(2)
                        .map((feature) => _buildTag(feature, const Color(0xFF6366F1))),
                  ],
                ),

                const SizedBox(height: 12),

                // 创建者和时间
                Row(
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
                      controller.formatDate(context, project.updatedAt ?? project.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 操作按钮
                Row(
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
                        onPressed: () {
                          // 创建临时用户对象用于聊天
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
                        },
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
                ),
              ],
            ),
          ),
        ],
      ),
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

  /// 构建关注按钮
  Widget _buildFollowButton(
    BuildContext context,
    InnovationListPageController controller,
    String projectId,
    InnovationProject project,
  ) {
    return Obx(() {
      final isFollowed = controller.isProjectFollowed(projectId, project);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleFollow(context, projectId),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowed ? const Color(0xFF8B5CF6) : Colors.white.withAlpha(230),
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
                  isFollowed ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
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
