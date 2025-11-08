import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/interest/domain/entities/interest.dart';
import '../features/interest/presentation/controllers/interest_state_controller.dart';
import '../features/skill/domain/entities/skill.dart';
import '../features/skill/presentation/controllers/skill_state_controller.dart';
import '../features/user/presentation/controllers/user_state_controller.dart';
import '../widgets/interests_selector.dart';
import '../widgets/skills_selector.dart';

/// 技能和兴趣选择页面
/// 用于用户注册流程或个人资料编辑
class SkillsInterestsPage extends StatefulWidget {
  const SkillsInterestsPage({super.key});

  @override
  State<SkillsInterestsPage> createState() => _SkillsInterestsPageState();
}

class _SkillsInterestsPageState extends State<SkillsInterestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final SkillStateController _skillController;
  late final InterestStateController _interestController;
  late final UserStateController _userStateController;

  List<UserSkill> _selectedSkills = [];
  List<UserInterest> _selectedInterests = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _skillController = Get.find<SkillStateController>();
    _interestController = Get.find<InterestStateController>();
    _userStateController = Get.find<UserStateController>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveSkillsAndInterests() async {
    final currentUser = _userStateController.currentUser.value;

    if (currentUser == null) {
      Get.snackbar(
        '提示',
        '请先登录以保存您的技能和兴趣',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_selectedSkills.isEmpty && _selectedInterests.isEmpty) {
      Get.snackbar(
        '提示',
        '请至少选择一个技能或兴趣',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      var skillSuccessCount = 0;
      var interestSuccessCount = 0;

      // 保存技能
      if (_selectedSkills.isNotEmpty) {
        for (final skill in _selectedSkills) {
          final success = await _skillController.addUserSkill(
            currentUser.id,
            AddUserSkillRequest(
              skillId: skill.skillId,
              proficiencyLevel: skill.proficiencyLevel,
              yearsOfExperience: skill.yearsOfExperience,
            ),
          );
          if (success) {
            skillSuccessCount++;
          }
        }
      }

      // 保存兴趣
      if (_selectedInterests.isNotEmpty) {
        for (final interest in _selectedInterests) {
          final success = await _interestController.addUserInterest(
            currentUser.id,
            AddUserInterestRequest(
              interestId: interest.interestId,
              intensityLevel: interest.intensityLevel,
            ),
          );
          if (success) {
            interestSuccessCount++;
          }
        }
      }

      final hasSkillFailure = skillSuccessCount != _selectedSkills.length &&
          _selectedSkills.isNotEmpty;
      final hasInterestFailure =
          interestSuccessCount != _selectedInterests.length &&
              _selectedInterests.isNotEmpty;

      if (!hasSkillFailure && !hasInterestFailure) {
        Get.snackbar(
          '保存成功',
          '已保存 ${skillSuccessCount} 个技能和 ${interestSuccessCount} 个兴趣',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // 返回上一页
        Get.back();
      } else {
        final failureMessages = <String>[];
        if (hasSkillFailure) {
          failureMessages.add(
              '技能保存失败 ${_selectedSkills.length - skillSuccessCount}/${_selectedSkills.length}');
        }
        if (hasInterestFailure) {
          failureMessages.add(
              '兴趣保存失败 ${_selectedInterests.length - interestSuccessCount}/${_selectedInterests.length}');
        }

        Get.snackbar(
          '部分保存失败',
          failureMessages.join(' · '),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ 保存失败: $e');
      Get.snackbar(
        '保存失败',
        '无法保存您的选择，请稍后重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择技能与兴趣'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '技能', icon: Icon(Icons.work_outline)),
            Tab(text: '兴趣', icon: Icon(Icons.favorite_outline)),
          ],
        ),
        actions: [
          if (_selectedSkills.isNotEmpty || _selectedInterests.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _saveSkillsAndInterests,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 技能选择器
          SkillsSelector(
            selectedSkillIds: _selectedSkills.map((s) => s.skillId).toList(),
            onChanged: (skills) {
              setState(() => _selectedSkills = skills);
            },
            showProficiency: true,
            maxSelection: 10, // 最多选择10个技能
          ),

          // 兴趣选择器
          InterestsSelector(
            selectedInterestIds:
                _selectedInterests.map((i) => i.interestId).toList(),
            onChanged: (interests) {
              setState(() => _selectedInterests = interests);
            },
            showIntensity: true,
            maxSelection: 15, // 最多选择15个兴趣
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '技能 ${_selectedSkills.length}/10  ·  兴趣 ${_selectedInterests.length}/15',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed:
                    (_selectedSkills.isEmpty && _selectedInterests.isEmpty) ||
                            _isSaving
                        ? null
                        : _saveSkillsAndInterests,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
