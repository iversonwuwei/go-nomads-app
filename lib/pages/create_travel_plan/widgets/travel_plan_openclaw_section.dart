import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';

class TravelPlanOpenClawSection extends GetView<CreateTravelPlanPageController> {
  const TravelPlanOpenClawSection({super.key});

  static const _planningModes = [
    ('quick', '快速草案', '更快出结果，适合先看方向', Icons.flash_on_outlined),
    ('balanced', '平衡规划', '兼顾速度、预算与可玩性', Icons.tune_outlined),
    ('research', 'OpenClaw 研究增强', '强调实时信号与研究线索', Icons.auto_awesome_outlined),
  ];

  static const _planningGoals = [
    ('work', '远程工作优先', Icons.work_outline),
    ('explore', '城市探索优先', Icons.travel_explore_outlined),
    ('hybrid', '工作与玩平衡', Icons.balance_outlined),
  ];

  static const _signals = [
    ('weather', '实时天气', Icons.cloud_outlined),
    ('events', '本周活动', Icons.event_outlined),
    ('coworking', '共享办公', Icons.domain_outlined),
    ('transit', '交通换乘', Icons.train_outlined),
    ('visa', '签证与入境', Icons.security_outlined),
    ('budget', '预算校验', Icons.account_balance_wallet_outlined),
  ];

  @override
  String? get tag => CreateTravelPlanPageController.controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: tag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'OpenClaw 研究增强',
          icon: Icons.auto_awesome,
        ),
        SizedBox(height: 8.h),
        Text(
          '把规划器升级成研究助手。你可以指定规划节奏、工作目标，以及希望 OpenClaw 优先核对的实时信号。',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], height: 1.45),
        ),
        SizedBox(height: 14.h),
        _SubSectionLabel(label: '规划模式'),
        SizedBox(height: 10.h),
        Obx(
          () => Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _planningModes
                .map((mode) => _OptionCard(
                      title: mode.$2,
                      subtitle: mode.$3,
                      icon: mode.$4,
                      selected: controller.planningMode.value == mode.$1,
                      onTap: () => controller.setPlanningMode(mode.$1),
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 20.h),
        _SubSectionLabel(label: '这次更偏向什么'),
        SizedBox(height: 10.h),
        Obx(
          () => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _planningGoals
                .map((goal) => _FilterChip(
                      label: goal.$2,
                      icon: goal.$3,
                      selected: controller.planningObjective.value == goal.$1,
                      onTap: () => controller.setPlanningObjective(goal.$1),
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 20.h),
        Obx(() {
          final researchMode = controller.planningMode.value == 'research';
          return AnimatedOpacity(
            opacity: researchMode ? 1 : 0.72,
            duration: const Duration(milliseconds: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubSectionLabel(label: '希望优先核对哪些信号'),
                SizedBox(height: 10.h),
                Obx(
                  () => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _signals
                        .map((signal) => _FilterChip(
                              label: signal.$2,
                              icon: signal.$3,
                              selected: controller.openClawSignals.contains(signal.$1),
                              onTap: () => controller.toggleOpenClawSignal(signal.$1),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFFFD6DC)),
                  ),
                  child: Text(
                    researchMode
                        ? '已启用研究增强：这些偏好会作为 OpenClaw 提示线索并入 AI 旅行规划。'
                        : '当前未启用研究增强。你仍然可以先挑选信号，切换到 OpenClaw 模式后会优先使用。',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFFB23A48),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}

class _SubSectionLabel extends StatelessWidget {
  final String label;

  const _SubSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 1.sw - 72.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF7A57)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.18),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color:
                    selected ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFFF4458).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: selected ? Colors.white : const Color(0xFFFF4458), size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.35,
                      color: selected ? Colors.white.withValues(alpha: 0.9) : Colors.grey[600],
                    ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF4458) : Colors.grey[100],
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: selected ? const Color(0xFFFF4458) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.r, color: selected ? Colors.white : Colors.black54),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
