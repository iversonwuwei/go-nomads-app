import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/edit_basic_info_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editBasicInfoTitle),
        actions: [
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final success = await controller.saveBasicInfo(formKey);
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: controller.isSaving.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.save,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
            );
          }),
        ],
      ),
      body: Obx(() {
        return AppLoadingSwitcher(
          isLoading: controller.isLoading.value,
          loading: const EditFormSkeleton(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
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
                              errorWidget: Icon(FontAwesomeIcons.user, size: 60.r),
                            )),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 20,
                            child: IconButton(
                              icon: Icon(FontAwesomeIcons.camera, size: 20.r, color: Colors.white),
                              onPressed: controller.uploadAvatar,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // 姓名
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: '${l10n.name} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.enterYourName;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // 个人简介
                  TextFormField(
                    controller: controller.bioController,
                    decoration: InputDecoration(
                      labelText: l10n.bio,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.penToSquare),
                      hintText: l10n.tellUsAboutYourself,
                    ),
                    maxLines: 4,
                  ),

                  SizedBox(height: 16.h),

                  // 性别
                  Obx(() => DropdownButtonFormField<String>(
                        initialValue: controller.gender.value,
                        decoration: InputDecoration(
                          labelText: l10n.editBasicInfoGender,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(FontAwesomeIcons.restroom),
                        ),
                        items: [
                          DropdownMenuItem(value: 'male', child: Text(l10n.editBasicInfoGenderMale)),
                          DropdownMenuItem(value: 'female', child: Text(l10n.editBasicInfoGenderFemale)),
                          DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                          DropdownMenuItem(
                            value: 'prefer_not_to_say',
                            child: Text(l10n.editBasicInfoGenderPreferNotToSay),
                          ),
                        ],
                        onChanged: controller.updateGender,
                      )),

                  SizedBox(height: 16.h),

                  // 当前城市
                  TextFormField(
                    controller: controller.cityController,
                    decoration: InputDecoration(
                      labelText: l10n.editBasicInfoCurrentCity,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.city),
                      hintText: l10n.editBasicInfoCityHint,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 当前国家
                  TextFormField(
                    controller: controller.countryController,
                    decoration: InputDecoration(
                      labelText: l10n.editBasicInfoCurrentCountry,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.flag),
                      hintText: l10n.editBasicInfoCountryHint,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 职业
                  TextFormField(
                    controller: controller.occupationController,
                    decoration: InputDecoration(
                      labelText: l10n.editBasicInfoOccupation,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.briefcase),
                      hintText: l10n.editBasicInfoOccupationHint,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 公司
                  TextFormField(
                    controller: controller.companyController,
                    decoration: InputDecoration(
                      labelText: l10n.editBasicInfoCompany,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.building),
                      hintText: l10n.editBasicInfoCompanyHint,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 个人网站
                  TextFormField(
                    controller: controller.websiteController,
                    decoration: InputDecoration(
                      labelText: l10n.editBasicInfoWebsite,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(FontAwesomeIcons.globe),
                      hintText: l10n.editBasicInfoWebsiteHint,
                    ),
                    keyboardType: TextInputType.url,
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
