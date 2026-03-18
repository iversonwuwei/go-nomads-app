import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/add_cost_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_cost/cost_categories_section.dart';
import 'package:go_nomads_app/pages/add_cost/currency_section.dart';
import 'package:go_nomads_app/pages/add_cost/total_and_notes_section.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 添加费用页面
class AddCostPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const AddCostPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<AddCostPage> createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  late final String _tag;
  late final AddCostPageController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'add_cost_${widget.cityId}';
    _controller = Get.put(
      AddCostPageController(
        cityId: widget.cityId,
        cityName: widget.cityName,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    // 在 dispose 中安全删除 controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AddCostPageController>(tag: _tag)) {
        Get.delete<AddCostPageController>(tag: _tag);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyCost,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.cityName,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Currency Selector
                    CurrencySection(controllerTag: _tag),
                    SizedBox(height: 24.h),

                    // Cost Categories
                    CostCategoriesSection(controllerTag: _tag),
                    SizedBox(height: 24.h),

                    // Total Display
                    TotalDisplaySection(controllerTag: _tag),
                    SizedBox(height: 24.h),

                    // Notes Section
                    NotesSection(controllerTag: _tag),
                    SizedBox(height: 100.h), // Space for submit button
                  ],
                ),
              ),
            ),

            // Submit Button (Fixed at bottom)
            SubmitButton(
              controllerTag: _tag,
              onSubmit: () => _handleSubmit(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final success = await _controller.submitCost(
      pleaseEnterCost: l10n.pleaseEnterCost,
      errorTitle: l10n.error,
      successTitle: l10n.success,
      costShared: l10n.costShared,
    );

    if (success && context.mounted) {
      NavigationUtil.popAfterSuccess(
        result: {'success': true},
        context: context,
      );
    }
  }
}
