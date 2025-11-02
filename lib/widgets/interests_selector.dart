import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../models/interest_model.dart';
import '../services/interests_api_service.dart';

/// 兴趣爱好选择器组件
class InterestsSelector extends StatefulWidget {
  /// 已选择的兴趣ID列表
  final List<String> selectedInterestIds;
  
  /// 选择变化回调
  final Function(List<UserInterest>) onChanged;
  
  /// 是否显示强度选择
  final bool showIntensity;
  
  /// 最大选择数量（0表示无限制）
  final int maxSelection;

  const InterestsSelector({
    super.key,
    required this.selectedInterestIds,
    required this.onChanged,
    this.showIntensity = true,
    this.maxSelection = 0,
  });

  @override
  State<InterestsSelector> createState() => _InterestsSelectorState();
}

class _InterestsSelectorState extends State<InterestsSelector> {
  final InterestsApiService _interestsService = InterestsApiService();
  
  List<InterestsByCategory> _interestsByCategory = [];
  List<UserInterest> _selectedInterests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoading = true);
    
    try {
      final interestsByCategory = await _interestsService.getInterestsByCategory();
      setState(() {
        _interestsByCategory = interestsByCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载兴趣失败: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        Get.snackbar(
          '加载失败',
          '无法加载兴趣列表，请稍后重试',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _toggleInterest(Interest interest) {
    final isSelected = _selectedInterests.any((i) => i.interestId == interest.id);
    
    if (isSelected) {
      // 取消选择
      setState(() {
        _selectedInterests.removeWhere((i) => i.interestId == interest.id);
      });
      widget.onChanged(_selectedInterests);
    } else {
      // 检查是否超过最大选择数
      if (widget.maxSelection > 0 && _selectedInterests.length >= widget.maxSelection) {
        Get.snackbar(
          '达到上限',
          '最多只能选择 ${widget.maxSelection} 个兴趣',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // 如果需要选择强度，显示对话框
      if (widget.showIntensity) {
        _showIntensityDialog(interest);
      } else {
        _addInterest(interest, null, null);
      }
    }
  }

  void _addInterest(Interest interest, String? intensity, String? _) {
    final userInterest = UserInterest(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 临时ID
      userId: '', // 将由后端填充
      interestId: interest.id,
      interestName: interest.name,
      category: interest.category,
      icon: interest.icon,
      intensityLevel: intensity,
      createdAt: DateTime.now(),
    );
    
    setState(() {
      _selectedInterests.add(userInterest);
    });
    widget.onChanged(_selectedInterests);
  }

  void _showIntensityDialog(Interest interest) {
    String? selectedIntensity = 'Medium';

    Get.dialog(
      AlertDialog(
        title: Text('${interest.icon ?? '❤️'} ${interest.name}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('喜爱程度', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Low', 'Medium', 'High'].map((level) {
                    return ChoiceChip(
                      label: Text(_getIntensityText(level)),
                      selected: selectedIntensity == level,
                      onSelected: (selected) {
                        setState(() => selectedIntensity = level);
                      },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: selectedIntensity == level ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
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
              _addInterest(interest, selectedIntensity, null);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getIntensityText(String level) {
    switch (level) {
      case 'Low':
        return '一般';
      case 'Medium':
        return '喜欢';
      case 'High':
        return '热爱';
      default:
        return level;
    }
  }

  List<Interest> _getFilteredInterests() {
    List<Interest> allInterests = [];
    
    for (var category in _interestsByCategory) {
      // 如果选择了类别，只显示该类别
      if (_selectedCategory != null && category.category != _selectedCategory) {
        continue;
      }
      allInterests.addAll(category.interests);
    }
    
    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      allInterests = allInterests.where((interest) {
        return interest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               interest.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return allInterests;
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

    final filteredInterests = _getFilteredInterests();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索兴趣爱好...',
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
                ..._interestsByCategory.map((category) {
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

        // 已选择的兴趣
        if (_selectedInterests.isNotEmpty)
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
                      '${_selectedInterests.length}${widget.maxSelection > 0 ? ' / ${widget.maxSelection}' : ''}',
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
                  children: _selectedInterests.map((userInterest) {
                    return Chip(
                      avatar: Text(userInterest.icon ?? '❤️'),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(userInterest.interestName),
                          if (userInterest.intensityLevel != null)
                            Text(
                              _getIntensityText(userInterest.intensityLevel!),
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
                          _selectedInterests.removeWhere((i) => i.interestId == userInterest.interestId);
                        });
                        widget.onChanged(_selectedInterests);
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

        // 兴趣列表
        Expanded(
          child: filteredInterests.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? '暂无兴趣' : '未找到匹配的兴趣',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredInterests.map((interest) {
                        final isSelected = _selectedInterests.any((i) => i.interestId == interest.id);
                        return FilterChip(
                          avatar: Text(interest.icon ?? '❤️'),
                          label: Text(interest.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleInterest(interest),
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
      'Sports': '运动健身',
      'Arts': '艺术文化',
      'Food': '美食烹饪',
      'Travel': '旅行探险',
      'Technology': '科技数码',
      'Reading': '阅读学习',
      'Music': '音乐娱乐',
      'Social': '社交公益',
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
