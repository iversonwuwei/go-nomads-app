import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_page.dart';
import 'package:go_nomads_app/pages/coworking_reviews_page.dart';
import 'package:go_nomads_app/widgets/coworking_verification_badge.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailImageSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailImageSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allImages = _c.allImages;
      final hasMultipleImages = _c.hasMultipleImages;

      return Stack(
        fit: StackFit.expand,
        children: [
          // 图片轮播
          hasMultipleImages
              ? PageView.builder(
                  controller: _c.pageController,
                  onPageChanged: _c.onPageChanged,
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      allImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(FontAwesomeIcons.building, size: 100),
                        );
                      },
                    );
                  },
                )
              : Image.network(
                  _c.space.value.spaceInfo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(FontAwesomeIcons.building, size: 100),
                    );
                  },
                ),
          // 渐变遮罩
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // 底部信息面板 - 贴着底部
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildHeroInfoPanel(context),
          ),
          // 图片指示器 - 显示在上方
          if (hasMultipleImages)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _c.currentImageIndex.value == index ? Colors.white : Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              )),
            ),
        ],
      );
    });
  }

  Widget _buildHeroInfoPanel(BuildContext context) {
    return Obx(() {
      final space = _c.space.value;
      final isOwner = space.isOwner;
      final isAdmin = _c.isAdmin.value;
      final showActions = isOwner || isAdmin;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 第一行：评分 + 验证徽章 + 操作按钮
            Row(
              children: [
                // 评分 - 可点击跳转到评论页
                GestureDetector(
                  onTap: () {
                    Get.to(() => CoworkingReviewsPage(
                          coworkingId: _c.space.value.id,
                          coworkingName: _c.space.value.name,
                        ))?.then((_) {
                      _c.loadComments();
                      _c.reloadCoworkingDetail();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FontAwesomeIcons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          space.spaceInfo.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${space.spaceInfo.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          FontAwesomeIcons.chevronRight,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 验证徽章
                CoworkingVerificationBadge(
                  space: space,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  darkTheme: true,
                  onVerified: (updatedSpace) => _c.updateSpace(updatedSpace),
                ),
                const Spacer(),
                // 操作按钮区域
                if (showActions) ...[
                  // 编辑按钮
                  if (isOwner)
                    _ActionButton(
                      icon: FontAwesomeIcons.penToSquare,
                      onTap: () => _navigateToEdit(context),
                    ),
                  // 删除按钮
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: FontAwesomeIcons.trash,
                      color: Colors.red,
                      onTap: () => _showDeleteConfirmation(context),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 10),
            // 第二行：信息指标
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // WiFi 速度
                  _HeroPill(
                    icon: FontAwesomeIcons.wifi,
                    value: '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                  ),
                  // 月租价格
                  if (space.pricing.monthlyRate != null) ...[
                    const SizedBox(width: 8),
                    _HeroPill(
                      icon: FontAwesomeIcons.dollarSign,
                      value: '${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
                    ),
                  ],
                  // 24/7 开放
                  if (space.amenities.has24HourAccess) ...[
                    const SizedBox(width: 8),
                    const _HeroPill(
                      icon: FontAwesomeIcons.clock,
                      value: '24/7',
                      color: Colors.orange,
                    ),
                  ],
                  // 更新时间
                  if (space.lastUpdated != null) ...[
                    const SizedBox(width: 8),
                    _HeroPill(
                      icon: FontAwesomeIcons.arrowsRotate,
                      value: _c.formatDate(space.lastUpdated!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCoworkingPage(editingSpace: _c.space.value),
      ),
    );
    if (result == true) {
      _c.markDataChanged();
      await _c.reloadCoworkingDetail();
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除 "${_c.space.value.name}" 吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _c.deleteCoworkingSpace();
    }
  }
}

/// 操作按钮组件
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: buttonColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: buttonColor.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: buttonColor,
        ),
      ),
    );
  }
}

/// Hero 样式的信息标签
class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
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
}

class CoworkingDetailImageCounterBadge extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailImageCounterBadge({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_c.hasMultipleImages) return const SizedBox.shrink();

      final allImages = _c.allImages;
      return Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(128),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Obx(() => Text(
          '${_c.currentImageIndex.value + 1}/${allImages.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        )),
      );
    });
  }
}
