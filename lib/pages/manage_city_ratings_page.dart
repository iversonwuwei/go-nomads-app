import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/city/domain/entities/city_rating_item.dart';
import '../widgets/rating_item_dialog.dart';

class ManageCityRatingsPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final List<CityRatingItem> initialRatings;

  const ManageCityRatingsPage({
    super.key,
    required this.cityId,
    required this.cityName,
    required this.initialRatings,
  });

  @override
  State<ManageCityRatingsPage> createState() => _ManageCityRatingsPageState();
}

class _ManageCityRatingsPageState extends State<ManageCityRatingsPage> {
  late List<CityRatingItem> _customRatings;

  @override
  void initState() {
    super.initState();
    _customRatings = List<CityRatingItem>.from(widget.initialRatings);
  }

  String _generateRatingId() {
    return 'rating_${DateTime.now().millisecondsSinceEpoch}_${_customRatings.length}';
  }

  Future<void> _addRating() async {
    final result = await showRatingItemDialog(
      context: context,
      idBuilder: _generateRatingId,
    );
    if (result != null) {
      setState(() => _customRatings.add(result));
    }
  }

  Future<void> _editRating(CityRatingItem item) async {
    final updated = await showRatingItemDialog(
      context: context,
      initial: item,
      idBuilder: () => item.id,
    );
    if (updated != null) {
      final index =
          _customRatings.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        setState(() => _customRatings[index] = updated);
      }
    }
  }

  Future<void> _deleteRating(CityRatingItem item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除评分项'),
        content: Text('确定要删除"${item.label}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(
          () => _customRatings.removeWhere((element) => element.id == item.id));
    }
  }

  void _finish() {
    Get.back(result: _customRatings);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finish();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.cityName} - 评分数据'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _finish,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '添加评分项',
              onPressed: _addRating,
            ),
          ],
        ),
        body: _customRatings.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = _customRatings[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFFF4458).withValues(alpha: 0.1),
                        child: Icon(item.icon, color: const Color(0xFFFF4458)),
                      ),
                      title: Text(item.label),
                      subtitle: Text('评分: ${item.score.toStringAsFixed(1)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: '编辑',
                            onPressed: () => _editRating(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: '删除',
                            onPressed: () => _deleteRating(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _customRatings.length,
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rate,
                size: 72, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              '暂无自定义评分项',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击下方按钮，添加第一个评分项，让城市信息更加丰富',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addRating,
              icon: const Icon(Icons.add),
              label: const Text('添加评分项'),
            ),
          ],
        ),
      ),
    );
  }
}
