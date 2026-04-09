import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/interest/domain/entities/interest.dart';
import 'package:go_nomads_app/features/interest/presentation/controllers/interest_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

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
  late final InterestStateController _interestController;

  List<InterestsByCategory> _interestsByCategory = [];
  final List<UserInterest> _selectedInterests = [];
  List<Interest> _allInterests = [];
  bool _didRestoreInitialSelection = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _interestController = Get.find<InterestStateController>();
    _loadInterests();
  }

  @override
  void didUpdateWidget(covariant InterestsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!setEquals(widget.selectedInterestIds.toSet(),
        oldWidget.selectedInterestIds.toSet())) {
      _restoreSelectionFromWidget(force: true);
    }
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoading = true);

    try {
      await _interestController.getInterests();

      final interests = List<Interest>.from(_interestController.interests);
      if (!mounted) return;

      setState(() {
        _allInterests = interests;
        _interestsByCategory = _groupInterestsByCategory(interests);
        _isLoading = false;
      });

      _restoreSelectionFromWidget();

      final error = _interestController.errorMessage.value;
      if (error != null && error.isNotEmpty && mounted) {
        AppToast.error(error);
      }
    } catch (e) {
      debugPrint('❌ 加载兴趣失败: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error(AppLocalizations.of(Get.context!)!.cannotLoadInterests);
    }
  }

  void _toggleInterest(Interest interest) {
    final isSelected =
        _selectedInterests.any((i) => i.interestId == interest.id);

    if (isSelected) {
      // 取消选择
      setState(() {
        _selectedInterests.removeWhere((i) => i.interestId == interest.id);
      });
      widget.onChanged(_selectedInterests);
    } else {
      // 检查是否超过最大选择数
      if (widget.maxSelection > 0 &&
          _selectedInterests.length >= widget.maxSelection) {
        AppToast.error(AppLocalizations.of(Get.context!)!
            .maxInterestsReached(widget.maxSelection.toString()));
        return;
      }

      // 如果需要选择强度，显示对话框
      if (widget.showIntensity) {
        _showIntensityDialog(interest);
      } else {
        _addInterest(interest, null);
      }
    }
  }

  void _addInterest(Interest interest, String? intensity) {
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

  void _restoreSelectionFromWidget({bool force = false}) {
    if (_allInterests.isEmpty || widget.selectedInterestIds.isEmpty) {
      return;
    }

    if (!force && _didRestoreInitialSelection) {
      return;
    }

    final restored = _buildUserInterestsFromIds(widget.selectedInterestIds);
    if (restored.isEmpty) {
      _didRestoreInitialSelection = true;
      return;
    }

    setState(() {
      _selectedInterests
        ..clear()
        ..addAll(restored);
    });

    _didRestoreInitialSelection = true;
  }

  List<UserInterest> _buildUserInterestsFromIds(List<String> interestIds) {
    final now = DateTime.now();
    final results = <UserInterest>[];
    for (final id in interestIds) {
      final interest = _findInterestById(id);
      if (interest == null) continue;
      results.add(
        UserInterest(
          id: 'selected-$id-${now.millisecondsSinceEpoch}',
          userId: '',
          interestId: interest.id,
          interestName: interest.name,
          category: interest.category,
          icon: interest.icon,
          intensityLevel: null,
          createdAt: now,
        ),
      );
    }
    return results;
  }

  Interest? _findInterestById(String id) {
    for (final interest in _allInterests) {
      if (interest.id == id) {
        return interest;
      }
    }
    return null;
  }

  List<InterestsByCategory> _groupInterestsByCategory(
      List<Interest> interests) {
    final Map<String, List<Interest>> grouped = {};
    for (final interest in interests) {
      grouped.putIfAbsent(interest.category, () => []).add(interest);
    }

    final categories = grouped.entries
        .map((entry) => InterestsByCategory(
              category: entry.key,
              interests: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));

    return categories;
  }

  void _showIntensityDialog(Interest interest) {
    String? selectedIntensity = 'moderate';

    Get.bottomSheet(
      AppBottomDrawer(
        title: '${interest.icon ?? '❤️'} ${interest.name}',
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(Get.context!)!.interestLevelTitle,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: ['casual', 'moderate', 'passionate'].map((level) {
                    return ChoiceChip(
                      label: Text(_getIntensityText(level)),
                      selected: selectedIntensity == level,
                      onSelected: (selected) {
                        setState(() => selectedIntensity = level);
                      },
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: selectedIntensity == level
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        footer: AppBottomDrawerActionRow(
          secondaryLabel: AppLocalizations.of(Get.context!)!.cancel,
          onSecondaryPressed: () => Get.back<void>(),
          primaryLabel: AppLocalizations.of(Get.context!)!.confirm,
          onPrimaryPressed: () {
            Get.back<void>();
            _addInterest(interest, selectedIntensity);
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  String _getIntensityText(String level) {
    switch (level) {
      case 'casual':
      case 'low':
        return AppLocalizations.of(Get.context!)!.interestLevelCasual;
      case 'moderate':
      case 'medium':
        return AppLocalizations.of(Get.context!)!.interestLevelLike;
      case 'passionate':
      case 'high':
        return AppLocalizations.of(Get.context!)!.interestLevelPassionate;
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
        return interest.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            interest.category
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return allInterests;
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

    final filteredInterests = _getFilteredInterests();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchInterests,
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
                ..._interestsByCategory.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
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

        SizedBox(height: 8.h),

        // 已选择的兴趣
        if (_selectedInterests.isNotEmpty)
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
                      '${_selectedInterests.length}${widget.maxSelection > 0 ? ' / ${widget.maxSelection}' : ''}',
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
                                fontSize: 10.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
                      onDeleted: () {
                        setState(() {
                          _selectedInterests.removeWhere(
                              (i) => i.interestId == userInterest.interestId);
                        });
                        widget.onChanged(_selectedInterests);
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

        // 兴趣列表
        Expanded(
          child: filteredInterests.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? AppLocalizations.of(context)!.noInterests
                        : AppLocalizations.of(context)!.noMatchingInterests,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: filteredInterests.map((interest) {
                        final isSelected = _selectedInterests
                            .any((i) => i.interestId == interest.id);
                        return FilterChip(
                          avatar: Text(interest.icon ?? '❤️'),
                          label: Text(interest.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleInterest(interest),
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
    final l10n = AppLocalizations.of(Get.context!)!;
    final categoryMap = {
      'Sports': l10n.categoryFitness,
      'Arts': l10n.categoryArtCulture,
      'Food': l10n.categoryCooking,
      'Travel': l10n.categoryTravel,
      'Technology': l10n.categoryTech,
      'Reading': l10n.categoryReading,
      'Music': l10n.categoryMusic,
      'Social': l10n.categorySocial,
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
