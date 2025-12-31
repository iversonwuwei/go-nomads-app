import 'package:df_admin_mobile/controllers/innovation_detail_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Innovation Detail Creator Section
/// 创意项目详情页 - 创建者信息区块
class InnovationDetailCreatorSection extends StatelessWidget {
  final String controllerTag;

  const InnovationDetailCreatorSection({
    super.key,
    required this.controllerTag,
  });

  InnovationDetailPageController get _c =>
      Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF8B5CF6),
                backgroundImage: _c.project.userAvatar != null &&
                        _c.project.userAvatar!.isNotEmpty
                    ? NetworkImage(_c.project.userAvatar!)
                    : null,
                child: _c.project.userAvatar == null ||
                        _c.project.userAvatar!.isEmpty
                    ? Text(
                        (_c.project.userName ?? '?').isNotEmpty
                            ? (_c.project.userName ?? '?').substring(0, 1)
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _c.project.userName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.createdAt} ${_c.formatDate(_c.project.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
