import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/skill/domain/entities/skill.dart';
import 'package:df_admin_mobile/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

    if (!setEquals(
        widget.selectedSkillIds.toSet(), oldWidget.selectedSkillIds.toSet())) {
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
      if (widget.maxSelection > 0 &&
          _selectedSkills.length >= widget.maxSelection) {
        AppToast.error('最多只能选择 ${widget.maxSelection} 个技能');
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
                const Text('熟练度',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                      .map((level) {
                    return ChoiceChip(
                      label: Text(_getProficiencyText(level)),
                      selected: selectedProficiency == level,
                      onSelected: (selected) {
                        setState(() => selectedProficiency = level);
                      },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: selectedProficiency == level
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('经验年限',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: selectedYears.toDouble(),
                        min: 0,
                        max: 20,
                        divisions: 20,
                        label: selectedYears == 0 ? '少于1年' : '$selectedYears 年',
                        onChanged: (value) {
                          setState(() => selectedYears = value.toInt());
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        selectedYears == 0 ? '< 1年' : '$selectedYears 年',
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
            child: const Text('取消'),
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
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getProficiencyText(String level) {
    switch (level) {
      case 'Beginner':
        return '初学者';
      case 'Intermediate':
        return '中级';
      case 'Advanced':
        return '高级';
      case 'Expert':
        return '专家';
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
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
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索技能...',
              prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: '全部',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ..._skillsByCategory.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: _getCategoryText(category.category),
                      isSelected: _selectedCategory == category.category,
                      onTap: () =>
                          setState(() => _selectedCategory = category.category),
                    ),
                  );
                }),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // 已选择的技能
        if (_selectedSkills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '已选择',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedSkills.length}${widget.maxSelection > 0 ? ' / ${widget.maxSelection}' : ''}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.removeWhere(
                              (s) => s.skillId == userSkill.skillId);
                        });
                        widget.onChanged(_selectedSkills);
                      },
                      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                      side: BorderSide(color: AppColors.accent),
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
              ],
            ),
          ),

        // 技能列表
        Expanded(
          child: filteredSkills.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? '暂无技能' : '未找到匹配的技能',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredSkills.map((skill) {
                        final isSelected =
                            _selectedSkills.any((s) => s.skillId == skill.id);
                        return FilterChip(
                          avatar: Text(skill.icon ?? '💼'),
                          label: Text(skill.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleSkill(skill),
                          selectedColor:
                              AppColors.accent.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.accent,
                          backgroundColor: AppColors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
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
    const categoryMap = {
      'Programming': '编程开发',
      'Design': '设计创意',
      'Marketing': '营销商务',
      'Languages': '语言能力',
      'Data': '数据分析',
      'Management': '项目管理',
      'Other': '其他技能',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(20),
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
