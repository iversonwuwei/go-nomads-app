import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_page.dart';
import 'package:go_nomads_app/widgets/coworking_verification_badge.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../features/coworking/domain/entities/coworking_space.dart' as coworking;
import '../../../../features/coworking/presentation/controllers/coworking_state_controller.dart';
import '../../city_detail_controller.dart';

/// Coworking Tab - GetView 实现
///
/// 显示城市的共享办公空间列表
class CoworkingTab extends GetView<CityDetailController> {
  const CoworkingTab({
    super.key,
    required this.tag,
    required this.onAddCoworkingPressed,
  });

  @override
  final String? tag;
  final VoidCallback onAddCoworkingPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return Obx(() {
      // 显示加载状态
      if (coworkingController.isLoading.value) {
        return const CoworkingTabSkeleton();
      }

      // 显示空状态
      if (coworkingController.coworkingSpaces.isEmpty) {
        return _EmptyCoworkingState(
          cityName: controller.cityName,
          onAddPressed: onAddCoworkingPressed,
        );
      }

      // 显示共享办公空间列表
      return _CoworkingList(
        cityName: controller.cityName,
        spaces: coworkingController.coworkingSpaces,
        isAdminOrModerator: controller.isAdmin.value || controller.isModerator.value,
        onAddCoworkingPressed: onAddCoworkingPressed,
      );
    });
  }
}

/// 空状态组件
class _EmptyCoworkingState extends StatelessWidget {
  const _EmptyCoworkingState({
    required this.cityName,
    required this.onAddPressed,
  });

  final String cityName;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return RefreshIndicator(
      onRefresh: () => coworkingController.loadCoworkingSpacesByCity(cityName),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = (constraints.maxHeight - 120).clamp(0.0, double.infinity);
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIllustration(),
                  const SizedBox(height: 40),
                  Text(
                    'No coworking spaces yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Help build the community',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildAddButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF4458).withValues(alpha: 0.08),
            const Color(0xFFFF4458).withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40,
            right: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 30,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(
            FontAwesomeIcons.building,
            size: 80,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.plus, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              'Add First Space',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 共享办公空间列表
class _CoworkingList extends StatelessWidget {
  const _CoworkingList({
    required this.cityName,
    required this.spaces,
    required this.isAdminOrModerator,
    required this.onAddCoworkingPressed,
  });

  final String cityName;
  final List<coworking.CoworkingSpace> spaces;
  final bool isAdminOrModerator;
  final VoidCallback onAddCoworkingPressed;

  @override
  Widget build(BuildContext context) {
    final coworkingController = Get.find<CoworkingStateController>();

    return RefreshIndicator(
      onRefresh: () => coworkingController.loadCoworkingSpacesByCity(cityName),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
        itemCount: spaces.length,
        itemBuilder: (context, index) {
          final space = spaces[index];
          return _CoworkingSpaceCard(space: space);
        },
      ),
    );
  }
}

/// 共享办公空间卡片 - Hero 风格（信息覆盖在图片上）
class _CoworkingSpaceCard extends StatelessWidget {
  const _CoworkingSpaceCard({required this.space});

  final coworking.CoworkingSpace space;

  @override
  Widget build(BuildContext context) {
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
          onTap: () => Get.to(() => CoworkingDetailPage(space: space)),
          borderRadius: BorderRadius.circular(16),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Stack(
      children: [
        // 背景图片
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            space.spaceInfo.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
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
          child: CoworkingVerificationBadge(
            space: space,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),
        // 底部信息面板
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _buildHeroInfoPanel(),
        ),
      ],
    );
  }

  Widget _buildHeroInfoPanel() {
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
          if (space.location.address.isNotEmpty) ...[
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
                    space.location.address,
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
                _HeroPill(
                  icon: FontAwesomeIcons.star,
                  value: space.spaceInfo.rating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
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
                // 免费试用
                if (space.pricing.hasFreeTrial) ...[
                  const SizedBox(width: 8),
                  const _HeroPill(
                    icon: FontAwesomeIcons.tag,
                    value: 'Free Trial',
                    color: Color(0xFFFF4458),
                  ),
                ],
              ],
            ),
          ),
        ],
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
