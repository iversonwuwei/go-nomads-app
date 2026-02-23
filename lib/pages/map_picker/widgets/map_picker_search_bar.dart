import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_controller.dart';

/// 地图选点搜索栏
/// Map picker search bar with debounce and clear button
class MapPickerSearchBar extends GetView<MapPickerController> {
  const MapPickerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Obx(() {
        final isSearching = controller.isSearching.value;
        return TextField(
          controller: controller.searchTextController,
          focusNode: controller.searchFocusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '搜索地点 / Search location',
            prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
            suffixIcon: isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (controller.searchTextController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(FontAwesomeIcons.xmark, size: 16),
                        onPressed: controller.clearSearch,
                      )),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
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
