import 'package:df_admin_mobile/controllers/innovation_detail_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/admin_delete_button.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// Innovation Detail App Bar Section
/// 创意项目详情页 - AppBar 区域
class InnovationDetailAppBar extends StatelessWidget {
  final String controllerTag;
  final VoidCallback? onEdit;

  const InnovationDetailAppBar({
    super.key,
    required this.controllerTag,
    this.onEdit,
  });

  InnovationDetailPageController get _c => Get.find<InnovationDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: const Color(0xFF8B5CF6),
          leading: const SliverBackButton(),
          actions: [
            // 管理员删除按钮
            if (_c.isAdmin.value)
              AdminDeleteButton(
                isAdmin: true,
                entityName: '创新项目',
                onDelete: () => _c.deleteInnovationProject(),
              ),
            // 编辑按钮 - 仅当 canEdit 为 true 时显示
            if (_c.project.canEdit)
              IconButton(
                icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.white, size: 20),
                onPressed: onEdit,
                tooltip: l10n.edit,
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _c.project.projectName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Color.fromARGB(128, 0, 0, 0),
                  ),
                ],
              ),
            ),
            background: _buildBackground(),
          ),
        ));
  }

  Widget _buildBackground() {
    final imageUrl = _c.project.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultHeader();
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _buildDefaultHeader();
  }

  /// 构建默认的 Header 背景
  Widget _buildDefaultHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6366F1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.lightbulb,
          size: 80,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
