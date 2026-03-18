import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            Icon(FontAwesomeIcons.image, size: 20.r, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8.w),
            Text(l10n.projectCover, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            SizedBox(width: 8.w),
            Text('(${l10n.optional})', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => _showImageSourceBottomSheet(context),
          child: Container(
            height: previewHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
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
            ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.file(_c.coverImage.value!, fit: BoxFit.cover)),
            _buildRemoveButton(),
            _buildImageSourceBadge(l10n.addInnovationImageSourceLocal, Icons.folder),
          ],
        );
      } else if (_c.coverImageUrl.value != null && _c.coverImageUrl.value!.isNotEmpty) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                _c.coverImageUrl.value!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                },
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FontAwesomeIcons.circleExclamation, color: Colors.grey[400], size: 32.r),
                  SizedBox(height: 8.h),
                  Text(l10n.loadFailed, style: TextStyle(color: Colors.grey[500], fontSize: 12.sp))
                ])),
              ),
            ),
            _buildRemoveButton(),
            _buildImageSourceBadge(l10n.addInnovationImageSourceAiGenerated, Icons.auto_awesome),
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
            SizedBox(width: 40.w, height: 40.h, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)))),
            SizedBox(height: 16.h),
            Obx(() => Text(
                _c.generatingStatus.value.isNotEmpty ? _c.generatingStatus.value : l10n.addInnovationAiGenerating,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center)),
          ],
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), shape: BoxShape.circle),
            child: Icon(FontAwesomeIcons.images, color: Colors.grey[400], size: 32.r),
          ),
          SizedBox(height: 12.h),
          Text(l10n.tapToSelectPhoto, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(l10n.addInnovationSupportAlbumOrAi, style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
        ],
      );
    });
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 8.h,
      right: 8.w,
      child: IconButton(
        onPressed: _c.removeImage,
        style: IconButton.styleFrom(backgroundColor: Colors.black.withAlpha(128)),
        icon: Icon(FontAwesomeIcons.xmark, color: Colors.white, size: 20.r),
      ),
    );
  }

  Widget _buildImageSourceBadge(String label, IconData icon) {
    return Positioned(
      bottom: 8.h,
      left: 8.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(color: Colors.black.withAlpha(153), borderRadius: BorderRadius.circular(16.r)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14.r, color: Colors.white), SizedBox(width: 4.w), Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.white))]),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20.r, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 48.w, height: 5.h, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]), borderRadius: BorderRadius.circular(3.r))),
                SizedBox(height: 28.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]), borderRadius: BorderRadius.circular(14.r), boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(60), blurRadius: 12.r, offset: const Offset(0, 4))]),
                      child: Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22.r),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AppLocalizations.of(context)!.addInnovationSelectCoverImage,
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      SizedBox(height: 4.h),
                      Text(AppLocalizations.of(context)!.addInnovationAddAttractiveCover,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey))
                    ])),
                  ],
                ),
                SizedBox(height: 28.h),
                Row(
                  children: [
                    Expanded(
                        child: _buildModernOptionCard(
                            icon: Icons.photo_library_rounded,
                            title: AppLocalizations.of(context)!.addInnovationAlbum,
                            subtitle: AppLocalizations.of(context)!.addInnovationPickFromLocal,
                            gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                            onTap: () {
                              Navigator.pop(context);
                              _c.pickImage();
                            })),
                    SizedBox(width: 16.w),
                    Expanded(
                        child: _buildModernOptionCard(
                            icon: Icons.auto_awesome_rounded,
                            title: AppLocalizations.of(context)!.addInnovationAiGenerate,
                            subtitle: AppLocalizations.of(context)!.addInnovationAiCreative,
                            gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                            onTap: () {
                              Navigator.pop(context);
                              _handleAIGenerateClick(context);
                            },
                            isPremium: true)),
                  ],
                ),
                SizedBox(height: 20.h),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.grey.shade200, width: 1.5), boxShadow: [BoxShadow(color: gradientColors[0].withAlpha(15), blurRadius: 20.r, offset: const Offset(0, 8))]),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(width: 64.w, height: 64.h, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors), borderRadius: BorderRadius.circular(18.r), boxShadow: [BoxShadow(color: gradientColors[0].withAlpha(80), blurRadius: 16.r, offset: const Offset(0, 6))]), child: Icon(icon, color: Colors.white, size: 30.r)),
                if (isPremium)
                  Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFFF59E0B).withAlpha(60),
                                    blurRadius: 8.r,
                                    offset: const Offset(0, 2))
                              ]),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12.r),
                            SizedBox(width: 2.w),
                            Text(AppLocalizations.of(Get.context!)!.addInnovationAiBadge,
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold))
                          ]))),
              ],
            ),
            SizedBox(height: 16.h),
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            SizedBox(height: 4.h),
            Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  void _handleAIGenerateClick(BuildContext context) {
    if (!Get.isRegistered<MembershipStateController>()) {
      AppToast.error(AppLocalizations.of(context)!.addInnovationMembershipUnavailable);
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
          constraints: BoxConstraints(maxWidth: 380.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r), boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 30.r, offset: const Offset(0, 10))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120.h,
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)]), borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
                child: Center(child: Icon(Icons.auto_awesome_rounded, size: 48.r, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.addInnovationAiImageGeneration,
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    SizedBox(height: 8.h),
                    Text(AppLocalizations.of(context)!.addInnovationMemberExclusive,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { Navigator.of(dialogContext).pop(); Get.toNamed(AppRoutes.membershipPlan); },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(FontAwesomeIcons.crown, size: 16.r), SizedBox(width: 8.w), Text(AppLocalizations.of(context)!.addInnovationUpgradeMembershipUnlock, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))]),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(AppLocalizations.of(context)!.addInnovationMaybeLater,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp))),
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
        title: Row(children: [
          Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Text(l10n.addInnovationAiGenerateCover)
        ]),
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
                        hintText: l10n.addInnovationDescribeCoverHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        filled: true)),
                SizedBox(height: 16.h),
                Text(l10n.addInnovationQuickTemplates,
                    style: TextStyle(fontSize: 12.sp, color: Theme.of(context).hintColor)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: promptTemplates
                      .map((template) => InkWell(
                            onTap: () => _c.aiPromptController.text = template,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3))),
                              child: Text(template.length > 20 ? '${template.substring(0, 20)}...' : template,
                                  style: TextStyle(fontSize: 11.sp, color: Theme.of(context).primaryColor)),
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
            icon: _c.isGeneratingImage.value ? SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.auto_awesome, size: 18.r),
                label: Text(_c.isGeneratingImage.value ? l10n.addInnovationGenerating : l10n.generate),
          )),
        ],
      ),
    );
  }
}
