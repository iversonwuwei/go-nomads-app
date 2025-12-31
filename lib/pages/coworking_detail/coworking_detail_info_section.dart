import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/coworking_detail_page_controller.dart';
import 'package:df_admin_mobile/pages/coworking_reviews_page.dart';
import 'package:df_admin_mobile/widgets/coworking_verification_badge.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailBadgesSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailBadgesSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          // Rating - 可点击跳转到评论列表
          InkWell(
            onTap: () {
              Get.to(() => CoworkingReviewsPage(
                    coworkingId: _c.space.value.id,
                    coworkingName: _c.space.value.name,
                  ))?.then((_) {
                _c.loadComments();
                _c.reloadCoworkingDetail();
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    _c.space.value.spaceInfo.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    ' (${_c.space.value.spaceInfo.reviewCount} ${l10n.reviews})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(FontAwesomeIcons.chevronRight, size: 16, color: Colors.grey[600]),
                ],
              ),
            ),
          ),

          CoworkingVerificationBadge(
            space: _c.space.value,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onVerified: (updatedSpace) => _c.updateSpace(updatedSpace),
          ),

          // Last Updated Badge
          if (_c.space.value.lastUpdated != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.arrowsRotate, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_c.formatDate(_c.space.value.lastUpdated!)}',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      )),
    );
  }
}

class CoworkingDetailAddressSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailAddressSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Column(
      children: [
        ListTile(
          leading: const Icon(FontAwesomeIcons.locationDot, color: Colors.red),
          title: Text(_c.space.value.fullAddress),
        ),
        if (_c.space.value.creatorName != null && _c.space.value.creatorName!.isNotEmpty)
          ListTile(
            leading: const Icon(FontAwesomeIcons.user, color: Colors.blue),
            title: Text(l10n.createdBy),
            subtitle: Text(_c.space.value.creatorName!),
          ),
      ],
    ));
  }
}

class CoworkingDetailAboutSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailAboutSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.about, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Text(
            _c.space.value.spaceInfo.description,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
          )),
        ],
      ),
    );
  }
}
