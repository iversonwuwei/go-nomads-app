import 'package:df_admin_mobile/controllers/skills_interests_page_controller.dart';
import 'package:df_admin_mobile/widgets/interests_selector.dart';
import 'package:df_admin_mobile/widgets/skills_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择技能与兴趣'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '技能', icon: Icon(FontAwesomeIcons.briefcase)),
            Tab(text: '兴趣', icon: Icon(FontAwesomeIcons.heart)),
          ],
        ),
        actions: [
          Obx(() {
            if (!_controller.hasSelection) return const SizedBox.shrink();
            return TextButton(
              onPressed: _controller.isSaving.value ? null : _controller.saveSkillsAndInterests,
              child: _controller.isSaving.value
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
            );
          }),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 技能选择器
          Obx(() => SkillsSelector(
                selectedSkillIds: _controller.selectedSkillIds,
                onChanged: _controller.updateSelectedSkills,
                showProficiency: true,
                maxSelection: 10, // 最多选择10个技能
              )),

          // 兴趣选择器
          Obx(() => InterestsSelector(
                selectedInterestIds: _controller.selectedInterestIds,
                onChanged: _controller.updateSelectedInterests,
                showIntensity: true,
                maxSelection: 15, // 最多选择15个兴趣
              )),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() => Row(
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
                        '技能 ${_controller.selectedSkills.length}/10  ·  兴趣 ${_controller.selectedInterests.length}/15',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: !_controller.hasSelection || _controller.isSaving.value
                        ? null
                        : _controller.saveSkillsAndInterests,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: _controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('保存'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
