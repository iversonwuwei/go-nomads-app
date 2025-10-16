import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';
import '../models/innovation_project_model.dart';
import '../models/user_model.dart' as models;
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

class _InnovationListPageState extends State<InnovationListPage> {
  // 模拟数据
  final List<InnovationProject> _projects = [
    InnovationProject(
      id: '1',
      projectName: '智课通',
      elevatorPitch: '我们是面向大学生的AI学习伙伴，像私人tutor一样个性化辅导，但完全自动化且价格更低。',
      problem: '大学生备考四六级时缺乏个性化练习和及时反馈，导致复习效率低下、通过率不高。',
      solution: '我们开发了一款基于AI的备考App，能根据用户错题自动推荐学习路径，并生成每日训练计划，提升学习效率30%以上。',
      targetAudience: '主要用户：一二线城市的大二至大四本科生\n次要用户：考研学生、语言培训机构\n用户画像：年龄18-24岁，手机使用频繁，愿意为提分付费',
      productType: '微信小程序 + 后台管理系统',
      keyFeatures: [
        '智能错题分析与知识点定位',
        '个性化每日学习任务推送',
        '模拟考试+成绩预测',
        '语音口语练习与评分',
        '学习进度可视化报告',
      ],
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
        TeamMember(
          name: '王五',
          role: 'COO',
          description: '曾运营教育类公众号，粉丝10万+',
        ),
      ],
      ask: '需要技术合伙人一起开发后端\n寻求天使投资50万，出让10%股权\n希望接入某平台API资源',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      imageUrl: 'https://picsum.photos/400/300?random=1',
      creatorId: 'user1',
      creatorName: '张三',
    ),
    InnovationProject(
      id: '2',
      projectName: '碳迹追踪',
      elevatorPitch: '我们是个人碳足迹管理工具，帮助用户追踪和减少日常碳排放，但更注重游戏化和社交互动。',
      problem: '随着环保意识提升，人们想减少碳排放，但不知道从何下手，也缺乏持续动力。',
      solution: '通过App记录出行、饮食、购物等行为，自动计算碳排放量，提供减排建议，并通过积分、排行榜等机制激励用户。',
      targetAudience: '主要用户：25-40岁中产阶级，关注环保和可持续生活\n次要用户：企业ESG部门、环保组织\n用户画像：有环保意识，愿意为绿色产品付费',
      productType: 'App（iOS + Android）',
      keyFeatures: [
        '自动碳足迹计算',
        '个性化减排建议',
        '碳积分商城',
        '好友排行榜',
        '企业碳中和服务',
      ],
      competitiveAdvantage: '市面上工具多为企业端，我们专注C端用户体验\n游戏化设计增强用户粘性\n已与多家新能源企业建立合作',
      businessModel: '免费版限制功能，高级版月费9.9元\n企业版按需定价\n碳积分商城抽成',
      marketOpportunity: '全球碳中和市场规模超万亿美元，个人碳管理是蓝海市场。',
      currentStatus: 'App已上线，用户500+\n正在对接碳交易平台\n计划参加碳中和创业大赛',
      team: [
        TeamMember(
          name: '陈六',
          role: 'CEO',
          description: '环境工程博士，3年碳咨询经验',
        ),
        TeamMember(
          name: '赵七',
          role: 'CTO',
          description: '全栈工程师，擅长移动端开发',
        ),
      ],
      ask: '寻求Pre-A轮融资200万\n希望接入更多碳数据源\n招募市场推广人员',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'https://picsum.photos/400/300?random=2',
      creatorId: 'user2',
      creatorName: '陈六',
    ),
    InnovationProject(
      id: '3',
      projectName: '灵犀翻译',
      elevatorPitch: '我们是专业文档翻译工具，像Google翻译一样快速，但专业度媲美人工翻译。',
      problem: '传统翻译工具无法处理专业术语，人工翻译价格昂贵且周期长。',
      solution: '利用垂直领域AI模型，针对法律、医疗、金融等专业文档提供高质量翻译，成本仅为人工翻译的1/10。',
      targetAudience: '主要用户：律所、医院、金融机构\n次要用户：留学生、科研人员\n用户画像：对翻译质量要求高，愿意为专业服务付费',
      productType: 'SaaS 平台 + API 服务',
      keyFeatures: [
        '多领域专业术语库',
        '上下文智能理解',
        '格式保留（PDF、Word等）',
        '人工审核服务',
        '批量翻译',
      ],
      competitiveAdvantage: '专注垂直领域，翻译准确度高于通用工具\n提供人工复核，质量有保障\n已服务多家500强企业',
      businessModel: '按字数收费，起步价0.1元/字\nAPI调用按次收费\n企业年费套餐',
      marketOpportunity: '中国翻译市场规模超400亿元，专业翻译占比60%以上。',
      currentStatus: '平台已上线1年，月营收10万+\n服务企业客户50+\n计划拓展海外市场',
      team: [
        TeamMember(
          name: '孙八',
          role: 'CEO',
          description: '翻译行业10年经验，曾任某知名翻译公司总监',
        ),
        TeamMember(
          name: '周九',
          role: 'CTO',
          description: 'NLP专家，前谷歌工程师',
        ),
        TeamMember(
          name: '吴十',
          role: 'VP of Sales',
          description: '企业服务销售专家，客户资源丰富',
        ),
      ],
      ask: '寻求A轮融资500万\n拓展更多垂直领域\n招募NLP算法工程师',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
      imageUrl: 'https://picsum.photos/400/300?random=3',
      creatorId: 'user3',
      creatorName: '孙八',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a1a1a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.innovation,
          style: const TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.innovation,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.innovationDescription,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withAlpha(230),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Create Project Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddInnovationPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline, size: 24),
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
                Icons.explore,
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
          ..._projects.map((project) => _buildProjectCard(project, isMobile)),
        ],
      ),
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
          if (project.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                project.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.lightbulb, size: 50),
                  );
                },
              ),
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
                        .take(2)
                        .map((feature) =>
                            _buildTag(feature, const Color(0xFF6366F1))),
                  ],
                ),

                const SizedBox(height: 12),

                // 创建者和时间
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF8B5CF6),
                      child: Text(
                        project.creatorName.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      project.creatorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(project.updatedAt),
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
                              builder: (context) =>
                                  InnovationDetailPage(project: project),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
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
                          final chatUser = models.UserModel(
                            id: project.creatorId,
                            name: project.creatorName,
                            username: project.creatorName,
                            avatarUrl: null,
                            stats: models.TravelStats(
                              countriesVisited: 0,
                              citiesLived: 0,
                              daysNomading: 0,
                              meetupsAttended: 0,
                              tripsCompleted: 0,
                            ),
                            joinedDate: DateTime.now(),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DirectChatPage(user: chatUser),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat, size: 18),
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
}
