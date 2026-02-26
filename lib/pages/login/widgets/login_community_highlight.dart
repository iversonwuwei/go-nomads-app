import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 社区亮点展示
class LoginCommunityHighlight extends StatelessWidget {
  const LoginCommunityHighlight({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(LoginConstants.cardBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: LoginConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  FontAwesomeIcons.userGroup,
                  color: LoginConstants.primaryColor,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join 38,000+ nomads',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Living and working around the world',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _FeatureBadge(emoji: '🍹', text: '363 meetups/year'),
              SizedBox(width: 8.w),
              _FeatureBadge(emoji: '💬', text: '15k+ messages'),
              SizedBox(width: 8.w),
              _FeatureBadge(emoji: '🌍', text: '100+ cities'),
            ],
          ),
        ],
      ),
    );
  }
}

/// 特性徽章
class _FeatureBadge extends StatelessWidget {
  final String emoji;
  final String text;

  const _FeatureBadge({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 4.h),
            SizedBox(
              height: 30.h,
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
