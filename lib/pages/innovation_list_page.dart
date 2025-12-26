import 'package:df_admin_mobile/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:df_admin_mobile/features/innovation_project/presentation/controllers/innovation_project_state_controller.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart' as models;
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'add_innovation_page.dart';
import 'direct_chat_page.dart';
import 'innovation_detail_page.dart';

/// Innovation Projects List Page
/// 创意项目列表页面
class InnovationListPage extends StatefulWidget {
  const InnovationListPage({super.key});

  @override
  State<InnovationListPage> createState() => _InnovationListPageState();
}

class _InnovationListPageState extends State<InnovationListPage> with WidgetsBindingObserver {
  // 关注状态管理 - 用项目ID作为key
  final Map<String, bool> _followedProjects = {};

  // 获取 controller（如果已注册）
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
    WidgetsBinding.instance.addObserver(this);
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从后台恢复时刷新数据
    if (state == AppLifecycleState.resumed) {
      _loadProjects(forceRefresh: true);
    }
  }

  /// 加载项目列表
  Future<void> _loadProjects({bool forceRefresh = false}) async {
    final controller = _controller;
    if (controller != null) {
      await controller.getProjects(forceRefresh: forceRefresh);
    }
  }

  // 数据刷新方法
  Future<void> _refreshData() async {
    await _loadProjects();
  }

  // 静态示例数据（作为备用）
  List<InnovationProject> get _fallbackProjects => [
        InnovationProject(
          id: 1,
          uuid: 'fallback-1',
          userId: 1,
          projectName: '智课通',
          elevatorPitch: '我们是面向大学生的AI学习伙伴，像私人tutor一样个性化辅导，但完全自动化且价格更低。',
          problem: '大学生备考四六级时缺乏个性化练习和及时反馈，导致复习效率低下、通过率不高。',
          solution: '我们开发了一款基于AI的备考App，能根据用户错题自动推荐学习路径，并生成每日训练计划，提升学习效率30%以上。',
          targetAudience: '主要用户：一二线城市的大二至大四本科生\n次要用户：考研学生、语言培训机构\n用户画像：年龄18-24岁，手机使用频繁，愿意为提分付费',
          productType: '微信小程序 + 后台管理系统',
          keyFeatures: '智能错题分析与知识点定位\n个性化每日学习任务推送\n模拟考试+成绩预测\n语音口语练习与评分\n学习进度可视化报告',
          competitiveAdvantage: '竞品A：题库大但无个性化推荐 → 我们有AI自适应引擎\n竞品B：价格高 → 我们采用订阅制，性价比更高\n我们的优势：团队有教育+AI背景，已获得某高校试点合作',
          businessModel: '基础功能免费，高级功能月费19元，支持学期/年费套餐',
          marketOpportunity: '中国大学生人数超3000万，每年四六级考生约1000万人次，备考工具市场规模预计2025年达50亿元。',
          currentStatus: '已完成MVP原型\n正在进行小范围内测（50名用户）\n已注册公司，申请软件著作权\n寻求种子轮融资50万元，用于产品迭代和推广',
          team: [
            TeamMember(
              name: '张三',
              role: 'CEO',
              description: '前腾讯产品经理，5年互联网经验',
            ),
            TeamMember(
              name: '李四',
              role: 'CTO',
              description: '计算机硕士，擅长AI算法开发',
            ),
          ],
          ask: '需要技术合伙人一起开发后端\n寻求天使投资50万，出让10%股权\n希望接入某平台API资源',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          userName: '张三',
        ),
      ];

  /// 获取显示的项目列表
  List<InnovationProject> get _displayProjects {
    final controller = _controller;
    if (controller != null && controller.projects.isNotEmpty) {
      return controller.projects;
    }
    return _fallbackProjects;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final controller = _controller;

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
        onRefresh: _refreshData,
        child: controller != null
            ? Obx(() {
                if (controller.isLoading.value && controller.projects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null && controller.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProjects,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                return _buildContent(l10n, isMobile, _displayProjects);
              })
            : _buildContent(l10n, isMobile, _displayProjects),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isMobile, List<InnovationProject> projects) {
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
              if (result == true && mounted) {
                await _refreshData();
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
          ...projects.map((project) => _buildProjectCard(project, isMobile)),
      ],
    );
  }

  Widget _buildProjectCard(InnovationProject project, bool isMobile) {
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
                child: _buildFollowButton(project.id.toString()),
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
                      _formatDate(project.updatedAt ?? project.createdAt),
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

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    if (diff.inDays < 30) return l10n.weeksAgo((diff.inDays / 7).floor());
    return l10n.monthsAgo((diff.inDays / 30).floor());
  }

  /// 构建关注按钮
  Widget _buildFollowButton(String projectId) {
    final isFollowed = _followedProjects[projectId] ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleFollow(projectId),
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
                isFollowed ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
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
  }

  /// 切换关注状态
  void _toggleFollow(String projectId) {
    setState(() {
      _followedProjects[projectId] = !(_followedProjects[projectId] ?? false);
    });

    // 显示提示
    final isFollowed = _followedProjects[projectId] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFollowed ? '已关注该项目' : '已取消关注'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: isFollowed ? const Color(0xFF10B981) : Colors.grey[700],
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
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 50,
          color: const Color(0xFF8B5CF6).withOpacity(0.5),
        ),
      ),
    );
  }
}
