import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 用户信息卡片 - API开发者身份
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.code,
                              size: 36,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'API开发者',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'developer@sjsj.com',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '认证开发者 • VIP会员',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
                              Get.back();
                              Get.snackbar('提示', '已退出登录');
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('退出登录'),
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
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 14,
      ),
      onTap: onTap,
    );
  }

  // 分割线构建方法
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }
}
