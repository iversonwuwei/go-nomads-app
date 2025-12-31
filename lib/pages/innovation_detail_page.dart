import 'package:df_admin_mobile/controllers/innovation_detail_page_controller.dart';
import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_innovation/add_innovation_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'direct_chat_page.dart';

/// Innovation Project Detail Page
/// 创意项目详情页面
class InnovationDetailPage extends StatelessWidget {
  final InnovationProject project;

  const InnovationDetailPage({super.key, required this.project});

  static const String _tag = 'InnovationDetailPage';

  InnovationDetailPageController _useController() {
    if (Get.isRegistered<InnovationDetailPageController>(tag: _tag)) {
      return Get.find<InnovationDetailPageController>(tag: _tag);
    }
    return Get.put(
      InnovationDetailPageController(initialProject: project),
      tag: _tag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Obx(() {
      // 加载中显示骨架屏
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF8B5CF6),
            leading: const SliverBackButton(),
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
            _buildSliverAppBar(controller, l10n),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. 一句话定位
                  _buildSection(
                    icon: FontAwesomeIcons.rocket,
                    title: l10n.elevatorPitch,
                    content: controller.project.elevatorPitch,
                    color: const Color(0xFF8B5CF6),
                  ),

                  const SizedBox(height: 24),

                  // 2. 要解决的问题
                  _buildSection(
                    icon: FontAwesomeIcons.circleExclamation,
                    title: l10n.problem,
                    content: controller.project.problem,
                    color: const Color(0xFFEF4444),
                  ),

                  const SizedBox(height: 24),

                  // 3. 解决方案
                  _buildSection(
                    icon: FontAwesomeIcons.lightbulb,
                    title: l10n.solution,
                    content: controller.project.solution,
                    color: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 24),

                  // 4. 目标用户
                  _buildSection(
                    icon: FontAwesomeIcons.users,
                    title: l10n.targetAudience,
                    content: controller.project.targetAudience,
                    color: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 24),

                  // 5. 产品形态
                  _buildSection(
                    icon: FontAwesomeIcons.laptop,
                    title: l10n.productType,
                    content: controller.project.productType,
                    color: const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 24),

                  // 6. 核心功能
                  _buildListSection(
                    icon: FontAwesomeIcons.star,
                    title: l10n.keyFeatures,
                    items: controller.project.keyFeatures.split('\n').where((s) => s.isNotEmpty).toList(),
                    color: const Color(0xFF8B5CF6),
                  ),

                  const SizedBox(height: 24),

                  // 7. 竞争优势
                  _buildSection(
                    icon: FontAwesomeIcons.chartLine,
                    title: l10n.competitiveAdvantage,
                    content: controller.project.competitiveAdvantage,
                    color: const Color(0xFF6366F1),
                  ),

                  const SizedBox(height: 24),

                  // 8. 商业模式
                  _buildSection(
                    icon: FontAwesomeIcons.dollarSign,
                    title: l10n.businessModel,
                    content: controller.project.businessModel,
                    color: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 24),

                  // 9. 市场潜力
                  _buildSection(
                    icon: FontAwesomeIcons.chartLine,
                    title: l10n.marketOpportunity,
                    content: controller.project.marketOpportunity,
                    color: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 24),

                  // 10. 当前进展
                  _buildSection(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: l10n.currentStatus,
                    content: controller.project.currentStatus,
                    color: const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 24),

                  // 11. 团队介绍
                  _buildTeamSection(
                    context: context,
                    icon: FontAwesomeIcons.userGroup,
                    title: l10n.team,
                    team: controller.project.team,
                    color: const Color(0xFF8B5CF6),
                  ),

                  const SizedBox(height: 24),

                  // 12. 所需支持
                  _buildSection(
                    icon: FontAwesomeIcons.handshake,
                    title: l10n.ask,
                    content: controller.project.ask,
                    color: const Color(0xFFEF4444),
                  ),

                  const SizedBox(height: 32),

                  // Footer - Creator Info
                  _buildCreatorFooter(controller, l10n),

                  const SizedBox(height: 32),

                  // 底部留白,为底部栏留出空间
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
        // 底部栏
        bottomNavigationBar: _buildBottomBar(context, controller, l10n),
      );
    });
  }

  Widget _buildSliverAppBar(InnovationDetailPageController controller, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF8B5CF6),
      leading: const SliverBackButton(),
      actions: [
        // 编辑按钮 - 仅当 canEdit 为 true 时显示
        if (controller.project.canEdit)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.white, size: 20),
              onPressed: () => _navigateToEdit(context, controller),
              tooltip: l10n.edit,
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.project.projectName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(128, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: controller.project.imageUrl != null && controller.project.imageUrl!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    controller.project.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultHeader();
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildDefaultHeader(),
      ),
    );
  }

  /// 跳转到编辑页面
  Future<void> _navigateToEdit(BuildContext context, InnovationDetailPageController controller) async {
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

  Widget _buildCreatorFooter(InnovationDetailPageController controller, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF8B5CF6),
            child: Text(
              (controller.project.userName ?? '?').substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.project.userName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.createdAt} ${controller.formatDate(controller.project.createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部栏
  Widget _buildBottomBar(BuildContext context, InnovationDetailPageController controller, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 关注按钮
            Expanded(
              flex: 1,
              child: Obx(() => OutlinedButton.icon(
                onPressed: controller.isToggling.value ? null : () => controller.toggleFollow(context),
                icon: Icon(
                  controller.isFollowed.value ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  size: 20,
                ),
                label: Text(
                  controller.isToggling.value ? '处理中...' : (controller.isFollowed.value ? '已关注' : '关注'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: controller.isFollowed.value ? const Color(0xFF8B5CF6) : Colors.grey[700],
                  side: BorderSide(
                    color: controller.isFollowed.value ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
            ),
            const SizedBox(width: 12),
            // 联系按钮
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _contactCreator(controller),
                icon: const Icon(FontAwesomeIcons.message, size: 20),
                label: Text(
                  l10n.message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 联系创建者
  void _contactCreator(InnovationDetailPageController controller) {
    Get.to(() => DirectChatPage(user: controller.creatorUser));
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4a5568),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < items.length - 1 ? 12 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4a5568),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<TeamMember> team,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (team.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(FontAwesomeIcons.userGroup, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.noTeamMembersAdded,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          ...team.map((member) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color,
                      child: Text(
                        member.name.isNotEmpty ? member.name.substring(0, 1) : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${member.name} - ${member.role}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4a5568),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  /// 构建默认的 Header 背景
  Widget _buildDefaultHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6366F1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 80,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
