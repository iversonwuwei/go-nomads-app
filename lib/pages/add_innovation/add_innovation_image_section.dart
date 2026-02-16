import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/add_innovation_page_controller.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

class AddInnovationImageSection extends StatelessWidget {
  final String controllerTag;

  const AddInnovationImageSection({super.key, required this.controllerTag});

  AddInnovationPageController get _c => Get.find<AddInnovationPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final previewHeight = isMobile ? 180.0 : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(FontAwesomeIcons.image, size: 20, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Text(l10n.projectCover, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Text('(${l10n.optional})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showImageSourceBottomSheet(context),
          child: Container(
            height: previewHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: _buildImagePreview(context, previewHeight, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, double height, AppLocalizations l10n) {
    return Obx(() {
      if (_c.coverImage.value != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_c.coverImage.value!, fit: BoxFit.cover)),
            _buildRemoveButton(),
            _buildImageSourceBadge('本地图片', Icons.folder),
          ],
        );
      } else if (_c.coverImageUrl.value != null && _c.coverImageUrl.value!.isNotEmpty) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _c.coverImageUrl.value!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                },
                errorBuilder: (context, error, stackTrace) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(FontAwesomeIcons.circleExclamation, color: Colors.grey[400], size: 32), const SizedBox(height: 8), Text('加载失败', style: TextStyle(color: Colors.grey[500], fontSize: 12))])),
              ),
            ),
            _buildRemoveButton(),
            _buildImageSourceBadge('AI 生成', Icons.auto_awesome),
          ],
        );
      }
      return _buildEmptyImagePlaceholder(l10n);
    });
  }

  Widget _buildEmptyImagePlaceholder(AppLocalizations l10n) {
    return Obx(() {
      if (_c.isGeneratingImage.value) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)))),
            const SizedBox(height: 16),
            Obx(() => Text(_c.generatingStatus.value.isNotEmpty ? _c.generatingStatus.value : 'AI 正在创作中...', style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center)),
          ],
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), shape: BoxShape.circle),
            child: Icon(FontAwesomeIcons.images, color: Colors.grey[400], size: 32),
          ),
          const SizedBox(height: 12),
          Text(l10n.tapToSelectPhoto, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text('支持相册选择或 AI 生成', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      );
    });
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        onPressed: _c.removeImage,
        style: IconButton.styleFrom(backgroundColor: Colors.black.withAlpha(128)),
        icon: const Icon(FontAwesomeIcons.xmark, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildImageSourceBadge(String label, IconData icon) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.black.withAlpha(153), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, color: Colors.white))]),
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey.shade50]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 48, height: 5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]), borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('选择封面图片', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)), SizedBox(height: 4), Text('为你的项目添加一张吸引眼球的封面', style: TextStyle(fontSize: 13, color: Colors.grey))])),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _buildModernOptionCard(icon: Icons.photo_library_rounded, title: '相册', subtitle: '从本地选择', gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)], onTap: () { Navigator.pop(context); _c.pickImage(); })),
                    const SizedBox(width: 16),
                    Expanded(child: _buildModernOptionCard(icon: Icons.auto_awesome_rounded, title: 'AI 生成', subtitle: '智能创作', gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)], onTap: () { Navigator.pop(context); _handleAIGenerateClick(context); }, isPremium: true)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionCard({required IconData icon, required String title, required String subtitle, required List<Color> gradientColors, required VoidCallback onTap, bool isPremium = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200, width: 1.5), boxShadow: [BoxShadow(color: gradientColors[0].withAlpha(15), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: gradientColors[0].withAlpha(80), blurRadius: 16, offset: const Offset(0, 6))]), child: Icon(icon, color: Colors.white, size: 30)),
                if (isPremium) Positioned(top: -6, right: -6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withAlpha(60), blurRadius: 8, offset: const Offset(0, 2))]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, color: Colors.white, size: 12), SizedBox(width: 2), Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]))),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  void _handleAIGenerateClick(BuildContext context) {
    if (!Get.isRegistered<MembershipStateController>()) {
      AppToast.error('会员服务不可用，请稍后再试');
      return;
    }
    final membershipController = Get.find<MembershipStateController>();
    if (membershipController.canUseAI || membershipController.isPaidMember) {
      _showAIGenerateDialog(context);
    } else {
      _showMembershipRequiredDialog(context);
    }
  }

  void _showMembershipRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 30, offset: const Offset(0, 10))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)]), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: const Center(child: Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  children: [
                    const Text('AI 图片生成', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text('会员专属功能', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { Navigator.of(dialogContext).pop(); Get.toNamed(AppRoutes.membershipPlan); },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(FontAwesomeIcons.crown, size: 16), SizedBox(width: 8), Text('升级会员解锁', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('稍后再说', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIGenerateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _c.aiPromptController.clear();

    final promptTemplates = ['一个现代化的科技创业项目封面，蓝色渐变背景，极简风格', '创新与科技结合的抽象图像，充满活力的色彩', '数字化转型概念图，展现连接与协作', '绿色环保主题的创业项目封面，自然与科技融合'];

    Get.dialog(
      AlertDialog(
        title: Row(children: [Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor), const SizedBox(width: 8), const Text('AI 生成封面')]),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                    controller: _c.aiPromptController,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: '请描述您想要的封面图片...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true)),
                const SizedBox(height: 16),
                Text('快速模板：', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: promptTemplates
                      .map((template) => InkWell(
                            onTap: () => _c.aiPromptController.text = template,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3))),
                              child: Text(template.length > 20 ? '${template.substring(0, 20)}...' : template,
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor)),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10n.cancel)),
          Obx(() => ElevatedButton.icon(
            onPressed: _c.isGeneratingImage.value ? null : () { Get.back(); _c.generateImageWithAI(_c.aiPromptController.text); },
            icon: _c.isGeneratingImage.value ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_c.isGeneratingImage.value ? '生成中...' : '生成'),
          )),
        ],
      ),
    );
  }
}
