import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_amenities_hours_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_comments_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_contact_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_image_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_info_section.dart';
import 'package:go_nomads_app/pages/coworking_detail/coworking_detail_pricing_specs_section.dart';
import 'package:go_nomads_app/pages/osm_navigation_page.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

class CoworkingDetailPage extends StatelessWidget {
  final CoworkingSpace space;

  const CoworkingDetailPage({super.key, required this.space});

  String get _controllerTag => 'coworking_detail_${space.id}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CoworkingDetailPageController(initialSpace: space),
      tag: _controllerTag,
    );

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(controller);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black87),
              leading: SliverBackButton(onPressed: () => _handleBack(controller)),
              actions: [
                // 图片计数器
                CoworkingDetailImageCounterBadge(controllerTag: _controllerTag),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: CoworkingDetailImageSection(controllerTag: _controllerTag),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address section
                  CoworkingDetailAddressSection(controllerTag: _controllerTag),
                  const Divider(),

                  // About section
                  CoworkingDetailAboutSection(controllerTag: _controllerTag),
                  const Divider(),

                  // Pricing section
                  CoworkingDetailPricingSection(controllerTag: _controllerTag),
                  const Divider(),

                  // Specs section
                  CoworkingDetailSpecsSection(controllerTag: _controllerTag),
                  const Divider(),

                  // Amenities section
                  CoworkingDetailAmenitiesSection(controllerTag: _controllerTag),
                  const Divider(),

                  // Opening Hours section (conditionally shown)
                  CoworkingDetailOpeningHoursSection(controllerTag: _controllerTag),

                  // Contact section
                  CoworkingDetailContactSection(controllerTag: _controllerTag),
                  const Divider(),

                  // Comments section
                  CoworkingDetailCommentsSection(controllerTag: _controllerTag),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),

        // Bottom Action Bar
        bottomNavigationBar: _buildBottomBar(context, l10n, controller),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n, CoworkingDetailPageController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(FontAwesomeIcons.diamondTurnRight),
              label: Text(l10n.directions),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () => Get.to(() => OSMNavigationPage(coworkingSpace: controller.space.value)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => ElevatedButton.icon(
                  icon: const Icon(FontAwesomeIcons.globe),
                  label: Text(l10n.visitWebsite),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: controller.space.value.contactInfo.hasWebsite
                      ? () => controller.launchURL(controller.space.value.contactInfo.website)
                      : null,
                )),
          ),
        ],
      ),
    );
  }

  void _handleBack(CoworkingDetailPageController controller) {
    NavigationUtil.backFromDetail<CoworkingSpace>(
      entity: controller.space.value,
      hasChanged: controller.hasDataChanged.value,
      context: Get.context,
    );
    _cleanupController();
  }

  void _cleanupController() {
    if (Get.isRegistered<CoworkingDetailPageController>(tag: _controllerTag)) {
      Get.delete<CoworkingDetailPageController>(tag: _controllerTag);
    }
  }
}
