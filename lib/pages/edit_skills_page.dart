import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

/// 技能编辑页面
class EditSkillsPage extends StatefulWidget {
  final int accountId;

  const EditSkillsPage({super.key, required this.accountId});

  @override
  State<EditSkillsPage> createState() => _EditSkillsPageState();
}

class _EditSkillsPageState extends State<EditSkillsPage> {
  final _userProfileDao = UserProfileDao();
  final _customSkillController = TextEditingController();

  bool _loading = true;
  Set<String> _selectedSkills = {};
  String? _selectedCategory = '全部';

  final Map<String, List<String>> _categorizedSkills = {
    '技术': [
      'Web开发',
      '移动开发',
      'UI/UX设计',
      '数据科学',
      '机器学习',
      'DevOps',
      '云计算',
      '区块链',
      '前端开发',
      '后端开发',
      'Full Stack',
      '数据库',
    ],
    '商业': [
      '市场营销',
      '产品管理',
      '项目管理',
      '销售',
      '商业分析',
      '创业',
      '咨询',
      '财务',
    ],
    '创意': [
      '平面设计',
      '内容创作',
      '视频制作',
      '摄影',
      '写作',
      '插画',
      '动画',
      '音乐制作',
    ],
    '其他': [
      '教学',
      '翻译',
      '客户服务',
      '人力资源',
      '法律',
      '医疗',
      '研究',
      '运营',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    _customSkillController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await _userProfileDao.getSkills(widget.accountId);
      if (mounted) {
        setState(() {
          _selectedSkills = skills.map((s) => s.skillName).toSet();
          _loading = false;
        });
      }
    } catch (e) {
      print('加载技能失败: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleSkill(String skillName) async {
    try {
      if (_selectedSkills.contains(skillName)) {
        // 移除技能
        await _userProfileDao.removeSkill(widget.accountId, skillName);
        setState(() {
          _selectedSkills.remove(skillName);
        });
        AppToast.success('已移除技能');
      } else {
        // 添加技能
        final skill = UserSkillDto(
          accountId: widget.accountId,
          skillName: skillName,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _userProfileDao.addSkill(skill);
        setState(() {
          _selectedSkills.add(skillName);
        });
        AppToast.success('已添加技能');
      }
    } catch (e) {
      print('操作技能失败: $e');
      AppToast.error('操作失败，请重试');
    }
  }

  Future<void> _addCustomSkill() async {
    final skillName = _customSkillController.text.trim();
    if (skillName.isEmpty) {
      AppToast.warning('请输入技能名称');
      return;
    }

    if (_selectedSkills.contains(skillName)) {
      AppToast.warning('该技能已存在');
      return;
    }

    try {
      final skill = UserSkillDto(
        accountId: widget.accountId,
        skillName: skillName,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.addSkill(skill);
      setState(() {
        _selectedSkills.add(skillName);
        _customSkillController.clear();
      });
      AppToast.success('已添加自定义技能');
    } catch (e) {
      print('添加自定义技能失败: $e');
      AppToast.error('添加失败，请重试');
    }
  }

  List<String> _getFilteredSkills() {
    if (_selectedCategory == '全部') {
      return _categorizedSkills.values.expand((skills) => skills).toList();
    }
    return _categorizedSkills[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑技能'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 已选技能显示
                if (_selectedSkills.isNotEmpty)
                  Container(
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
                            Text(
                              '已选择 ${_selectedSkills.length} 项技能',
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
                          children: _selectedSkills.map((skill) {
                            return Chip(
                              label: Text(skill),
                              deleteIcon: const Icon(FontAwesomeIcons.xmark, size: 18),
                              onDeleted: () => _toggleSkill(skill),
                              backgroundColor: Colors.blue.shade100,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // 自定义技能输入
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customSkillController,
                          decoration: const InputDecoration(
                            labelText: '添加自定义技能',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(FontAwesomeIcons.circlePlus),
                            hintText: '输入技能名称',
                          ),
                          onSubmitted: (_) => _addCustomSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomSkill,
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
                        ['全部', ..._categorizedSkills.keys].map((category) {
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

                // 技能列表
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getFilteredSkills().map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) => _toggleSkill(skill),
                          selectedColor: Colors.blue.shade200,
                          checkmarkColor: Colors.blue.shade700,
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
