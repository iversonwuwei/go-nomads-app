import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

/// 基本信息编辑页面示例
class EditBasicInfoPage extends StatefulWidget {
  final int accountId;

  const EditBasicInfoPage({super.key, required this.accountId});

  @override
  State<EditBasicInfoPage> createState() => _EditBasicInfoPageState();
}

class _EditBasicInfoPageState extends State<EditBasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _userProfileDao = UserProfileDao();

  // 控制器
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _occupationController = TextEditingController();
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _avatarUrl;
  String? _gender;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadBasicInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _loadBasicInfo() async {
    try {
      final info = await _userProfileDao.getBasicInfo(widget.accountId);
      if (info != null && mounted) {
        setState(() {
          _nameController.text = info.name;
          _bioController.text = info.bio ?? '';
          _cityController.text = info.currentCity ?? '';
          _countryController.text = info.currentCountry ?? '';
          _occupationController.text = info.occupation ?? '';
          _companyController.text = info.company ?? '';
          _websiteController.text = info.website ?? '';
          _avatarUrl = info.avatarUrl;
          _gender = info.gender;
          _loading = false;
        });
      }
    } catch (e) {
      log('加载基本信息失败: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveBasicInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      final info = UserBasicInfoDto(
        accountId: widget.accountId,
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        avatarUrl: _avatarUrl,
        currentCity: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        currentCountry: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        gender: _gender,
        createdAt: now,
        updatedAt: now,
      );

      await _userProfileDao.saveBasicInfo(info);

      if (mounted) {
        AppToast.success('基本信息已保存', title: '成功');
        Navigator.pop(context, true);
      }
    } catch (e) {
      log('保存基本信息失败: $e');
      if (mounted) {
        AppToast.error('保存失败，请重试', title: '错误');
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑基本信息'),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _saving ? null : _saveBasicInfo,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _avatarUrl == null
                                ? const Icon(FontAwesomeIcons.user, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(FontAwesomeIcons.camera,
                                    size: 20, color: Colors.white),
                                onPressed: () {
                                  AppToast.info('头像上传功能开发中');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 姓名
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '姓名 *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.user),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入姓名';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 个人简介
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: '个人简介',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.penToSquare),
                        hintText: '介绍一下你自己...',
                      ),
                      maxLines: 4,
                    ),

                    const SizedBox(height: 16),

                    // 性别
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: '性别',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.restroom),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('男')),
                        DropdownMenuItem(value: 'female', child: Text('女')),
                        DropdownMenuItem(value: 'other', child: Text('其他')),
                        DropdownMenuItem(
                            value: 'prefer_not_to_say', child: Text('不愿透露')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 当前城市
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: '当前城市',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.city),
                        hintText: '例如: Bangkok',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 当前国家
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: '当前国家',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.flag),
                        hintText: '例如: Thailand',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 职业
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: '职业',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.briefcase),
                        hintText: '例如: Software Engineer',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 公司
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: '公司',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.building),
                        hintText: '例如: Google',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 个人网站
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: '个人网站',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.globe),
                        hintText: 'https://yourwebsite.com',
                      ),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
