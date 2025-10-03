import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 用户信息卡片 - API开发者身份
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.containerBlueGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.containerWhite15,
                            borderRadius: BorderRadius.circular(4),
                            border: const Border(
                              top: BorderSide(
                                  color: AppColors.borderWhite30, width: 1),
                              left: BorderSide(
                                  color: AppColors.borderWhite30, width: 1),
                              right: BorderSide(
                                  color: AppColors.borderWhite30, width: 1),
                              bottom: BorderSide(
                                  color: AppColors.borderWhite30, width: 1),
                            ),
                          ),
                          child: Icon(
                            Icons.code,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'API DEVELOPER',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'developer@sjsj.com',
                                style: TextStyle(
                                  color: AppColors.textWhite70,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'VERIFIED DEVELOPER • VIP',
                                style: TextStyle(
                                  color: AppColors.textWhite60,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 统计信息
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem('已购API', '12'),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem('本月调用', '1.2万'),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem('余额', '¥68.5'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // API管理菜单
              _buildMenuSection(
                '📊 API管理',
                [
                  _buildMenuItem(Icons.api, '我的API接口', Colors.blue, () {
                    Get.snackbar('API接口', '查看已购买的API接口');
                  }),
                  _buildMenuItem(Icons.analytics, '调用统计', Colors.green, () {
                    Get.snackbar('调用统计', '查看API调用统计数据');
                  }),
                  _buildMenuItem(Icons.receipt, '消费记录', Colors.orange, () {
                    Get.snackbar('消费记录', '查看API消费记录');
                  }),
                  _buildMenuItem(Icons.code, 'API文档', Colors.purple, () {
                    Get.snackbar('API文档', '查看API接口文档');
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // 数据服务菜单
              _buildMenuSection(
                '💰 数据服务',
                [
                  _buildMenuItem(Icons.shopping_cart, '购买清单', Colors.red, () {
                    Get.snackbar('购买清单', '查看待购买的API接口');
                  }),
                  _buildMenuItem(Icons.star, '收藏接口', Colors.amber, () {
                    Get.snackbar('收藏接口', '查看收藏的API接口');
                  }),
                  _buildMenuItem(Icons.payment, '充值中心', Colors.teal, () {
                    Get.snackbar('充值中心', '账户余额充值');
                  }),
                  _buildMenuItem(Icons.card_membership, '套餐订阅', Colors.indigo,
                      () {
                    Get.snackbar('套餐订阅', '查看API套餐订阅');
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // 开发者工具菜单
              _buildMenuSection(
                '🛠️ 开发者工具',
                [
                  _buildMenuItem(Icons.bug_report, 'API测试', Colors.cyan, () {
                    Get.snackbar('API测试', '在线API接口测试工具');
                  }),
                  _buildMenuItem(Icons.key, 'API密钥', Colors.brown, () {
                    Get.snackbar('API密钥', '管理API访问密钥');
                  }),
                  _buildMenuItem(Icons.integration_instructions, 'SDK下载',
                      Colors.deepOrange, () {
                    Get.snackbar('SDK下载', '下载各语言SDK');
                  }),
                  _buildMenuItem(Icons.school, '开发教程', Colors.deepPurple, () {
                    Get.snackbar('开发教程', '查看API开发教程');
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // 账户设置菜单
              _buildMenuSection(
                '⚙️ 账户设置',
                [
                  _buildMenuItem(Icons.login, '登录/注册', Colors.blue, () {
                    Get.toNamed(AppRoutes.login);
                  }),
                  _buildMenuItem(Icons.person, '个人信息', Colors.grey, () {
                    Get.snackbar('个人信息', '编辑个人资料');
                  }),
                  _buildMenuItem(Icons.security, '安全设置', Colors.red, () {
                    Get.snackbar('安全设置', '密码和安全设置');
                  }),
                  _buildMenuItem(Icons.notifications, '消息通知', Colors.orange,
                      () {
                    Get.snackbar('消息通知', '通知设置');
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // 帮助与支持菜单
              _buildMenuSection(
                '❓ 帮助与支持',
                [
                  _buildMenuItem(Icons.help_outline, '使用帮助', Colors.green, () {
                    Get.snackbar('使用帮助', '查看使用帮助文档');
                  }),
                  _buildMenuItem(Icons.contact_support, '客服支持', Colors.blue,
                      () {
                    Get.snackbar('客服支持', '联系在线客服');
                  }),
                  _buildMenuItem(Icons.feedback, '意见反馈', Colors.purple, () {
                    Get.snackbar('意见反馈', '提交意见和建议');
                  }),
                  _buildMenuItem(Icons.info_outline, '关于数金数据', Colors.grey, () {
                    Get.snackbar('关于我们', '数金数据API交易平台');
                  }),
                ],
              ),

              const SizedBox(height: 32),

              // 退出登录按钮
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('确认退出'),
                        content: const Text('确定要退出登录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(); // 关闭对话框
                              Get.snackbar(
                                '提示',
                                '已退出登录',
                                duration: const Duration(seconds: 2),
                              );
                              // 延迟一下再跳转，让用户看到提示信息
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                Get.offAllNamed(
                                    AppRoutes.login); // 跳转到登录页面并清除所有路由栈
                              });
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.containerDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: AppColors.containerDark,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // 统计信息项构建方法
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // 菜单分组构建方法
  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF9E9E9E),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                title
                    .replaceAll(RegExp(r'[\p{Emoji}\s]+', unicode: true), '')
                    .trim()
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
                left: BorderSide(color: AppColors.border, width: 1),
                right: BorderSide(color: AppColors.border, width: 1),
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: _buildMenuItems(items),
            ),
          ),
        ],
      ),
    );
  }

  // 菜单项列表构建方法
  List<Widget> _buildMenuItems(List<Widget> items) {
    List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      widgets.add(items[i]);
      if (i < items.length - 1) {
        widgets.add(_buildDivider());
      }
    }
    return widgets;
  }

  // 菜单项构建方法
  Widget _buildMenuItem(
      IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: AppColors.containerDark,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.iconLight,
        size: 14,
      ),
      onTap: onTap,
    );
  }

  // 分割线构建方法
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: AppColors.borderLight,
      indent: 20,
      endIndent: 20,
    );
  }
}
