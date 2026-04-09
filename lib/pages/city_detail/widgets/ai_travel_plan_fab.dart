import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/membership/presentation/services/ai_planner_access_service.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

Future<void> openAiTravelPlanEntry(
  BuildContext context, {
  required String cityId,
  required String cityName,
}) async {
  try {
    final allowed = await AiPlannerAccessService().ensureAccess(
      featureName: 'AI 旅行规划师',
    );

    if (!allowed) {
      return;
    }
  } catch (e) {
    log('⚠️ AI 旅行规划师会员检查异常: $e');
  }

  Get.toNamed(
    AppRoutes.createTravelPlan,
    arguments: {
      'cityId': cityId,
      'cityName': cityName,
    },
  );
}

/// AI 旅行计划浮动按钮
class AiTravelPlanFab extends StatelessWidget {
  final String cityId;
  final String cityName;

  const AiTravelPlanFab({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final fabLabel = isEnglish ? 'AI Plan' : 'AI Travel Plan';

    return Material(
      elevation: 6,
      shadowColor: AppColors.cityPrimary.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(28.r),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.cityPrimary, Color(0xFFFF6B7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.cityPrimary.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: Colors.white,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                fabLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                FontAwesomeIcons.arrowRight,
                color: Colors.white,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    openAiTravelPlanEntry(
      context,
      cityId: cityId,
      cityName: cityName,
    );
  }
}
