import 'package:go_nomads_app/controllers/edit_skills_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 技能编辑页面
class EditSkillsPage extends StatelessWidget {
  final int accountId;

  const EditSkillsPage({super.key, required this.accountId});

  String get _tag => 'edit_skills_$accountId';

  EditSkillsPageController get _controller {
    if (!Get.isRegistered<EditSkillsPageController>(tag: _tag)) {
      Get.put(EditSkillsPageController(accountId: accountId), tag: _tag);
    }
    return Get.find<EditSkillsPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑技能'),
      ),
      body: Obx(() => controller.loading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 已选技能显示
                Obx(() => controller.selectedSkills.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.circleCheck, color: Colors.blue),
                                const SizedBox(width: 8),
                                Obx(() => Text(
                                  '已选择 ${controller.selectedSkills.length} 项技能',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.selectedSkills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                                  onDeleted: () => controller.toggleSkill(skill),
                                  backgroundColor: Colors.blue.shade100,
                                );
                              }).toList(),
                            )),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                // 自定义技能输入
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.customSkillController,
                          decoration: const InputDecoration(
                            labelText: '添加自定义技能',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(FontAwesomeIcons.circlePlus),
                            hintText: '输入技能名称',
                          ),
                          onSubmitted: (_) => controller.addCustomSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.addCustomSkill,
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // 分类选择
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['全部', ...controller.categorizedSkills.keys].map((category) {
                      return Obx(() {
                        final isSelected = controller.selectedCategory.value == category;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) => controller.setCategory(category),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),

                const Divider(),

                // 技能列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.getFilteredSkills().map((skill) {
                        return Obx(() {
                          final isSelected = controller.selectedSkills.contains(skill);
                          return FilterChip(
                            label: Text(skill),
                            selected: isSelected,
                            onSelected: (selected) => controller.toggleSkill(skill),
                            selectedColor: Colors.blue.shade200,
                            checkmarkColor: Colors.blue.shade700,
                          );
                        });
                      }).toList(),
                    )),
                  ),
                ),
              ],
            )),
    );
  }
}
