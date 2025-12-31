import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/coworking_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailContactSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailContactSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final contact = _c.space.value.contactInfo;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.contactInfo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (contact.phone.isNotEmpty) _buildPhoneCard(context, l10n, contact.phone),
            if (contact.phone.isNotEmpty && contact.email.isNotEmpty) const SizedBox(height: 12),
            if (contact.email.isNotEmpty) _buildEmailCard(l10n, contact.email),
            if ((contact.phone.isNotEmpty || contact.email.isNotEmpty) && contact.hasWebsite) const SizedBox(height: 12),
            if (contact.hasWebsite) _buildWebsiteCard(l10n, contact.website),
          ],
        ),
      );
    });
  }

  Widget _buildPhoneCard(BuildContext context, AppLocalizations l10n, String phone) {
    return InkWell(
      onTap: () => _c.makePhoneCall(context, phone),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
              child: const Icon(FontAwesomeIcons.phone, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(phone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.phone, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(l10n.call, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(AppLocalizations l10n, String email) {
    return InkWell(
      onTap: () => _c.launchURL('mailto:$email'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Icon(FontAwesomeIcons.envelope, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(AppLocalizations l10n, String website) {
    return InkWell(
      onTap: () => _c.launchURL(website),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
              child: const Icon(FontAwesomeIcons.globe, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.website, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(website, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
