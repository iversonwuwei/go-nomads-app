import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        SizedBox(height: 8.h),
        Text(
          '选择您在${controller.cityName}想要游览的景点类型',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 12.h),
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
      spacing: 8.w,
      runSpacing: 8.w,
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[50],
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                      blurRadius: 6.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.r, color: isSelected ? Colors.white : const Color(0xFFFF4458)),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13.sp,
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
        SizedBox(height: 12.h),
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
      spacing: 8.w,
      runSpacing: 8.w,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.r, color: isSelected ? Colors.white : Colors.black54),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 13.sp,
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
        SizedBox(height: 12.h),
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
      spacing: 8.w,
      runSpacing: 8.w,
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 13.sp,
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
        Icon(icon, size: 20.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
