import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/controllers/modular_user_profile_page_controller.dart';
import 'edit_basic_info_page.dart';
import 'edit_interests_page.dart';
import 'edit_skills_page.dart';
import 'edit_social_links_page.dart';

/// 模块化用户资料页面 - 整合所有8个模块
class ModularUserProfilePage extends StatelessWidget {
  final int accountId;
  final String? username;

  const ModularUserProfilePage({
    super.key,
    required this.accountId,
    this.username,
  });

  static String _generateTag(int accountId) => 'ModularUserProfilePage_$accountId';

  ModularUserProfilePageController _useController() {
    final tag = _generateTag(accountId);
    if (Get.isRegistered<ModularUserProfilePageController>(tag: tag)) {
      return Get.find<ModularUserProfilePageController>(tag: tag);
    }
    return Get.put(
      ModularUserProfilePageController(accountId: accountId, username: username),
      tag: tag,
    );
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(FontAwesomeIcons.arrowRight, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();

    return Scaffold(
      appBar: AppBar(
        title: Text(username ?? '用户资料'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate),
            onPressed: controller.loadProfileData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadProfileData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 头部 - 头像和基本信息
              Center(
                child: Column(
                  children: [
                    SafeCircleAvatar(
                      imageUrl: controller.basicInfo.value?.avatarUrl,
                      radius: 50,
                      errorWidget: const Icon(FontAwesomeIcons.user, size: 50),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.basicInfo.value?.name ?? '未设置姓名',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (controller.basicInfo.value?.occupation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        controller.basicInfo.value!.occupation!,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                    if (controller.basicInfo.value?.currentCity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.locationDot, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.basicInfo.value!.currentCity}, ${controller.basicInfo.value!.currentCountry ?? ''}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                    if (controller.basicInfo.value?.bio != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        controller.basicInfo.value!.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nomad统计
              if (controller.stats.value != null) ...[
                const Text(
                  'Nomad 统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    _buildStatCard('国家', controller.stats.value!.countriesVisited, FontAwesomeIcons.flag, Colors.blue),
                    _buildStatCard('城市', controller.stats.value!.citiesLived, FontAwesomeIcons.city, Colors.green),
                    _buildStatCard(
                        '旅行天数', controller.stats.value!.daysNomading, FontAwesomeIcons.calendar, Colors.orange),
                    _buildStatCard(
                        'Meetup', controller.stats.value!.meetupsAttended, FontAwesomeIcons.userGroup, Colors.purple),
                    _buildStatCard(
                        '行程', controller.stats.value!.tripsCompleted, FontAwesomeIcons.ticketSimple, Colors.red),
                    _buildStatCard(
                        '评论', controller.stats.value!.reviewsWritten, FontAwesomeIcons.commentDots, Colors.teal),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 模块卡片
              _buildModuleCard(
                title: '基本信息',
                icon: FontAwesomeIcons.user,
                content: controller.basicInfo.value != null
                    ? '${controller.basicInfo.value!.name} · ${controller.basicInfo.value!.occupation ?? "未设置职业"}'
                    : '点击编辑基本信息',
                onTap: () async {
                  final result = await Get.to(() => EditBasicInfoPage(accountId: accountId));
                  if (result == true) {
                    controller.loadProfileData();
                  }
                },
                color: Colors.blue,
              ),

              _buildModuleCard(
                title: '技能标签',
                icon: FontAwesomeIcons.star,
                content: controller.skills.isEmpty
                    ? '点击添加技能标签'
                    : '${controller.skills.length} 项技能: ${controller.skills.take(3).map((s) => s.skillName).join(", ")}${controller.skills.length > 3 ? "..." : ""}',
                onTap: () async {
                  await Get.to(() => EditSkillsPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.amber,
              ),

              _buildModuleCard(
                title: '兴趣爱好',
                icon: FontAwesomeIcons.heart,
                content: controller.interests.isEmpty
                    ? '点击添加兴趣爱好'
                    : '${controller.interests.length} 项兴趣: ${controller.interests.take(3).map((i) => i.interestName).join(", ")}${controller.interests.length > 3 ? "..." : ""}',
                onTap: () async {
                  await Get.to(() => EditInterestsPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.green,
              ),

              _buildModuleCard(
                title: '社交链接',
                icon: FontAwesomeIcons.link,
                content: controller.socialLinks.isEmpty ? '点击添加社交平台链接' : '已添加 ${controller.socialLinks.length} 个平台',
                onTap: () async {
                  await Get.to(() => EditSocialLinksPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.purple,
              ),

              _buildModuleCard(
                title: '旅行计划',
                icon: FontAwesomeIcons.map,
                content: controller.travelPlans.isEmpty ? '暂无旅行计划' : '${controller.travelPlans.length} 个计划',
                onTap: () {
                  AppToast.error('旅行计划功能开发中');
                },
                color: Colors.orange,
              ),

              _buildModuleCard(
                title: '成就徽章',
                icon: FontAwesomeIcons.medal,
                content: controller.badges.isEmpty ? '暂无徽章' : '已获得 ${controller.badges.length} 个徽章',
                onTap: () {
                  AppToast.error('徽章功能开发中');
                },
                color: Colors.red,
              ),

              _buildModuleCard(
                title: '旅行历史',
                icon: FontAwesomeIcons.clockRotateLeft,
                content: controller.history.isEmpty ? '暂无旅行记录' : '${controller.history.length} 条记录',
                onTap: () {
                  AppToast.error('旅行历史功能开发中');
                },
                color: Colors.teal,
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}
