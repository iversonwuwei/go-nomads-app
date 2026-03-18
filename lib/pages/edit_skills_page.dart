import 'package:go_nomads_app/controllers/edit_skills_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSkillsTitle),
      ),
      body: Obx(() => controller.loading.value
          ? const AppSceneLoading(scene: AppLoadingScene.tags, fullScreen: true)
          : Column(
              children: [
                // 已选技能显示
                Obx(() => controller.selectedSkills.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.circleCheck, color: Colors.blue),
                                SizedBox(width: 8.w),
                                Obx(() => Text(
                                  '已选择 ${controller.selectedSkills.length} 项技能',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Obx(() => Wrap(
                              spacing: 8.w,
                              runSpacing: 8.w,
                              children: controller.selectedSkills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
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
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.customSkillController,
                          decoration: InputDecoration(
                            labelText: l10n.editSkillsAddCustomSkill,
                            border: OutlineInputBorder(),
                            prefixIcon: const Icon(FontAwesomeIcons.circlePlus),
                            hintText: l10n.enterSkillName,
                          ),
                          onSubmitted: (_) => controller.addCustomSkill(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: controller.addCustomSkill,
                        child: Text(l10n.add),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // 分类选择
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['全部', ...controller.categorizedSkills.keys].map((category) {
                      return Obx(() {
                        final isSelected = controller.selectedCategory.value == category;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                    padding: EdgeInsets.all(16.w),
                    child: Obx(() => Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
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
