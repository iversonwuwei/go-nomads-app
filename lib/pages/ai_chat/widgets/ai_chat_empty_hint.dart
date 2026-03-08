import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// AI Chat 空状态提示
class AiChatEmptyHint extends StatelessWidget {
  const AiChatEmptyHint({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          SizedBox(height: 18.h),
          Text(
            l10n.aiChatEmptyHint,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          _buildStartButton(l10n),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12.r,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: FaIcon(
        FontAwesomeIcons.solidComments,
        color: AppColors.cityPrimary,
        size: 28.r,
      ),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      child: Text(l10n.aiChatStartConversation),
    );
  }
}
