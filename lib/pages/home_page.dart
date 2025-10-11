import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/shopping_controller.dart';
import '../models/api_interface_model.dart';
import '../routes/app_routes.dart';
import '../widgets/copyright_widget.dart';
import '../widgets/skeleton_loader.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ShoppingController controller = Get.find<ShoppingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w300,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textTertiary),
            onPressed: () {
              Get.snackbar('搜索', '搜索API接口功能开发中...');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.textTertiary),
            onPressed: () {
              Get.snackbar('购买清单', 'API购买清单功能开发中...');
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SkeletonLoader(type: SkeletonType.home);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner轮播图
              _buildBannerCarousel(controller),

              const SizedBox(height: 20),

              // 快捷功能区
              _buildQuickActions(),

              const SizedBox(height: 20),

              // 数据分类标题
              _buildSectionTitle('📊 数据分类'),

              // 数据分类瓷片
              _buildDataCategories(),

              const SizedBox(height: 20),

              // 热门精选标题
              _buildSectionTitle('🔥 热门API接口'),

              // 热门API接口网格
              _buildApiInterfaceGrid(controller.hotApiInterfaces),

              const SizedBox(height: 20),

              // 精选推荐标题
              _buildSectionTitle('⭐ 精选API服务'),

              // 精选API接口网格
              _buildApiInterfaceGrid(controller.selectedApiInterfaces),

              const SizedBox(height: 20),

              // 版权信息
              const CopyrightWidget(useTopMargin: true),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBannerCarousel(ShoppingController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                controller.updateBannerIndex(index);
              },
            ),
            items: controller.bannerList.map((banner) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // 圆角设计
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.background,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 36, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            banner.title.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Obx(() => DotsIndicator(
                dotsCount: controller.bannerList.length,
                position: controller.currentBannerIndex.value.toDouble(),
                decorator: const DotsDecorator(
                  activeColor: AppColors.textPrimary,
                  color: AppColors.border,
                  size: Size.square(6.0),
                  activeSize: Size(24.0, 6.0),
                  activeShape: RoundedRectangleBorder(),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.api_outlined,
        'title': 'API市场',
        'route': AppRoutes.apiMarketplace
      },
      {
        'icon': Icons.dns_outlined,
        'title': '数据服务',
        'route': AppRoutes.dataService
      },
      {'icon': Icons.verified_user_outlined, 'title': '验证接口', 'route': null},
      {
        'icon': Icons.analytics_outlined,
        'title': '分析工具',
        'route': AppRoutes.analyticsTool
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return _QuickActionButton(
            icon: action['icon'],
            title: action['title'],
            onTap: () {
              if (action['route'] != null) {
                Get.toNamed(action['route']);
              } else {
                Get.snackbar('功能', '${action['title']}功能开发中...');
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // 移除 emoji,只保留文字
    final cleanTitle =
        title.replaceAll(RegExp(r'[\p{Emoji}\s]+', unicode: true), '').trim();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textTertiary,
            width: 2,
          ),
        ),
      ),
      child: Text(
        cleanTitle.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildApiInterfaceGrid(RxList<ApiInterfaceModel> apiInterfaces) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: apiInterfaces.length,
        itemBuilder: (context, index) {
          final apiInterface = apiInterfaces[index];
          return _buildApiInterfaceCard(apiInterface);
        },
      ),
    );
  }

  Widget _buildApiInterfaceCard(ApiInterfaceModel apiInterface) {
    final ShoppingController controller = Get.find<ShoppingController>();

    // 为每个API定义单色方案 - 性冷淡风格(浅色系)
    final colorIndex =
        apiInterface.name.hashCode.abs() % AppColors.apiCardColors.length;
    final cardColor = AppColors.apiCardColors[colorIndex];

    return GestureDetector(
      onTap: () => controller.onApiInterfaceTap(apiInterface),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8), // 圆角设计
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部: 图标和标签
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      apiInterface.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  if (apiInterface.isHot)
                    _buildMinimalTag('HOT', Colors.white)
                  else if (apiInterface.isFree)
                    _buildMinimalTag('FREE', Colors.white),
                ],
              ),

              const SizedBox(height: 16),

              // API名称
              Text(
                apiInterface.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // 分类
              Text(
                apiInterface.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              // 描述
              Expanded(
                child: Text(
                  apiInterface.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),

              // 底部信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (apiInterface.isFree)
                    const Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    )
                  else
                    Text(
                      '¥${apiInterface.price.toStringAsFixed(3)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '${(apiInterface.responseTime).toInt()}MS',
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTag(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(
          color: textColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 7,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDataCategories() {
    final List<Map<String, dynamic>> dataCategories = [
      {
        'title': '房产数据',
        'icon': Icons.home_outlined, // outlined风格
      },
      {
        'title': '企业数据',
        'icon': Icons.business_outlined, // outlined风格
      },
      {
        'title': '产品信息',
        'icon': Icons.inventory_2_outlined, // outlined风格
      },
      {
        'title': '个人信息',
        'icon': Icons.person_outline, // outlined风格
      },
      {
        'title': '金融数据',
        'icon': Icons.account_balance_outlined, // outlined风格
      },
      {
        'title': '电商数据',
        'icon': Icons.shopping_bag_outlined, // outlined风格
      },
      {
        'title': '社交数据',
        'icon': Icons.group_outlined, // outlined风格
      },
      {
        'title': '位置数据',
        'icon': Icons.location_on_outlined, // outlined风格
      },
      {
        'title': '生活服务',
        'icon': Icons.stars_outlined, // outlined风格
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: dataCategories.length,
        itemBuilder: (context, index) {
          final category = dataCategories[index];
          return _buildDataCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildDataCategoryCard(Map<String, dynamic> category) {
    // 使用性冷淡风格的单色方案(浅色系)
    final index =
        category['title'].hashCode.abs() % AppColors.dataCategoryColors.length;
    final iconColor = AppColors.dataCategoryColors[index];

    return GestureDetector(
      onTap: () {
        // 如果是位置数据,跳转到位置演示页面
        if (category['title'] == '位置数据') {
          Get.toNamed(AppRoutes.locationDemo);
        } else {
          Get.snackbar('数据分类', '${category['title']}功能开发中...');
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 纯图标 - 无边框无背景
            Icon(
              category['icon'],
              color: iconColor,
              size: 32,
            ),

            const SizedBox(height: 8),

            // 分类名称 - 深灰色文字
            Text(
              category['title'],
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 快捷功能按钮组件 - 带hover效果
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.containerLight.withValues(alpha: 0.7)
                      : AppColors.containerLight,
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : AppColors.borderLight,
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  widget.icon,
                  color: _isHovered ? AppColors.accent : AppColors.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 11,
                  color: _isHovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
