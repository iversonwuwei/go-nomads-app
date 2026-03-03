import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 个人资料头部组件
class ProfileHeaderWidget extends StatelessWidget {
  final User user;
  final bool isMobile;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar - 点击跳转到编辑页面
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.profileEdit),
          child: Stack(
            children: [
              Container(
                width: isMobile ? 80 : 120,
                height: isMobile ? 80 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF4458),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatarContent(),
                ),
              ),
              // 编辑图标
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: isMobile ? 24 : 32,
                  height: isMobile ? 24 : 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4458),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    user.isVerified ? FontAwesomeIcons.check : FontAwesomeIcons.pen,
                    color: Colors.white,
                    size: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 20.w),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1a1a1a),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (user.isVerified)
                    Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Color(0xFFFF4458),
                      size: 20.r,
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                user.username,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Color(0xFF6b7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.currentCity != null && user.currentCountry != null) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.locationDot,
                      size: 18.r,
                      color: Color(0xFFFF4458),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${user.currentCity}, ${user.currentCountry}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF1a1a1a),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (user.bio != null) ...[
                SizedBox(height: 16.h),
                Text(
                  user.bio!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Text(
                'Member since ${_formatJoinDate(user.joinedDate)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF9ca3af),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建头像内容
  Widget _buildAvatarContent() {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    if (hasAvatar) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar();
        },
      );
    } else {
      return _buildInitialsAvatar();
    }
  }

  /// 构建首字母头像
  Widget _buildInitialsAvatar() {
    String initials = '';
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        initials = nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        initials = user.name.substring(0, user.name.length >= 2 ? 2 : 1).toUpperCase();
      }
    } else {
      initials = '?';
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.sp,
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}
