import 'package:df_admin_mobile/controllers/edit_interests_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑兴趣'),
      ),
      body: Obx(() => controller.loading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 已选兴趣显示
                Obx(() => controller.selectedInterests.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.green.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.heart, color: Colors.green),
                                const SizedBox(width: 8),
                                Obx(() => Text(
                                  '已选择 ${controller.selectedInterests.length} 项兴趣',
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
                              children: controller.selectedInterests.map((interest) {
                                return Chip(
                                  label: Text(interest),
                                  deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.customInterestController,
                          decoration: const InputDecoration(
                            labelText: '添加自定义兴趣',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(FontAwesomeIcons.circlePlus),
                            hintText: '输入兴趣名称',
                          ),
                          onSubmitted: (_) => controller.addCustomInterest(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: controller.addCustomInterest,
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
                    children: ['全部', ...controller.categorizedInterests.keys].map((category) {
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

                // 兴趣列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
