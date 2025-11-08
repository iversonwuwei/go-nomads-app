import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/shopping_controller.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../routes/app_routes.dart';
import 'data_service_page.dart';
import 'profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ShoppingController controller = Get.put(ShoppingController());
    final userStateController = Get.find<UserStateController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Obx(() {
        switch (controller.currentTabIndex.value) {
          case 0:
            return const DataServicePage();
          case 1:
            // AI助手页面 - 检查登录状态后跳转
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (userStateController.isLoggedIn) {
                // 已登录,跳转到AI聊天页面
                Get.toNamed(AppRoutes.aiChat);
              } else {
                // 未登录,跳转到登录页
                print('🔒 需要登录才能使用AI助手');
                Get.toNamed(AppRoutes.login);
              }
              // 重置导航栏到首页
              controller.changeTab(0);
            });
            return const DataServicePage();
          case 2:
            return const ProfilePage();
          default:
            return const DataServicePage();
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentTabIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue[700],
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        Color(0xFFf093fb),
                        Color(0xFFf5576c),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                label: l10n.aiAssistant,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: l10n.myProfile,
              ),
            ],
          )),
    );
  }
}
