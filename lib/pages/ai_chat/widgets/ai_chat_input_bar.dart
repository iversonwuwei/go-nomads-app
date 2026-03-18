import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AI Chat 输入框
/// 使用 GetView 自动获取 controller
class AiChatInputBar extends GetView<AiChatController> {
  const AiChatInputBar({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 24,
          8,
          isMobile ? 14 : 24,
          14,
        ),
        child: Row(
          children: [
            Expanded(child: _buildTextField()),
            SizedBox(width: 10.w),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    final l10n = AppLocalizations.of(Get.context!)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Obx(() {
        return TextField(
          controller: controller.inputController,
          enabled: !controller.isStreaming.value,
          decoration: InputDecoration(
            hintText: l10n.aiChatInputHint,
            border: InputBorder.none,
          ),
          minLines: 1,
          maxLines: 4,
          onSubmitted: (_) => controller.sendMessage(),
        );
      }),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final disabled = controller.isStreaming.value;

      return ElevatedButton(
        onPressed: disabled ? null : controller.sendMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cityPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 16,
            vertical: isMobile ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: FaIcon(
          FontAwesomeIcons.paperPlane,
          color: Colors.white,
          size: 16.r,
        ),
      );
    });
  }
}
