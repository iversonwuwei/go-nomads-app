import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/pages/register/widgets/register_feature_highlights.dart';
import 'package:go_nomads_app/pages/register/widgets/register_form.dart';
import 'package:go_nomads_app/pages/register/widgets/register_header.dart';
import 'package:go_nomads_app/pages/register/widgets/register_login_link.dart';
import 'package:go_nomads_app/pages/register/widgets/register_submit_button.dart';
import 'package:go_nomads_app/pages/register/widgets/register_terms_checkbox.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';
import 'package:go_nomads_app/widgets/legal_links_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 注册页面 - 使用响应式验证，无需 GlobalKey
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final Future<RegisterEntryCopyBundle> _entryCopyFuture;

  @override
  void initState() {
    super.initState();
    _entryCopyFuture = AppConfigService().getRegisterEntryCopyBundle().then((bundle) {
      Get.find<RegisterController>().applyFeedbackCopy(bundle.feedback);
      return bundle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RegisterEntryCopyBundle>(
      future: _entryCopyFuture,
      builder: (context, snapshot) {
        final entryCopy = snapshot.data;
        final marketingCopy = entryCopy?.marketing;
        final formCopy = entryCopy?.form;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: RegisterConstants.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),
                    RegisterHeader(copy: marketingCopy),
                    SizedBox(height: 48.h),
                    RegisterForm(copy: formCopy),
                    SizedBox(height: 24.h),
                    const RegisterTermsCheckbox(),
                    SizedBox(height: 32.h),
                    RegisterSubmitButton(copy: formCopy),
                    SizedBox(height: 32.h),
                    RegisterLoginLink(copy: marketingCopy),
                    SizedBox(height: 24.h),
                    RegisterFeatureHighlights(copy: marketingCopy),
                    SizedBox(height: 24.h),
                    const LegalLinksWidget(),
                    SizedBox(height: 8.h),
                    const CopyrightWidget(),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
