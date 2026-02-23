import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';

/// 搜索结果列表（覆盖在地图上方）
/// Search results overlay list with pagination support
class MapPickerSearchResults extends GetView<MapPickerController> {
  const MapPickerSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = controller.searchResults;
      if (results.isEmpty) return const SizedBox.shrink();

      return Positioned(
        left: 16,
        right: 16,
        top: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              controller: controller.searchScrollController,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount:
                  results.length + (controller.hasMoreResults.value ? 1 : 0),
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, index) {
                // 加载更多指示器
                if (index >= results.length) {
                  return const _LoadMoreIndicator();
                }

                final result = results[index];
                return _SearchResultTile(
                  result: result,
                  onTap: () => controller.selectSearchResult(result),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

/// 单条搜索结果
class _SearchResultTile extends StatelessWidget {
  final MapPickerSearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.locationDot,
                size: 16,
                color: Color(0xFFFF4458),
              ),
            ),
            const SizedBox(width: 12),
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (result.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

/// 加载更多指示器
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            '加载更多... / Loading more...',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
