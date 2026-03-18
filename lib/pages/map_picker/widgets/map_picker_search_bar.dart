import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 地图选点搜索栏
/// Map picker search bar with debounce and clear button
class MapPickerSearchBar extends GetView<MapPickerController> {
  const MapPickerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Obx(() {
        final isSearching = controller.isSearching.value;
        return TextField(
          controller: controller.searchTextController,
          focusNode: controller.searchFocusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.search,
            prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 18.r),
            suffixIcon: isSearching
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (controller.searchTextController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(FontAwesomeIcons.xmark, size: 16.r),
                        onPressed: controller.clearSearch,
                      )),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Color(0xFFFF4458),
                width: 1.5,
              ),
            ),
          ),
          onChanged: controller.onSearchChanged,
          onSubmitted: controller.onSearchSubmitted,
        );
      }),
    );
  }
}
