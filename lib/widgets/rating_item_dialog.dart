import 'package:df_admin_mobile/features/city/domain/entities/city_rating_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rating_icon_catalog.dart';

/// Shows a dialog allowing the user to enter/update a rating item label,
/// score, and icon. Returns a [CityRatingItem] when confirmed.
Future<CityRatingItem?> showRatingItemDialog({
  required BuildContext context,
  required String Function() idBuilder,
  CityRatingItem? initial,
}) {
  final textController = TextEditingController(text: initial?.label ?? '');
  double scoreValue = initial?.score ?? 4.0;
  IconData selectedIcon = initial?.getIcon() ?? RatingIconCatalog.icons.first;
  String? errorText;

  return Get.dialog<CityRatingItem>(
    Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: StatefulBuilder(
        builder: (context, setState) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    initial == null ? '添加评分项' : '编辑评分项',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: '评分项名称',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '评分值: ${scoreValue.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: scoreValue,
                    min: 0,
                    max: 5,
                    divisions: 50,
                    label: scoreValue.toStringAsFixed(1),
                    activeColor: const Color(0xFFFF4458),
                    onChanged: (value) {
                      setState(() => scoreValue = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '选择图标',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: RatingIconCatalog.icons.map((iconData) {
                      final isSelected = iconData == selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = iconData),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF4458)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF4458)
                                  : Colors.grey.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final label = textController.text.trim();
                            if (label.isEmpty) {
                              setState(() => errorText = '请输入评分项名称');
                              return;
                            }

                            final newItem = CityRatingItem.fromIcon(
                              id: initial?.id ?? idBuilder(),
                              label: label,
                              icon: selectedIcon,
                              score: scoreValue,
                              isDefault: initial?.isDefault ?? false,
                            );
                            Get.back(result: newItem);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4458),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('提交'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
