import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/coworking_verification_badge.dart';
import 'package:go_nomads_app/widgets/edit_button.dart';

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
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 排序按钮
          PopupMenuButton<String>(
            icon: Icon(FontAwesomeIcons.arrowDownShortWide, color: Colors.black54, size: 20.r),
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
                      Icon(FontAwesomeIcons.star, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(l10n.rating),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'price',
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.dollarSign, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(l10n.price),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'distance',
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.locationDot, size: 20.r),
                      SizedBox(width: 8.w),
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
              final isLoading = controller.isLoading.value && controller.filteredSpaces.isEmpty;

              Widget content;
              if (controller.filteredSpaces.isEmpty) {
                content = Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 80.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.noData,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                content = RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    controller: _scrollController, // 添加滚动控制器
                    cacheExtent: 500, // 增加缓存范围，提升滚动性能
                    padding: EdgeInsets.all(16.w),
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
              }

              return AppLoadingSwitcher(
                isLoading: isLoading,
                loading: _buildSkeletonList(),
                child: content,
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
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
                child: Center(
                  child: Icon(FontAwesomeIcons.building, size: 48.r, color: Colors.grey),
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
          top: 12.h,
          right: 12.w,
          child: CoworkingVerificationBadge(space: space),
        ),
        // 左上角：编辑按钮（仅创建者可见）
        if (space.isOwner)
          Positioned(
            top: 12.h,
            left: 12.w,
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
              size: 14.r,
              mini: true,
            ),
          ),
        // 底部信息面板
        Positioned(
          left: 12.w,
          right: 12.w,
          bottom: 12.h,
          child: _buildHeroInfoPanel(context, space),
        ),
      ],
    );
  }

  /// 底部信息面板 - Hero 风格
  Widget _buildHeroInfoPanel(BuildContext context, CoworkingSpace space) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
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
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 地址
          if (space.fullAddress.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 11.r,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    space.fullAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.h),
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
                SizedBox(width: 8.w),
                // WiFi 速度
                _buildHeroPill(
                  FontAwesomeIcons.wifi,
                  '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                ),
                // 月租价格
                if (space.pricing.monthlyRate != null) ...[
                  SizedBox(width: 8.w),
                  _buildHeroPill(
                    FontAwesomeIcons.dollarSign,
                    '${space.pricing.monthlyRate!.toStringAsFixed(0)}/${l10n.monthlyRate}',
                  ),
                ],
                // 24/7 开放
                if (space.amenities.has24HourAccess) ...[
                  SizedBox(width: 8.w),
                  _buildHeroPill(
                    FontAwesomeIcons.clock,
                    '24/7',
                    color: Colors.orange,
                  ),
                ],
                // 免费试用
                if (space.pricing.hasFreeTrial) ...[
                  SizedBox(width: 8.w),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: hasCustomColor ? pillColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: hasCustomColor ? pillColor : Colors.white.withValues(alpha: 0.9),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
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
        return Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // 如果没有更多数据，显示提示
      if (!controller.hasMore.value && controller.filteredSpaces.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Center(
            child: Text(
              '没有更多数据了',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
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
    return const AppSceneLoading(scene: AppLoadingScene.coworkingList, fullScreen: true);
  }
}
