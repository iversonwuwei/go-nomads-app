import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/add_cost/cost_categories_section.dart';
import 'package:df_admin_mobile/pages/add_cost/currency_section.dart';
import 'package:df_admin_mobile/pages/add_cost/total_and_notes_section.dart';
import 'package:df_admin_mobile/controllers/add_cost_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 添加费用页面
class AddCostPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const AddCostPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  String get _tag => 'add_cost_$cityId';

  @override
  Widget build(BuildContext context) {
    // 注册 Controller
    final controller = Get.put(
      AddCostPageController(
        cityId: cityId,
        cityName: cityName,
      ),
      tag: _tag,
    );

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<AddCostPageController>(tag: _tag);
        }
      },
      child: Scaffold(
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cityName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Currency Selector
                      CurrencySection(controllerTag: _tag),
                      const SizedBox(height: 24),

                      // Cost Categories
                      CostCategoriesSection(controllerTag: _tag),
                      const SizedBox(height: 24),

                      // Total Display
                      TotalDisplaySection(controllerTag: _tag),
                      const SizedBox(height: 24),

                      // Notes Section
                      NotesSection(controllerTag: _tag),
                      const SizedBox(height: 100), // Space for submit button
                    ],
                  ),
                ),
              ),

              // Submit Button (Fixed at bottom)
              SubmitButton(
                controllerTag: _tag,
                onSubmit: () => _handleSubmit(context, controller, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    AddCostPageController controller,
    AppLocalizations l10n,
  ) async {
    final success = await controller.submitCost(
      pleaseEnterCost: l10n.pleaseEnterCost,
      errorTitle: l10n.error,
      successTitle: l10n.success,
      costShared: l10n.costShared,
    );

    if (success) {
      Get.back(result: {
        'success': true,
      });
    }
  }
}
