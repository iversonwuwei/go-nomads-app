import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

/// 兴趣编辑页面
class EditInterestsPage extends StatefulWidget {
  final int accountId;

  const EditInterestsPage({super.key, required this.accountId});

  @override
  State<EditInterestsPage> createState() => _EditInterestsPageState();
}

class _EditInterestsPageState extends State<EditInterestsPage> {
  final _userProfileDao = UserProfileDao();
  final _customInterestController = TextEditingController();

  bool _loading = true;
  Set<String> _selectedInterests = {};
  String? _selectedCategory = '全部';

  final Map<String, List<String>> _categorizedInterests = {
    '旅行': [
      '旅行',
      '冒险',
      '背包旅行',
      '徒步',
      '露营',
      '公路旅行',
      '探索',
      '文化交流',
    ],
    '运动': [
      '健身',
      '瑜伽',
      '跑步',
      '游泳',
      '冲浪',
      '滑雪',
      '攀岩',
      '骑行',
      '潜水',
      '极限运动',
    ],
    '艺术': [
      '摄影',
      '绘画',
      '音乐',
      '舞蹈',
      '电影',
      '戏剧',
      '博物馆',
      '艺术展',
    ],
    '美食': [
      '美食',
      '烹饪',
      '街头小吃',
      '咖啡',
      '美酒',
      '素食',
      '甜点',
      '异国料理',
    ],
    '社交': [
      '交友',
      '聚会',
      '夜生活',
      '派对',
      'Meetup',
      '社区活动',
      '志愿服务',
    ],
    '学习': [
      '阅读',
      '写作',
      '语言学习',
      '编程',
      '历史',
      '哲学',
      '科学',
      '教育',
    ],
    '科技': [
      '科技',
      '创业',
      '创新',
      '数字游民',
      '远程工作',
      '区块链',
      'AI',
      'Web3',
    ],
    '生活': [
      '冥想',
      '正念',
      '可持续生活',
      '极简主义',
      '宠物',
      '园艺',
      '手工艺',
      '时尚',
      '健康生活',
      '环保',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  Future<void> _loadInterests() async {
    try {
      final interests = await _userProfileDao.getInterests(widget.accountId);
      if (mounted) {
        setState(() {
          _selectedInterests = interests.map((i) => i.interestName).toSet();
          _loading = false;
        });
      }
    } catch (e) {
      log('加载兴趣失败: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleInterest(String interestName) async {
    try {
      if (_selectedInterests.contains(interestName)) {
        // 移除兴趣
        await _userProfileDao.removeInterest(widget.accountId, interestName);
        setState(() {
          _selectedInterests.remove(interestName);
        });
        AppToast.success('已移除兴趣');
      } else {
        // 添加兴趣
        final interest = UserInterestDto(
          accountId: widget.accountId,
          interestName: interestName,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _userProfileDao.addInterest(interest);
        setState(() {
          _selectedInterests.add(interestName);
        });
        AppToast.success('已添加兴趣');
      }
    } catch (e) {
      log('操作兴趣失败: $e');
      AppToast.error('操作失败，请重试');
    }
  }

  Future<void> _addCustomInterest() async {
    final interestName = _customInterestController.text.trim();
    if (interestName.isEmpty) {
      AppToast.warning('请输入兴趣名称');
      return;
    }

    if (_selectedInterests.contains(interestName)) {
      AppToast.warning('该兴趣已存在');
      return;
    }

    try {
      final interest = UserInterestDto(
        accountId: widget.accountId,
        interestName: interestName,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.addInterest(interest);
      setState(() {
        _selectedInterests.add(interestName);
        _customInterestController.clear();
      });
      AppToast.success('已添加自定义兴趣');
    } catch (e) {
      log('添加自定义兴趣失败: $e');
      AppToast.error('添加失败，请重试');
    }
  }

  List<String> _getFilteredInterests() {
    if (_selectedCategory == '全部') {
      return _categorizedInterests.values
          .expand((interests) => interests)
          .toList();
    }
    return _categorizedInterests[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑兴趣'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 已选兴趣显示
                if (_selectedInterests.isNotEmpty)
                  Container(
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
                            Text(
                              '已选择 ${_selectedInterests.length} 项兴趣',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedInterests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                              onDeleted: () => _toggleInterest(interest),
                              backgroundColor: Colors.green.shade100,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // 自定义兴趣输入
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customInterestController,
                          decoration: const InputDecoration(
                            labelText: '添加自定义兴趣',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(FontAwesomeIcons.circlePlus),
                            hintText: '输入兴趣名称',
                          ),
                          onSubmitted: (_) => _addCustomInterest(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomInterest,
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
                    children:
                        ['全部', ..._categorizedInterests.keys].map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(),

                // 兴趣列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getFilteredInterests().map((interest) {
                        final isSelected =
                            _selectedInterests.contains(interest);
                        return FilterChip(
                          label: Text(interest),
                          selected: isSelected,
                          onSelected: (selected) => _toggleInterest(interest),
                          selectedColor: Colors.green.shade200,
                          checkmarkColor: Colors.green.shade700,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
