import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/user_profile/infrastructure/models/user_profile_dto.dart';
import '../services/database/user_profile_dao.dart';
import 'edit_basic_info_page.dart';
import 'edit_interests_page.dart';
import 'edit_skills_page.dart';
import 'edit_social_links_page.dart';

/// 模块化用户资料页面 - 整合所有8个模块
class ModularUserProfilePage extends StatefulWidget {
  final int accountId;
  final String? username;

  const ModularUserProfilePage({
    super.key,
    required this.accountId,
    this.username,
  });

  @override
  State<ModularUserProfilePage> createState() => _ModularUserProfilePageState();
}

class _ModularUserProfilePageState extends State<ModularUserProfilePage> {
  final _userProfileDao = UserProfileDao();

  bool _loading = true;
  UserBasicInfoDto? _basicInfo;
  NomadStatsDto? _stats;
  List<UserSkillDto> _skills = [];
  List<UserInterestDto> _interests = [];
  List<SocialLinkDto> _socialLinks = [];
  List<dynamic> _travelPlans = [];
  List<UserBadgeDto> _badges = [];
  List<TravelHistoryEntryDto> _history = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final basicInfo = await _userProfileDao.getBasicInfo(widget.accountId);
      final stats = await _userProfileDao.getNomadStats(widget.accountId);
      final skills = await _userProfileDao.getSkills(widget.accountId);
      final interests = await _userProfileDao.getInterests(widget.accountId);
      final socialLinks =
          await _userProfileDao.getSocialLinks(widget.accountId);
      final travelPlans =
          await _userProfileDao.getTravelPlans(widget.accountId);
      final badges = await _userProfileDao.getBadges(widget.accountId);
      final history = await _userProfileDao.getTravelHistory(widget.accountId);

      if (mounted) {
        setState(() {
          _basicInfo = basicInfo;
          _stats = stats;
          _skills = skills;
          _interests = interests;
          _socialLinks = socialLinks;
          _travelPlans = travelPlans;
          _badges = badges;
          _history = history;
          _loading = false;
        });
      }
    } catch (e) {
      print('加载用户资料失败: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required String content,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username ?? '用户资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loading = true;
              });
              _loadProfileData();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 头部 - 头像和基本信息
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _basicInfo?.avatarUrl != null
                              ? NetworkImage(_basicInfo!.avatarUrl!)
                              : null,
                          child: _basicInfo?.avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _basicInfo?.name ?? '未设置姓名',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_basicInfo?.occupation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _basicInfo!.occupation!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (_basicInfo?.currentCity != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${_basicInfo!.currentCity}, ${_basicInfo!.currentCountry ?? ''}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                        if (_basicInfo?.bio != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _basicInfo!.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nomad统计
                  if (_stats != null) ...[
                    const Text(
                      'Nomad 统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        _buildStatCard('国家', _stats!.countriesVisited,
                            Icons.flag, Colors.blue),
                        _buildStatCard('城市', _stats!.citiesLived,
                            Icons.location_city, Colors.green),
                        _buildStatCard('旅行天数', _stats!.daysNomading,
                            Icons.calendar_today, Colors.orange),
                        _buildStatCard('Meetup', _stats!.meetupsAttended,
                            Icons.group, Colors.purple),
                        _buildStatCard('行程', _stats!.tripsCompleted,
                            Icons.airplane_ticket, Colors.red),
                        _buildStatCard('评论', _stats!.reviewsWritten,
                            Icons.rate_review, Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 模块卡片
                  _buildModuleCard(
                    title: '基本信息',
                    icon: Icons.person,
                    content: _basicInfo != null
                        ? '${_basicInfo!.name} · ${_basicInfo!.occupation ?? "未设置职业"}'
                        : '点击编辑基本信息',
                    onTap: () async {
                      final result = await Get.to(
                          () => EditBasicInfoPage(accountId: widget.accountId));
                      if (result == true) {
                        _loadProfileData();
                      }
                    },
                    color: Colors.blue,
                  ),

                  _buildModuleCard(
                    title: '技能标签',
                    icon: Icons.star,
                    content: _skills.isEmpty
                        ? '点击添加技能标签'
                        : '${_skills.length} 项技能: ${_skills.take(3).map((s) => s.skillName).join(", ")}${_skills.length > 3 ? "..." : ""}',
                    onTap: () async {
                      await Get.to(
                          () => EditSkillsPage(accountId: widget.accountId));
                      _loadProfileData();
                    },
                    color: Colors.amber,
                  ),

                  _buildModuleCard(
                    title: '兴趣爱好',
                    icon: Icons.favorite,
                    content: _interests.isEmpty
                        ? '点击添加兴趣爱好'
                        : '${_interests.length} 项兴趣: ${_interests.take(3).map((i) => i.interestName).join(", ")}${_interests.length > 3 ? "..." : ""}',
                    onTap: () async {
                      await Get.to(
                          () => EditInterestsPage(accountId: widget.accountId));
                      _loadProfileData();
                    },
                    color: Colors.green,
                  ),

                  _buildModuleCard(
                    title: '社交链接',
                    icon: Icons.link,
                    content: _socialLinks.isEmpty
                        ? '点击添加社交平台链接'
                        : '已添加 ${_socialLinks.length} 个平台',
                    onTap: () async {
                      await Get.to(() =>
                          EditSocialLinksPage(accountId: widget.accountId));
                      _loadProfileData();
                    },
                    color: Colors.purple,
                  ),

                  _buildModuleCard(
                    title: '旅行计划',
                    icon: Icons.map,
                    content: _travelPlans.isEmpty
                        ? '暂无旅行计划'
                        : '${_travelPlans.length} 个计划',
                    onTap: () {
                      // TODO: 导航到旅行计划页面
                      Get.snackbar('提示', '旅行计划功能开发中');
                    },
                    color: Colors.orange,
                  ),

                  _buildModuleCard(
                    title: '成就徽章',
                    icon: Icons.military_tech,
                    content:
                        _badges.isEmpty ? '暂无徽章' : '已获得 ${_badges.length} 个徽章',
                    onTap: () {
                      // TODO: 导航到徽章页面
                      Get.snackbar('提示', '徽章功能开发中');
                    },
                    color: Colors.red,
                  ),

                  _buildModuleCard(
                    title: '旅行历史',
                    icon: Icons.history,
                    content:
                        _history.isEmpty ? '暂无旅行记录' : '${_history.length} 条记录',
                    onTap: () {
                      // TODO: 导航到旅行历史页面
                      Get.snackbar('提示', '旅行历史功能开发中');
                    },
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
