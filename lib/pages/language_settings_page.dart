import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        centerTitle: true,
      ),
      body: Obx(() => ListView(
            children: [
              _buildLanguageTile(
                context: context,
                title: '简体中文',
                subtitle: 'Simplified Chinese',
                languageCode: 'zh',
                isSelected: localeController.locale.value.languageCode == 'zh',
                onTap: () {
                  localeController.changeLocale('zh');
                  AppToast.success(
                    '当前语言：简体中文',
                    title: '语言已切换',
                  );
                },
              ),
              const Divider(height: 1),
              _buildLanguageTile(
                context: context,
                title: 'English',
                subtitle: 'English',
                languageCode: 'en',
                isSelected: localeController.locale.value.languageCode == 'en',
                onTap: () {
                  localeController.changeLocale('en');
                  AppToast.success(
                    'Current Language: English',
                    title: 'Language Changed',
                  );
                },
              ),
            ],
          )),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.language,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            )
          : Icon(
              Icons.circle_outlined,
              color: Colors.grey[400],
              size: 24.sp,
            ),
      onTap: onTap,
    );
  }
}
