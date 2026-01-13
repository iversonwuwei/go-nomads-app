import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 景点选择部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanAttractionsSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanAttractionsSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: '想去的景点', icon: FontAwesomeIcons.city),
        const SizedBox(height: 8),
        Text(
          '选择您在${controller.cityName}想要游览的景点类型',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _AttractionsWrap(controllerTag: controllerTag),
      ],
    );
  }
}

/// 景点选项网格
class _AttractionsWrap extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _AttractionsWrap({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.cityAttractions.map((attraction) {
        return _AttractionChip(
          label: attraction['name'] as String,
          id: attraction['id'] as String,
          icon: attraction['icon'] as IconData,
          controllerTag: controllerTag,
        );
      }).toList(),
    );
  }
}

/// 景点选项芯片
class _AttractionChip extends GetView<CreateTravelPlanPageController> {
  final String label;
  final String id;
  final IconData icon;
  final String controllerTag;

  const _AttractionChip({
    required this.label,
    required this.id,
    required this.icon,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isSelected = controller.selectedAttractions.contains(id);

      return GestureDetector(
        onTap: () => controller.toggleAttraction(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFFFF4458)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 旅行风格部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanStyleSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanStyleSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.travelStyle, icon: FontAwesomeIcons.paintbrush),
        const SizedBox(height: 12),
        _StyleChipsWrap(controllerTag: controllerTag),
      ],
    );
  }
}

/// 旅行风格选项网格
class _StyleChipsWrap extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _StyleChipsWrap({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StyleChip(
            label: l10n.culture, value: 'culture', icon: FontAwesomeIcons.landmark, controllerTag: controllerTag),
        _StyleChip(
            label: l10n.adventure, value: 'adventure', icon: FontAwesomeIcons.mountain, controllerTag: controllerTag),
        _StyleChip(
            label: l10n.relaxation, value: 'relaxation', icon: FontAwesomeIcons.spa, controllerTag: controllerTag),
        _StyleChip(
            label: l10n.nightlife,
            value: 'nightlife',
            icon: FontAwesomeIcons.champagneGlasses,
            controllerTag: controllerTag),
      ],
    );
  }
}

/// 风格选项芯片
class _StyleChip extends GetView<CreateTravelPlanPageController> {
  final String label;
  final String value;
  final IconData icon;
  final String controllerTag;

  const _StyleChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isSelected = controller.travelStyle.value == value;

      return GestureDetector(
        onTap: () => controller.setTravelStyle(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 兴趣爱好部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanInterestsSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanInterestsSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.interests, icon: FontAwesomeIcons.heart),
        const SizedBox(height: 12),
        _InterestsWrap(controllerTag: controllerTag),
      ],
    );
  }
}

/// 兴趣选项网格
class _InterestsWrap extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _InterestsWrap({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InterestChip(label: l10n.photography, controllerTag: controllerTag),
        _InterestChip(label: l10n.history, controllerTag: controllerTag),
        _InterestChip(label: 'Art', controllerTag: controllerTag),
        _InterestChip(label: l10n.nature, controllerTag: controllerTag),
        _InterestChip(label: 'Beach', controllerTag: controllerTag),
        _InterestChip(label: 'Temples', controllerTag: controllerTag),
        _InterestChip(label: 'Markets', controllerTag: controllerTag),
        _InterestChip(label: 'Coffee', controllerTag: controllerTag),
      ],
    );
  }
}

/// 兴趣选项芯片
class _InterestChip extends GetView<CreateTravelPlanPageController> {
  final String label;
  final String controllerTag;

  const _InterestChip({
    required this.label,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isSelected = controller.interests.contains(label);

      return GestureDetector(
        onTap: () => controller.toggleInterest(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }
}

/// 区块标题组件
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF4458)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
