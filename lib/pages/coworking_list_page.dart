import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/presentation/controllers/coworking_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_coworking_page.dart';
import 'package:df_admin_mobile/pages/coworking_detail_page.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/coworking_verification_badge.dart';
import 'package:df_admin_mobile/widgets/edit_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

    // 延迟加载，防止快速导航时的并发请求
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      // 检查是否需要加载数据
      final needsLoad = controller.currentCityId.value != widget.cityId || controller.coworkingSpaces.isEmpty;

      if (needsLoad) {
        print('🔄 CoworkingList: 首次加载或cityId变化,开始加载数据');
        controller.loadCoworkingsByCity(widget.cityId, refresh: true);
      } else {
        print('✅ CoworkingList: 使用缓存数据,跳过加载');
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
    // 页面恢复时不刷新，避免并发请求
    // 数据已通过 initState 或上次加载获取
    print('🔙 CoworkingList: 页面恢复,使用缓存数据');
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCoworkingPage(
                    cityId: widget.cityId,
                    cityName: widget.cityName,
                    countryName: widget.countryName,
                  ),
                ),
              );

              if (!context.mounted) return;

              // 如果成功添加,刷新列表并通知上级页面
              if (result == true) {
                await _refreshData();

                if (!context.mounted) return;
                // 通知 CoworkingHomePage 也需要刷新
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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

              return ListView.builder(
                controller: _scrollController, // 添加滚动控制器
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
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 共享办公空间卡片
  Widget _buildCoworkingCard(BuildContext context, CoworkingSpace space) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // 等待详情页返回,如果返回 true 则刷新数据
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoworkingDetailPage(space: space),
            ),
          );

          // 如果详情页有数据变化(编辑/删除),刷新列表
          if (result == true && mounted) {
            await _refreshData();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      space.spaceInfo.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(FontAwesomeIcons.building, size: 50),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CoworkingVerificationBadge(space: space),
                  ),
                ],
              ),
            ),

            // 信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和评分
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 编辑按钮（仅创建者可见）
                      if (space.isOwner)
                        AppEditButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCoworkingPage(
                                  editingSpace: space,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              await _refreshData();
                            }
                          },
                          size: 14,
                          mini: true,
                        ),
                      if (space.isOwner) const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            space.spaceInfo.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${space.spaceInfo.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 地址
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.locationDot, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.fullAddress,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 创建者信息
                  if (space.creatorName != null && space.creatorName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.user, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          space.creatorName!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // 关键信息
                  Row(
                    children: [
                      _buildInfoChip(
                        FontAwesomeIcons.wifi,
                        '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      if (space.pricing.monthlyRate != null)
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return _buildInfoChip(
                              FontAwesomeIcons.dollarSign,
                              '${space.pricing.monthlyRate!.toStringAsFixed(0)}/${l10n.monthlyRate}',
                              Colors.green,
                            );
                          },
                        ),
                      const SizedBox(width: 8),
                      if (space.amenities.has24HourAccess)
                        _buildInfoChip(
                          FontAwesomeIcons.clock,
                          '24/7',
                          Colors.orange,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 设施
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: space.amenities
                        .getAvailableAmenities()
                        .take(4)
                        .map(
                          (amenity) => Chip(
                            label: Text(
                              amenity,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),

                  if (space.pricing.hasFreeTrial) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.tag, size: 16, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            space.pricing.trialDuration != null
                                ? 'Free ${space.pricing.trialDuration} trial available'
                                : 'Free trial available',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
}
