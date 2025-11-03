import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../models/skill_model.dart';
import '../services/skills_api_service.dart';

/// 底部抽屉：技能选择器
class SkillsBottomSheet extends StatefulWidget {
  /// 已选择的技能ID列表
  final List<String> selectedSkillIds;
  
  /// 选择变化回调
  final Function(List<UserSkill>) onChanged;
  
  /// 是否显示熟练度选择
  final bool showProficiency;

  const SkillsBottomSheet({
    super.key,
    required this.selectedSkillIds,
    required this.onChanged,
    this.showProficiency = false,
  });

  @override
  State<SkillsBottomSheet> createState() => _SkillsBottomSheetState();
}

class _SkillsBottomSheetState extends State<SkillsBottomSheet> {
  final SkillsApiService _skillsService = SkillsApiService();
  
  List<SkillsByCategory> _skillsByCategory = [];
  final List<UserSkill> _selectedSkills = [];
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
    } else {
      // 直接添加，不需要熟练度对话框（简化版）
      _addSkill(skill, null, null);
    }
  }

  void _addSkill(Skill skill, String? proficiency, int? yearsOfExperience) {
    final userSkill = UserSkill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '',
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
  }

  List<Skill> _getFilteredSkills() {
    List<Skill> allSkills = [];
    
    for (var category in _skillsByCategory) {
      if (_selectedCategory != null && category.category != _selectedCategory) {
        continue;
      }
      allSkills.addAll(category.skills);
    }
    
    if (_searchQuery.isNotEmpty) {
      allSkills = allSkills.where((skill) {
        return skill.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               skill.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return allSkills;
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

  @override
  Widget build(BuildContext context) {
    final filteredSkills = _getFilteredSkills();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动指示器和标题
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '选择技能',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onChanged(_selectedSkills);
                          Get.back();
                        },
                        child: Text(
                          '完成 (${_selectedSkills.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: Column(
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
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              const SizedBox(height: 80), // 底部留白
                            ],
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
