import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/skills_interests_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/interests_selector.dart';
import 'package:go_nomads_app/widgets/skills_selector.dart';

/// 技能和兴趣选择页面
/// 用于用户注册流程或个人资料编辑
/// 需要 StatefulWidget 因为 TabController 需要 SingleTickerProviderStateMixin
class SkillsInterestsPage extends StatefulWidget {
  const SkillsInterestsPage({super.key});

  @override
  State<SkillsInterestsPage> createState() => _SkillsInterestsPageState();
}

class _SkillsInterestsPageState extends State<SkillsInterestsPage> with SingleTickerProviderStateMixin {
  static const String _tag = 'SkillsInterestsPage';
  late TabController _tabController;
  late final SkillsInterestsPageController _controller;

  SkillsInterestsPageController _useController() {
    if (Get.isRegistered<SkillsInterestsPageController>(tag: _tag)) {
      return Get.find<SkillsInterestsPageController>(tag: _tag);
    }
    return Get.put(SkillsInterestsPageController(), tag: _tag);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = _useController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final items = _buildNavItems(l10n);

          return AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final currentIndex = _tabController.index;
              final currentItem = items[currentIndex];

              return Column(
                children: [
                  _buildHeader(l10n),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                    child: _SkillsInterestsCompactToolbar(
                      items: items,
                      currentIndex: currentIndex,
                      currentItem: currentItem,
                      onTabSelected: _switchTab,
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(currentIndex),
                        child: _buildPanel(currentIndex),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.skillsInterestsTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.skillsInterestsSummary(
                    _controller.selectedSkills.length,
                    _controller.selectedInterests.length,
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            label: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  List<_SkillsInterestsNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _SkillsInterestsNavItem(
        index: 0,
        label: l10n.skills,
        subtitle: '${_controller.selectedSkills.length}/10 selected',
        description: l10n.selectSkills,
        icon: FontAwesomeIcons.briefcase,
        accent: const Color(0xFF1E5C7A),
        selectedCount: _controller.selectedSkills.length,
        limit: 10,
      ),
      _SkillsInterestsNavItem(
        index: 1,
        label: l10n.interests,
        subtitle: '${_controller.selectedInterests.length}/15 selected',
        description: l10n.selectInterests,
        icon: FontAwesomeIcons.heart,
        accent: const Color(0xFF7B3559),
        selectedCount: _controller.selectedInterests.length,
        limit: 15,
      ),
    ];
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  Widget _buildPanel(int index) {
    switch (index) {
      case 0:
        return Obx(() => SkillsSelector(
              selectedSkillIds: _controller.selectedSkillIds,
              onChanged: _controller.updateSelectedSkills,
              showProficiency: true,
              maxSelection: 10,
            ));
      case 1:
        return Obx(() => InterestsSelector(
              selectedInterestIds: _controller.selectedInterestIds,
              onChanged: _controller.updateSelectedInterests,
              showIntensity: true,
              maxSelection: 15,
            ));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.skillsInterestsSelected,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.skillsInterestsSummary(
                          _controller.selectedSkills.length,
                          _controller.selectedInterests.length,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                FilledButton(
                  onPressed: !_controller.hasSelection || _controller.isSaving.value
                      ? null
                      : _controller.saveSkillsAndInterests,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _controller.isSaving.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.save),
                ),
              ],
            )),
      ),
    );
  }
}

class _SkillsInterestsNavItem {
  const _SkillsInterestsNavItem({
    required this.index,
    required this.label,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.selectedCount,
    required this.limit,
  });

  final int index;
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final int selectedCount;
  final int limit;
}

class _SkillsInterestsPill extends StatelessWidget {
  const _SkillsInterestsPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _SkillsInterestsNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? item.accent : Colors.white,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                item.icon,
                size: 12.sp,
                color: isActive ? Colors.white : item.accent,
              ),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillsInterestsCompactToolbar extends StatelessWidget {
  const _SkillsInterestsCompactToolbar({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.onTabSelected,
  });

  final List<_SkillsInterestsNavItem> items;
  final int currentIndex;
  final _SkillsInterestsNavItem currentItem;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DED0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: currentItem.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: FaIcon(
                    currentItem.icon,
                    size: 14.sp,
                    color: currentItem.accent,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentItem.label,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currentItem.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentIndex + 1}/${items.length}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8.w),
                  child: _SkillsInterestsPill(
                    item: item,
                    isActive: currentIndex == index,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
