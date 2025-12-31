import 'package:df_admin_mobile/controllers/innovation_detail_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Innovation Detail Bottom Bar
/// 创意项目详情页 - 底部操作栏
class InnovationDetailBottomBar extends StatelessWidget {
  final String controllerTag;
  final VoidCallback? onContact;

  const InnovationDetailBottomBar({
    super.key,
    required this.controllerTag,
    this.onContact,
  });

  InnovationDetailPageController get _c =>
      Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 关注按钮
            Expanded(
              flex: 1,
              child: _buildFollowButton(context),
            ),
            const SizedBox(width: 12),
            // 联系按钮
            Expanded(
              flex: 2,
              child: _buildContactButton(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    return Obx(() => OutlinedButton.icon(
          onPressed:
              _c.isToggling.value ? null : () => _c.toggleFollow(context),
          icon: Icon(
            _c.isFollowed.value
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart,
            size: 20,
          ),
          label: Text(
            _c.isToggling.value
                ? '处理中...'
                : (_c.isFollowed.value ? '已关注' : '关注'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _c.isFollowed.value
                ? const Color(0xFF8B5CF6)
                : Colors.grey[700],
            side: BorderSide(
              color: _c.isFollowed.value
                  ? const Color(0xFF8B5CF6)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ));
  }

  Widget _buildContactButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: onContact,
      icon: const Icon(FontAwesomeIcons.message, size: 20),
      label: Text(
        l10n.message,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }
}
