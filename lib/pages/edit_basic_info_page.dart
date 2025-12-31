import 'package:df_admin_mobile/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/controllers/edit_basic_info_page_controller.dart';

/// 基本信息编辑页面
class EditBasicInfoPage extends StatelessWidget {
  final int accountId;

  const EditBasicInfoPage({super.key, required this.accountId});

  static String _generateTag(int accountId) => 'EditBasicInfoPage_$accountId';

  EditBasicInfoPageController _useController() {
    final tag = _generateTag(accountId);
    if (Get.isRegistered<EditBasicInfoPageController>(tag: tag)) {
      return Get.find<EditBasicInfoPageController>(tag: tag);
    }
    return Get.put(EditBasicInfoPageController(accountId: accountId), tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑基本信息'),
        actions: [
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final success = await controller.saveBasicInfo(formKey);
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    },
              child: controller.isSaving.value
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
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                Center(
                  child: Stack(
                    children: [
                      Obx(() => SafeCircleAvatar(
                            imageUrl: controller.avatarUrl.value,
                            radius: 60,
                            errorWidget: const Icon(FontAwesomeIcons.user, size: 60),
                          )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(FontAwesomeIcons.camera, size: 20, color: Colors.white),
                            onPressed: controller.uploadAvatar,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 姓名
                TextFormField(
                  controller: controller.nameController,
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
                  controller: controller.bioController,
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
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.gender.value,
                      decoration: const InputDecoration(
                        labelText: '性别',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.restroom),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('男')),
                        DropdownMenuItem(value: 'female', child: Text('女')),
                        DropdownMenuItem(value: 'other', child: Text('其他')),
                        DropdownMenuItem(value: 'prefer_not_to_say', child: Text('不愿透露')),
                      ],
                      onChanged: controller.updateGender,
                    )),

                const SizedBox(height: 16),

                // 当前城市
                TextFormField(
                  controller: controller.cityController,
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
                  controller: controller.countryController,
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
                  controller: controller.occupationController,
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
                  controller: controller.companyController,
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
                  controller: controller.websiteController,
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
        );
      }),
    );
  }
}
