import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/pages/coworking_detail/coworking_detail_page.dart';
import 'package:df_admin_mobile/widgets/coworking_verification_badge.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
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
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 120),
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

/// 共享办公空间卡片
class _CoworkingSpaceCard extends StatelessWidget {
  const _CoworkingSpaceCard({required this.space});

  final coworking.CoworkingSpace space;

  @override
  Widget build(BuildContext context) {
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
        onTap: () => Get.to(() => CoworkingDetailPage(space: space)),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpaceImage(),
            _buildSpaceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              space.spaceInfo.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(FontAwesomeIcons.building, size: 48),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: CoworkingVerificationBadge(
            space: space,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameAndRating(),
          const SizedBox(height: 8),
          _buildAddress(),
          const SizedBox(height: 12),
          _buildInfoChips(),
        ],
      ),
    );
  }

  Widget _buildNameAndRating() {
    return Row(
      children: [
        Expanded(
          child: Text(
            space.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                space.spaceInfo.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.locationDot, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            space.location.address,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InfoChip(
          icon: FontAwesomeIcons.wifi,
          label: '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
          color: Colors.blue,
        ),
        if (space.pricing.monthlyRate != null)
          _InfoChip(
            icon: FontAwesomeIcons.dollarSign,
            label: '\$${space.pricing.monthlyRate!.toStringAsFixed(0)}/mo',
            color: Colors.green,
          ),
        if (space.amenities.has24HourAccess)
          const _InfoChip(
            icon: FontAwesomeIcons.clock,
            label: '24/7',
            color: Colors.orange,
          ),
        if (space.pricing.hasFreeTrial)
          const _InfoChip(
            icon: FontAwesomeIcons.tag,
            label: 'Free Trial',
            color: Color(0xFFFF4458),
          ),
      ],
    );
  }
}

/// 信息标签组件
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
