import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28.r),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppUiTokens.heroCardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.wandMagicSparkles,
                  color: AppColors.cityPrimary,
                  size: 15.r,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fabLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEnglish ? 'Create a city-specific route' : '生成当前城市的专属行程',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.arrowRight,
                  color: AppColors.cityPrimary,
                  size: 14.r,
                ),
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
