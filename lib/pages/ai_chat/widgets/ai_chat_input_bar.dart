import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_controller.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

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
          12,
          isMobile ? 14 : 24,
          14,
        ),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AiChatTheme.panel,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: AiChatTheme.line),
            boxShadow: [
              BoxShadow(
                color: AiChatTheme.shadow,
                blurRadius: 24.r,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: _buildTextField()),
              SizedBox(width: 10.w),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    final l10n = AppLocalizations.of(Get.context!)!;
    return Container(
      decoration: BoxDecoration(
        color: AiChatTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AiChatTheme.line),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      child: Obx(() {
        return TextField(
          controller: controller.inputController,
          enabled: !controller.isStreaming.value,
          style: TextStyle(
            color: AiChatTheme.ink,
            fontSize: 15.sp,
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: l10n.aiChatInputHint,
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 6.w, right: 8.w),
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16.r,
                  color: AiChatTheme.teal,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintStyle: TextStyle(
              color: AiChatTheme.inkSoft,
              fontSize: 14.sp,
            ),
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
          backgroundColor: AiChatTheme.coral,
          disabledBackgroundColor: AiChatTheme.inkSoft.withValues(alpha: 0.35),
          minimumSize: Size(52.r, 52.r),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        child: FaIcon(
          FontAwesomeIcons.paperPlane,
          color: Colors.white,
          size: 15.r,
        ),
      );
    });
  }
}
