import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoworkingDetailAddressSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailAddressSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Padding(
      padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Coworking 名称
              Text(
                _c.space.value.name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              // 地址信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.red,
                      size: 16.r,
                    ),
              ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _c.space.value.fullAddress,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              // 创建者信息
              if (_c.space.value.creatorName != null && _c.space.value.creatorName!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        FontAwesomeIcons.user,
                        color: Colors.blue,
                        size: 16.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.createdBy,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _c.space.value.creatorName!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
    ));
  }
}

class CoworkingDetailAboutSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailAboutSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.about, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Obx(() => Text(
            _c.space.value.spaceInfo.description,
            style: TextStyle(fontSize: 15.sp, color: Colors.grey[700], height: 1.5),
          )),
        ],
      ),
    );
  }
}
