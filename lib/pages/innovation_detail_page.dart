import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';
import '../models/innovation_project_model.dart';

/// Innovation Project Detail Page
/// 创意项目详情页面
class InnovationDetailPage extends StatelessWidget {
  final InnovationProject project;

  const InnovationDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF8B5CF6),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                project.projectName,
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
              background: project.imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          project.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF8B5CF6),
                              child: const Icon(
                                Icons.lightbulb,
                                size: 80,
                                color: Colors.white,
                              ),
                            );
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
                  : Container(
                      color: const Color(0xFF8B5CF6),
                      child: const Icon(
                        Icons.lightbulb,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. 一句话定位
                _buildSection(
                  icon: Icons.rocket_launch,
                  title: l10n.elevatorPitch,
                  content: project.elevatorPitch,
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 2. 要解决的问题
                _buildSection(
                  icon: Icons.error_outline,
                  title: l10n.problem,
                  content: project.problem,
                  color: const Color(0xFFEF4444),
                ),

                const SizedBox(height: 24),

                // 3. 解决方案
                _buildSection(
                  icon: Icons.lightbulb_outline,
                  title: l10n.solution,
                  content: project.solution,
                  color: const Color(0xFF10B981),
                ),

                const SizedBox(height: 24),

                // 4. 目标用户
                _buildSection(
                  icon: Icons.people_outline,
                  title: l10n.targetAudience,
                  content: project.targetAudience,
                  color: const Color(0xFF3B82F6),
                ),

                const SizedBox(height: 24),

                // 5. 产品形态
                _buildSection(
                  icon: Icons.devices,
                  title: l10n.productType,
                  content: project.productType,
                  color: const Color(0xFFF59E0B),
                ),

                const SizedBox(height: 24),

                // 6. 核心功能
                _buildListSection(
                  icon: Icons.star_outline,
                  title: l10n.keyFeatures,
                  items: project.keyFeatures,
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 7. 竞争优势
                _buildSection(
                  icon: Icons.trending_up,
                  title: l10n.competitiveAdvantage,
                  content: project.competitiveAdvantage,
                  color: const Color(0xFF6366F1),
                ),

                const SizedBox(height: 24),

                // 8. 商业模式
                _buildSection(
                  icon: Icons.attach_money,
                  title: l10n.businessModel,
                  content: project.businessModel,
                  color: const Color(0xFF10B981),
                ),

                const SizedBox(height: 24),

                // 9. 市场潜力
                _buildSection(
                  icon: Icons.analytics_outlined,
                  title: l10n.marketOpportunity,
                  content: project.marketOpportunity,
                  color: const Color(0xFF3B82F6),
                ),

                const SizedBox(height: 24),

                // 10. 当前进展
                _buildSection(
                  icon: Icons.timeline,
                  title: l10n.currentStatus,
                  content: project.currentStatus,
                  color: const Color(0xFFF59E0B),
                ),

                const SizedBox(height: 24),

                // 11. 团队介绍
                _buildTeamSection(
                  icon: Icons.groups,
                  title: l10n.team,
                  team: project.team,
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 12. 所需支持
                _buildSection(
                  icon: Icons.handshake_outlined,
                  title: l10n.ask,
                  content: project.ask,
                  color: const Color(0xFFEF4444),
                ),

                const SizedBox(height: 32),

                // Footer - Creator Info
                Container(
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
                          project.creatorName.substring(0, 1),
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
                              project.creatorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.createdAt} ${_formatDate(project.createdAt)}',
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
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
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
                      member.name.substring(0, 1),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
