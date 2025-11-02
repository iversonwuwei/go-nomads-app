import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../models/skill_model.dart';
import '../services/skills_api_service.dart';

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
  final SkillsApiService _skillsService = SkillsApiService();
  
  List<SkillsByCategory> _skillsByCategory = [];
  List<UserSkill> _selectedSkills = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    
    try {
      final skillsByCategory = await _skillsService.getSkillsByCategory();
      setState(() {
        _skillsByCategory = skillsByCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载技能失败: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        Get.snackbar(
          '加载失败',
          '无法加载技能列表，请稍后重试',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
        Get.snackbar(
          '达到上限',
          '最多只能选择 ${widget.maxSelection} 个技能',
          snackPosition: SnackPosition.BOTTOM,
        );
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
                const Text('熟练度', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
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
                const SizedBox(height: 16),
                const Text('经验年限', style: TextStyle(fontWeight: FontWeight.bold)),
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
              prefixIcon: const Icon(Icons.search),
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
                      onTap: () => setState(() => _selectedCategory = category.category),
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
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.removeWhere((s) => s.skillId == userSkill.skillId);
                        });
                        widget.onChanged(_selectedSkills);
                      },
                      backgroundColor: AppColors.accent.withOpacity(0.1),
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
                        final isSelected = _selectedSkills.any((s) => s.skillId == skill.id);
                        return FilterChip(
                          avatar: Text(skill.icon ?? '💼'),
                          label: Text(skill.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleSkill(skill),
                          selectedColor: AppColors.accent.withOpacity(0.2),
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
