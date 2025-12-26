import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'direct_chat_page.dart';

/// Innovation Project Detail Page
/// 创意项目详情页面
class InnovationDetailPage extends StatefulWidget {
  final InnovationProject project;

  const InnovationDetailPage({super.key, required this.project});

  @override
  State<InnovationDetailPage> createState() => _InnovationDetailPageState();
}

class _InnovationDetailPageState extends State<InnovationDetailPage> {
  // 关注状态
  bool _isFollowed = false;
  // 完整项目数据
  InnovationProject? _fullProject;
  bool _isLoading = true;

  // 获取 controller
  InnovationProjectStateController? get _controller {
    try {
      return Get.find<InnovationProjectStateController>();
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // 延迟到帧渲染完成后再加载数据，避免在 build 过程中触发状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFullProject();
    });
  }

  /// 加载完整项目数据
  Future<void> _loadFullProject() async {
    final controller = _controller;
    final projectId = widget.project.uuid;
    print('📱 加载项目详情: projectId=$projectId, controller=${controller != null}');

    if (controller != null && projectId != null) {
      await controller.getProjectById(projectId);
      print('📱 API返回: currentProject=${controller.currentProject.value?.projectName}');
      if (mounted) {
        setState(() {
          _fullProject = controller.currentProject.value;
          _isLoading = false;
          print('📱 设置 _fullProject: ${_fullProject?.projectName}, problem: ${_fullProject?.problem}');
        });
      }
    } else {
      print('📱 跳过加载: controller=$controller, projectId=$projectId');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取当前显示的项目（优先使用完整数据）
  InnovationProject get _project => _fullProject ?? widget.project;

  /// 切换关注状态
  void _toggleFollow() {
    setState(() {
      _isFollowed = !_isFollowed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowed ? '已关注项目' : '已取消关注',
          style: const TextStyle(fontSize: 15),
        ),
        backgroundColor: _isFollowed ? const Color(0xFF8B5CF6) : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // 加载中显示骨架屏
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF8B5CF6),
          leading: const SliverBackButton(),
          title: Text(widget.project.projectName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF8B5CF6),
            leading: const SliverBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _project.projectName,
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
              background: _project.imageUrl != null && _project.imageUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _project.imageUrl!,
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
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. 一句话定位
                _buildSection(
                  icon: FontAwesomeIcons.rocket,
                  title: l10n.elevatorPitch,
                  content: _project.elevatorPitch,
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 2. 要解决的问题
                _buildSection(
                  icon: FontAwesomeIcons.circleExclamation,
                  title: l10n.problem,
                  content: _project.problem,
                  color: const Color(0xFFEF4444),
                ),

                const SizedBox(height: 24),

                // 3. 解决方案
                _buildSection(
                  icon: FontAwesomeIcons.lightbulb,
                  title: l10n.solution,
                  content: _project.solution,
                  color: const Color(0xFF10B981),
                ),

                const SizedBox(height: 24),

                // 4. 目标用户
                _buildSection(
                  icon: FontAwesomeIcons.users,
                  title: l10n.targetAudience,
                  content: _project.targetAudience,
                  color: const Color(0xFF3B82F6),
                ),

                const SizedBox(height: 24),

                // 5. 产品形态
                _buildSection(
                  icon: FontAwesomeIcons.laptop,
                  title: l10n.productType,
                  content: _project.productType,
                  color: const Color(0xFFF59E0B),
                ),

                const SizedBox(height: 24),

                // 6. 核心功能
                _buildListSection(
                  icon: FontAwesomeIcons.star,
                  title: l10n.keyFeatures,
                  items: _project.keyFeatures.split('\n').where((s) => s.isNotEmpty).toList(),
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 7. 竞争优势
                _buildSection(
                  icon: FontAwesomeIcons.chartLine,
                  title: l10n.competitiveAdvantage,
                  content: _project.competitiveAdvantage,
                  color: const Color(0xFF6366F1),
                ),

                const SizedBox(height: 24),

                // 8. 商业模式
                _buildSection(
                  icon: FontAwesomeIcons.dollarSign,
                  title: l10n.businessModel,
                  content: _project.businessModel,
                  color: const Color(0xFF10B981),
                ),

                const SizedBox(height: 24),

                // 9. 市场潜力
                _buildSection(
                  icon: FontAwesomeIcons.chartLine,
                  title: l10n.marketOpportunity,
                  content: _project.marketOpportunity,
                  color: const Color(0xFF3B82F6),
                ),

                const SizedBox(height: 24),

                // 10. 当前进展
                _buildSection(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  title: l10n.currentStatus,
                  content: _project.currentStatus,
                  color: const Color(0xFFF59E0B),
                ),

                const SizedBox(height: 24),

                // 11. 团队介绍
                _buildTeamSection(
                  icon: FontAwesomeIcons.userGroup,
                  title: l10n.team,
                  team: _project.team,
                  color: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 24),

                // 12. 所需支持
                _buildSection(
                  icon: FontAwesomeIcons.handshake,
                  title: l10n.ask,
                  content: _project.ask,
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
                          (_project.userName ?? '?').substring(0, 1),
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
                              _project.userName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.createdAt} ${_formatDate(_project.createdAt)}',
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

                // 底部留白,为底部栏留出空间
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      // 底部栏
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建底部栏
  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              child: OutlinedButton.icon(
                onPressed: _toggleFollow,
                icon: Icon(
                  _isFollowed ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
                  size: 20,
                ),
                label: Text(
                  _isFollowed ? '已关注' : '关注',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isFollowed ? const Color(0xFF8B5CF6) : Colors.grey[700],
                  side: BorderSide(
                    color: _isFollowed ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 联系按钮
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _contactCreator(context),
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
  void _contactCreator(BuildContext context) {
    // 创建发布者的 User 对象
    final creatorUser = User(
      id: _project.userId.toString(),
      name: _project.userName ?? 'Unknown',
      username: (_project.userName ?? 'unknown').toLowerCase().replaceAll(' ', '_'),
      avatarUrl: _project.userAvatar,
      stats: TravelStats(
        citiesVisited: 0,
        countriesVisited: 0,
        reviewsWritten: 0,
        photosShared: 0,
        totalDistanceTraveled: 0,
      ),
      joinedDate: DateTime.now(),
    );

    // 跳转到一对一聊天页面
    Get.to(() => DirectChatPage(user: creatorUser));
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF6366F1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
