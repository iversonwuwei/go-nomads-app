import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/skill/domain/entities/skill.dart';
import 'package:go_nomads_app/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 技能选择器组件
class SkillsSelector extends StatefulWidget {
  /// 已选择的技能ID列表
  final List<String> selectedSkillIds;

  /// 选择变化回调
  final Function(List<UserSkill>) onChanged;

  /// 是否显示熟练度选择
  final bool showProficiency;

  /// 最大选择数量（0表示无限制）
  final int maxSelection;

  const SkillsSelector({
    super.key,
    required this.selectedSkillIds,
    required this.onChanged,
    this.showProficiency = true,
    this.maxSelection = 0,
  });

  @override
  State<SkillsSelector> createState() => _SkillsSelectorState();
}

class _SkillsSelectorState extends State<SkillsSelector> {
  late final SkillStateController _skillController;

  List<SkillsByCategory> _skillsByCategory = [];
  final List<UserSkill> _selectedSkills = [];
  List<Skill> _allSkills = [];
  bool _didRestoreInitialSelection = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _skillController = Get.find<SkillStateController>();
    _loadSkills();
  }

  @override
  void didUpdateWidget(covariant SkillsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!setEquals(widget.selectedSkillIds.toSet(), oldWidget.selectedSkillIds.toSet())) {
      _restoreSelectionFromWidget(force: true);
    }
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);

    await _skillController.getSkills();

    final skills = List<Skill>.from(_skillController.skills);
    if (!mounted) return;

    setState(() {
      _allSkills = skills;
      _skillsByCategory = _groupSkillsByCategory(skills);
      _isLoading = false;
    });

    _restoreSelectionFromWidget();

    final error = _skillController.errorMessage.value;
    if (error != null && error.isNotEmpty && mounted) {
      AppToast.error(error);
    }
  }

  void _toggleSkill(Skill skill) {
    final isSelected = _selectedSkills.any((s) => s.skillId == skill.id);

    if (isSelected) {
      // 取消选择
      setState(() {
        _selectedSkills.removeWhere((s) => s.skillId == skill.id);
      });
      widget.onChanged(_selectedSkills);
    } else {
      // 检查是否超过最大选择数
      if (widget.maxSelection > 0 && _selectedSkills.length >= widget.maxSelection) {
        AppToast.error(AppLocalizations.of(Get.context!)!.maxSkillsReached(widget.maxSelection.toString()));
        return;
      }

      // 如果需要选择熟练度，显示对话框
      if (widget.showProficiency) {
        _showProficiencyDialog(skill);
      } else {
        _addSkill(skill, null, null);
      }
    }
  }

  void _addSkill(Skill skill, String? proficiency, int? yearsOfExperience) {
    final userSkill = UserSkill(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 临时ID
      userId: '', // 将由后端填充
      skillId: skill.id,
      skillName: skill.name,
      category: skill.category,
      icon: skill.icon,
      proficiencyLevel: proficiency,
      yearsOfExperience: yearsOfExperience,
      createdAt: DateTime.now(),
    );

    setState(() {
      _selectedSkills.add(userSkill);
    });
    widget.onChanged(_selectedSkills);
  }

  void _restoreSelectionFromWidget({bool force = false}) {
    if (_allSkills.isEmpty || widget.selectedSkillIds.isEmpty) {
      return;
    }

    if (!force && _didRestoreInitialSelection) {
      return;
    }

    final restored = _buildUserSkillsFromIds(widget.selectedSkillIds);
    if (restored.isEmpty) {
      _didRestoreInitialSelection = true;
      return;
    }

    setState(() {
      _selectedSkills
        ..clear()
        ..addAll(restored);
    });

    _didRestoreInitialSelection = true;
  }

  List<UserSkill> _buildUserSkillsFromIds(List<String> skillIds) {
    final now = DateTime.now();
    final results = <UserSkill>[];
    for (final id in skillIds) {
      final skill = _findSkillById(id);
      if (skill == null) continue;
      results.add(
        UserSkill(
          id: 'selected-$id-${now.millisecondsSinceEpoch}',
          userId: '',
          skillId: skill.id,
          skillName: skill.name,
          category: skill.category,
          icon: skill.icon,
          proficiencyLevel: null,
          yearsOfExperience: null,
          createdAt: now,
        ),
      );
    }
    return results;
  }

  Skill? _findSkillById(String id) {
    for (final skill in _allSkills) {
      if (skill.id == id) {
        return skill;
      }
    }
    return null;
  }

  List<SkillsByCategory> _groupSkillsByCategory(List<Skill> skills) {
    final Map<String, List<Skill>> grouped = {};
    for (final skill in skills) {
      grouped.putIfAbsent(skill.category, () => []).add(skill);
    }

    final categories = grouped.entries
        .map((entry) => SkillsByCategory(
              category: entry.key,
              skills: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));

    return categories;
  }

  void _showProficiencyDialog(Skill skill) {
    String? selectedProficiency = 'Intermediate';
    int selectedYears = 1;

    Get.dialog(
      AlertDialog(
        title: Text('${skill.icon ?? '💼'} ${skill.name}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(Get.context!)!.proficiencyTitle,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].map((level) {
                    return ChoiceChip(
                      label: Text(_getProficiencyText(level)),
                      selected: selectedProficiency == level,
                      onSelected: (selected) {
                        setState(() => selectedProficiency = level);
                      },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: selectedProficiency == level ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
                Text(AppLocalizations.of(Get.context!)!.experienceYears, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: selectedYears.toDouble(),
                        min: 0,
                        max: 20,
                        divisions: 20,
                        label: selectedYears == 0
                            ? AppLocalizations.of(Get.context!)!.lessThanOneYear
                            : AppLocalizations.of(Get.context!)!.yearsCount(selectedYears.toString()),
                        onChanged: (value) {
                          setState(() => selectedYears = value.toInt());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        selectedYears == 0
                            ? AppLocalizations.of(Get.context!)!.lessThanOneYear
                            : AppLocalizations.of(Get.context!)!.yearsCount(selectedYears.toString()),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(Get.context!)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _addSkill(
                skill,
                selectedProficiency,
                selectedYears == 0 ? null : selectedYears,
              );
            },
            child: Text(AppLocalizations.of(Get.context!)!.confirm),
          ),
        ],
      ),
    );
  }

  String _getProficiencyText(String level) {
    switch (level) {
      case 'Beginner':
        return AppLocalizations.of(Get.context!)!.beginner;
      case 'Intermediate':
        return AppLocalizations.of(Get.context!)!.intermediate;
      case 'Advanced':
        return AppLocalizations.of(Get.context!)!.advanced;
      case 'Expert':
        return AppLocalizations.of(Get.context!)!.expert;
      default:
        return level;
    }
  }

  List<Skill> _getFilteredSkills() {
    List<Skill> allSkills = [];

    for (var category in _skillsByCategory) {
      // 如果选择了类别，只显示该类别
      if (_selectedCategory != null && category.category != _selectedCategory) {
        continue;
      }
      allSkills.addAll(category.skills);
    }

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      allSkills = allSkills.where((skill) {
        return skill.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            skill.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allSkills;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.0.w),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredSkills = _getFilteredSkills();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchSkills,
              prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // 类别筛选
        if (_searchQuery.isEmpty)
          SizedBox(
            height: 50.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _CategoryChip(
                  label: AppLocalizations.of(context)!.allCategories,
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                SizedBox(width: 8.w),
                ..._skillsByCategory.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _CategoryChip(
                      label: _getCategoryText(category.category),
                      isSelected: _selectedCategory == category.category,
                      onTap: () => setState(() => _selectedCategory = category.category),
                    ),
                  );
                }),
              ],
            ),
          ),

        SizedBox(height: 8.h),

        // 已选择的技能
        if (_selectedSkills.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selected,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${_selectedSkills.length}${widget.maxSelection > 0 ? ' / ${widget.maxSelection}' : ''}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: _selectedSkills.map((userSkill) {
                    return Chip(
                      avatar: Text(userSkill.icon ?? '💼'),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(userSkill.skillName),
                          if (userSkill.proficiencyLevel != null)
                            Text(
                              _getProficiencyText(userSkill.proficiencyLevel!),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.removeWhere((s) => s.skillId == userSkill.skillId);
                        });
                        widget.onChanged(_selectedSkills);
                      },
                      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                      side: BorderSide(color: AppColors.accent),
                    );
                  }).toList(),
                ),
                Divider(height: 24.h),
              ],
            ),
          ),

        // 技能列表
        Expanded(
          child: filteredSkills.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? AppLocalizations.of(context)!.noSkills
                        : AppLocalizations.of(context)!.noMatchingSkills,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: filteredSkills.map((skill) {
                        final isSelected = _selectedSkills.any((s) => s.skillId == skill.id);
                        return FilterChip(
                          avatar: Text(skill.icon ?? '💼'),
                          label: Text(skill.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleSkill(skill),
                          selectedColor: AppColors.accent.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.accent,
                          backgroundColor: AppColors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.accent : AppColors.border,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _getCategoryText(String category) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final categoryMap = {
      'Programming': l10n.categoryProgramming,
      'Design': l10n.categoryDesign,
      'Marketing': l10n.categoryMarketing,
      'Languages': l10n.categoryLanguage,
      'Data': l10n.categoryDataAnalysis,
      'Management': l10n.categoryProjectMgmt,
      'Other': l10n.categoryOther,
    };
    return categoryMap[category] ?? category;
  }
}

/// 类别筛选芯片
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
