import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_page.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 出发地点部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanDepartureSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanDepartureSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.departureLocation, icon: FontAwesomeIcons.locationDot),
        SizedBox(height: 12.h),
        _DepartureInputRow(controllerTag: controllerTag),
        SizedBox(height: 8.h),
        Text(
          '输入地址搜索或点击地图图标选择出发地点',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

/// 出发地输入行（包含输入框和地图按钮）
class _DepartureInputRow extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DepartureInputRow({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DepartureSearchField(controllerTag: controllerTag),
        ),
        SizedBox(width: 12.w),
        _MapPickerButton(controllerTag: controllerTag),
      ],
    );
  }
}

/// 出发地搜索输入框（带建议下拉）
class _DepartureSearchField extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DepartureSearchField({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 输入框
        Obx(() => controller.isLoadingLocation.value
            ? const _LoadingLocationIndicator()
            : _DepartureTextField(controllerTag: controllerTag)),
        // 建议下拉列表
        Obx(() => controller.showDepartureSuggestions.value
            ? _SuggestionsDropdown(controllerTag: controllerTag)
            : const SizedBox.shrink()),
      ],
    );
  }
}

/// 加载位置指示器
class _LoadingLocationIndicator extends StatelessWidget {
  const _LoadingLocationIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF4458),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '正在获取当前位置...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

/// 出发地文本输入框
class _DepartureTextField extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DepartureTextField({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return TextField(
      controller: controller.departureSearchController,
      focusNode: controller.departureFocusNode,
      onChanged: controller.onDepartureSearchChanged,
      decoration: InputDecoration(
        hintText: l10n.selectDeparture,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFFF4458), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        prefixIcon: IconButton(
          icon: Icon(
            FontAwesomeIcons.locationCrosshairs,
            color: Color(0xFFFF4458),
            size: 18.r,
          ),
          onPressed: () async {
            controller.hideDepartureSuggestions();
            controller.departureFocusNode.unfocus();
            await controller.refreshCurrentLocation();
          },
          tooltip: '获取当前位置',
        ),
        suffixIcon: Obx(() => controller.departureLocation.value.isNotEmpty
            ? IconButton(
                icon: Icon(FontAwesomeIcons.xmark, size: 20.r),
                onPressed: controller.clearDepartureSearch,
              )
            : const SizedBox.shrink()),
      ),
    );
  }
}

/// 建议下拉列表
class _SuggestionsDropdown extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _SuggestionsDropdown({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // 搜索中且无结果
      if (controller.isDepartureSearching.value && controller.departureSuggestions.isEmpty) {
        return const _SearchingIndicator();
      }

      // 无结果
      if (controller.departureSuggestions.isEmpty) {
        return const _NoResultsIndicator();
      }

      // 显示建议列表
      return Container(
        margin: EdgeInsets.only(top: 4.h),
        constraints: BoxConstraints(maxHeight: 250.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: controller.departureSuggestions.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final poi = controller.departureSuggestions[index];
            return _SuggestionItem(poi: poi, controllerTag: controllerTag);
          },
        ),
      );
    });
  }
}

/// 搜索中指示器
class _SearchingIndicator extends StatelessWidget {
  const _SearchingIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF4458),
            ),
          ),
          SizedBox(width: 12.w),
          Text(l10n.loading, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// 无结果指示器
class _NoResultsIndicator extends StatelessWidget {
  const _NoResultsIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        '未找到相关地址',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}

/// 单个建议项
class _SuggestionItem extends GetView<CreateTravelPlanPageController> {
  final PoiResult poi;
  final String controllerTag;

  const _SuggestionItem({required this.poi, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => controller.selectDepartureSuggestion(poi),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                FontAwesomeIcons.locationDot,
                size: 14.r,
                color: Color(0xFFFF4458),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    poi.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (poi.address.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      poi.address,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 地图选择按钮
class _MapPickerButton extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _MapPickerButton({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 56.h,
      width: 56.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(FontAwesomeIcons.map, color: Colors.white),
        onPressed: () async {
          controller.hideDepartureSuggestions();
          try {
            final result = await Get.to(
              () => const MapPickerPage(),
              binding: MapPickerBinding(),
            );
            if (result != null && result is Map) {
              final address = result['address'] as String? ?? '';
              final name = result['name'] as String? ?? '';
              final displayAddress = address.isNotEmpty ? address : name;
              controller.departureSearchController.text = displayAddress;
              controller.setDepartureLocation(displayAddress);
            }
          } catch (e) {
            AppToast.error('${l10n.failedToOpenMap}: $e', title: l10n.error);
          }
        },
        tooltip: l10n.selectOnMap,
      ),
    );
  }
}

/// 出发日期部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanDateSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanDateSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.date, icon: FontAwesomeIcons.calendarDays),
        SizedBox(height: 12.h),
        _DatePickerField(controllerTag: controllerTag),
      ],
    );
  }
}

/// 日期选择器
class _DatePickerField extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _DatePickerField({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() => InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.departureDate.value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFFF4458),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.setDepartureDate(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.calendar,
                  color: controller.departureDate.value != null ? const Color(0xFFFF4458) : Colors.grey[400],
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    controller.departureDate.value != null
                        ? '${controller.departureDate.value!.year}-${controller.departureDate.value!.month.toString().padLeft(2, '0')}-${controller.departureDate.value!.day.toString().padLeft(2, '0')}'
                        : 'Select departure date',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: controller.departureDate.value != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
                if (controller.departureDate.value != null)
                  IconButton(
                    icon: Icon(FontAwesomeIcons.xmark, size: 20.r),
                    onPressed: controller.clearDepartureDate,
                  ),
              ],
            ),
          ),
        ));
  }
}

/// 区块标题组件
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
