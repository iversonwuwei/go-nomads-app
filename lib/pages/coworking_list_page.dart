import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_page.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_page.dart';
import 'package:go_nomads_app/routes/route_refresh_observer.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/coworking_verification_badge.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';
import 'package:go_nomads_app/widgets/skeletons/base_skeleton.dart';

/// Coworking List Page
/// 共享办公空间列表页面
class CoworkingListPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String? countryName;

  const CoworkingListPage({
    super.key,
    required this.cityId,
    required this.cityName,
    this.countryName,
  });

  @override
  State<CoworkingListPage> createState() => _CoworkingListPageState();
}

class _CoworkingListPageState extends State<CoworkingListPage> with RouteAwareRefreshMixin<CoworkingListPage> {
  late final CoworkingStateController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<CoworkingStateController>();
    _scrollController.addListener(_onScroll);

    // 立即加载数据，不使用延迟
    log('🔄 CoworkingList: 加载数据 cityId=${widget.cityId}');
    // 强制刷新确保每次进入都加载正确的城市数据
    controller.loadCoworkingsByCity(widget.cityId, refresh: true);

    // 初始化 SignalR 连接
    _initSignalRSubscription();
  }

  /// 初始化 SignalR 订阅
  Future<void> _initSignalRSubscription() async {
    // 延迟等待数据加载完成后再订阅
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // 订阅当前列表中所有 Coworking 的验证人数更新
      if (controller.coworkingSpaces.isNotEmpty) {
        controller.subscribeCoworkingList(controller.coworkingSpaces);
      }
    });

    // 监听列表变化，自动订阅新加载的数据
    ever(controller.coworkingSpaces, (List<CoworkingSpace> spaces) {
      if (spaces.isNotEmpty && mounted) {
        controller.subscribeCoworkingList(spaces);
      }
    });
  }

  /// 监听滚动，实现无限滚动加载
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // 滚动到 90% 位置时加载更多
      controller.loadMoreCoworkingSpaces();
    }
  }

  /// 刷新数据(下拉刷新)
  Future<void> _refreshData() async {
    await controller.loadCoworkingsByCity(
      widget.cityId,
      refresh: true, // 刷新模式，重置分页
    );
  }

  @override
  Future<void> onRouteResume() async {
    // 页面恢复时刷新数据，确保数据同步
    log('🔄 CoworkingList: 页面恢复，刷新数据');
    await _refreshData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(color: Colors.black87),
        title: Text(
          widget.cityName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 排序按钮
          PopupMenuButton<String>(
            icon: const Icon(FontAwesomeIcons.arrowDownShortWide, color: Colors.black54, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'rating':
                  controller.sortByRating();
                  break;
                case 'price':
                  controller.sortByPrice();
                  break;
                case 'distance':
                  controller.sortByDistance();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'rating',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.star, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.rating),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'price',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.dollarSign, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.price),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'distance',
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.locationDot, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.distance),
                    ],
                  ),
                ),
              ];
            },
          ),
          // 添加按钮
          IconButton(
            icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.black54),
            onPressed: () async {
              // 跳转到添加页面,预填充当前城市信息
              await NavigationUtil.toWithCallback<bool>(
                page: () => AddCoworkingPage(
                  cityId: widget.cityId,
                  cityName: widget.cityName,
                  countryName: widget.countryName,
                ),
                onResult: (result) async {
                  if (result.needsRefresh) {
                    await _refreshData();
                    // 通知 CoworkingHomePage 也需要刷新
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // 显示骨架屏加载效果
              if (controller.isLoading.value && controller.filteredSpaces.isEmpty) {
                return _buildSkeletonList();
              }

              if (controller.filteredSpaces.isEmpty) {
                return Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noData,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  controller: _scrollController, // 添加滚动控制器
                  cacheExtent: 500, // 增加缓存范围，提升滚动性能
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredSpaces.length + 1, // +1 用于底部加载指示器
                  itemBuilder: (context, index) {
                    // 最后一项显示加载指示器
                    if (index == controller.filteredSpaces.length) {
                      return _buildLoadMoreIndicator();
                    }

                    final space = controller.filteredSpaces[index];
                    return _buildCoworkingCard(context, space);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 共享办公空间卡片 - Hero 风格（信息覆盖在图片上）
  Widget _buildCoworkingCard(BuildContext context, CoworkingSpace space) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await NavigationUtil.toWithCallback<CoworkingSpace>(
              page: () => CoworkingDetailPage(space: space),
              onResult: (result) async {
                if (result.hasData && mounted) {
                  final controller = Get.find<CoworkingStateController>();
                  controller.updateCoworkingInList(result.data!);
                } else if (result.needsRefresh && mounted) {
                  await _refreshData();
                }
              },
            );
          },
          child: _buildCoworkingCardContent(context, space),
        ),
      ),
    );
  }

  Widget _buildCoworkingCardContent(BuildContext context, CoworkingSpace space) {
    return Stack(
      children: [
        // 背景图片
        AspectRatio(
          aspectRatio: 16 / 10,
          child: CachedNetworkImage(
            imageUrl: space.spaceInfo.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(FontAwesomeIcons.building, size: 48, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        // 右上角：验证徽章
        Positioned(
          top: 12,
          right: 12,
          child: CoworkingVerificationBadge(space: space),
        ),
        // 左上角：编辑按钮（仅创建者可见）
        if (space.isOwner)
          Positioned(
            top: 12,
            left: 12,
            child: AppEditButton(
              onPressed: () async {
                await NavigationUtil.toWithCallback<bool>(
                  page: () => AddCoworkingPage(editingSpace: space),
                  onResult: (result) async {
                    if (result.needsRefresh && mounted) {
                      await _refreshData();
                    }
                  },
                );
              },
              size: 14,
              mini: true,
            ),
          ),
        // 底部信息面板
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _buildHeroInfoPanel(context, space),
        ),
      ],
    );
  }

  /// 底部信息面板 - Hero 风格
  Widget _buildHeroInfoPanel(BuildContext context, CoworkingSpace space) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 名称
          Text(
            space.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 地址
          if (space.fullAddress.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    space.fullAddress,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          // 指标 Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 评分
                _buildHeroPill(
                  FontAwesomeIcons.star,
                  space.spaceInfo.rating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                // WiFi 速度
                _buildHeroPill(
                  FontAwesomeIcons.wifi,
                  '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                ),
                // 月租价格
                if (space.pricing.monthlyRate != null) ...[
                  const SizedBox(width: 8),
                  _buildHeroPill(
                    FontAwesomeIcons.dollarSign,
                    '${space.pricing.monthlyRate!.toStringAsFixed(0)}/${l10n.monthlyRate}',
                  ),
                ],
                // 24/7 开放
                if (space.amenities.has24HourAccess) ...[
                  const SizedBox(width: 8),
                  _buildHeroPill(
                    FontAwesomeIcons.clock,
                    '24/7',
                    color: Colors.orange,
                  ),
                ],
                // 免费试用
                if (space.pricing.hasFreeTrial) ...[
                  const SizedBox(width: 8),
                  _buildHeroPill(
                    FontAwesomeIcons.tag,
                    'Free Trial',
                    color: const Color(0xFFFF4458),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hero 样式的信息标签
  Widget _buildHeroPill(IconData icon, String value, {Color? color}) {
    final pillColor = color ?? Colors.white;
    final hasCustomColor = color != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasCustomColor ? pillColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: hasCustomColor ? pillColor : Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasCustomColor ? pillColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部加载指示器
  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      // 如果正在加载更多，显示加载指示器
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // 如果没有更多数据，显示提示
      if (!controller.hasMore.value && controller.filteredSpaces.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '没有更多数据了',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        );
      }

      // 其他情况不显示任何内容
      return const SizedBox.shrink();
    });
  }

  /// 骨架屏列表（加载时显示）
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // 显示5个骨架项
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  /// 单个骨架屏卡片
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片骨架
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            // 信息骨架
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题骨架
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 地址骨架
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 标签骨架
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
