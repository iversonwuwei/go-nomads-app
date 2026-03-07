import 'package:go_nomads_app/controllers/edit_interests_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// 兴趣编辑页面
class EditInterestsPage extends StatelessWidget {
  final int accountId;

  const EditInterestsPage({super.key, required this.accountId});

  String get _tag => 'edit_interests_$accountId';

  EditInterestsPageController get _controller {
    if (!Get.isRegistered<EditInterestsPageController>(tag: _tag)) {
      Get.put(EditInterestsPageController(accountId: accountId), tag: _tag);
    }
    return Get.find<EditInterestsPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editInterestsTitle),
      ),
      body: Obx(() => controller.loading.value
          ? const AppSceneLoading(scene: AppLoadingScene.tags, fullScreen: true)
          : Column(
              children: [
                // 已选兴趣显示
                Obx(() => controller.selectedInterests.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        color: Colors.green.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.heart, color: Colors.green),
                                SizedBox(width: 8.w),
                                Obx(() => Text(
                                  '已选择 ${controller.selectedInterests.length} 项兴趣',
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
                              children: controller.selectedInterests.map((interest) {
                                return Chip(
                                  label: Text(interest),
                                  deleteIcon: Icon(FontAwesomeIcons.xmark, size: 18.r),
                                  onDeleted: () => controller.toggleInterest(interest),
                                  backgroundColor: Colors.green.shade100,
                                );
                              }).toList(),
                            )),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                // 自定义兴趣输入
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.customInterestController,
                          decoration: InputDecoration(
                            labelText: l10n.editInterestsAddCustomInterest,
                            border: OutlineInputBorder(),
                            prefixIcon: const Icon(FontAwesomeIcons.circlePlus),
                            hintText: l10n.enterInterestName,
                          ),
                          onSubmitted: (_) => controller.addCustomInterest(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: controller.addCustomInterest,
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
                    children: ['全部', ...controller.categorizedInterests.keys].map((category) {
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

                // 兴趣列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Obx(() => Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: controller.getFilteredInterests().map((interest) {
                        return Obx(() {
                          final isSelected = controller.selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            onSelected: (selected) => controller.toggleInterest(interest),
                            selectedColor: Colors.green.shade200,
                            checkmarkColor: Colors.green.shade700,
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
