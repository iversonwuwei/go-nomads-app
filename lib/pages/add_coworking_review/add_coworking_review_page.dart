import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_coworking_review/bottom_submit_bar.dart';
import 'package:df_admin_mobile/pages/add_coworking_review/form_section.dart';
import 'package:df_admin_mobile/pages/add_coworking_review/photos_section.dart';
import 'package:df_admin_mobile/pages/add_coworking_review/rating_section.dart';
import 'package:df_admin_mobile/controllers/add_coworking_review_page_controller.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 添加 Coworking Review 页面
class AddCoworkingReviewPage extends StatelessWidget {
  final String coworkingId;
  final String coworkingName;

  const AddCoworkingReviewPage({
    super.key,
    required this.coworkingId,
    required this.coworkingName,
  });

  String get _tag => 'add_coworking_review_$coworkingId';

  @override
  Widget build(BuildContext context) {
    // 注册 Controller
    final controller = Get.put(
      AddCoworkingReviewPageController(
        coworkingId: coworkingId,
        coworkingName: coworkingName,
      ),
      tag: _tag,
    );

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<AddCoworkingReviewPageController>(tag: _tag);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.xmark, color: AppColors.textPrimary, size: 24.sp),
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.writeAReview,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                coworkingName,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              // Rating Section
              RatingSection(controllerTag: _tag),
              SizedBox(height: 32.h),

              // Form Section (Date, Title, Content)
              FormSection(controllerTag: _tag),
              SizedBox(height: 24.h),

              // Photos Section
              PhotosSection(controllerTag: _tag),
              SizedBox(height: 32.h),

              // Guidelines
              const GuidelinesSection(),
              SizedBox(height: 96.h),
            ],
          ),
        ),
        bottomNavigationBar: BottomSubmitBar(
          controllerTag: _tag,
          onSubmit: () => _handleSubmit(context, controller, l10n),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    AddCoworkingReviewPageController controller,
    AppLocalizations l10n,
  ) async {
    final success = await controller.submit(
      pleaseSelectRating: l10n.pleaseSelectRating,
      submitSuccess: l10n.coworkingReviewSubmitSuccess,
      submitFailed: l10n.submitFailed,
    );

    if (success) {
      AppToast.success(l10n.coworkingReviewSubmitSuccess);
      Get.back(result: true);
    }
  }
}
