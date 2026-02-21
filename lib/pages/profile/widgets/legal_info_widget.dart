import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

/// 法律信息入口组件（用于 Profile 页面，工信部/腾讯合规要求）
/// Legal info entry widget (Tencent app store compliance - permanent entry)
class LegalInfoWidget extends StatelessWidget {
  const LegalInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 用户协议
          _LegalItem(
            icon: FontAwesomeIcons.fileContract,
            iconColor: const Color(0xFF4A90D9),
            bgColor: const Color(0xFFEBF3FB),
            title: l10n.termsAndConditions,
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
          ),
          const Divider(height: 1, indent: 60, endIndent: 16),
          // 隐私政策
          _LegalItem(
            icon: FontAwesomeIcons.shieldHalved,
            iconColor: const Color(0xFF52C41A),
            bgColor: const Color(0xFFEFF9EB),
            title: l10n.privacyPolicy,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
        ],
      ),
    );
  }
}

/// 法律信息列表项
class _LegalItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final VoidCallback onTap;

  const _LegalItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Icon(
              FontAwesomeIcons.chevronRight,
              color: Color(0xFFCCCCCC),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
