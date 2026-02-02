import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/venue_map_picker_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/venue_map_picker/address_search_section.dart';
import 'package:go_nomads_app/pages/venue_map_picker/filter_chips_section.dart';
import 'package:go_nomads_app/pages/venue_map_picker/map_section.dart';
import 'package:go_nomads_app/pages/venue_map_picker/venue_list_section.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 场地地图选择器页面
class VenueMapPickerPage extends StatelessWidget {
  final String? cityName;
  final String? initialVenueAddress;

  const VenueMapPickerPage({
    super.key,
    this.cityName,
    this.initialVenueAddress,
  });

  String get _tag => 'venue_map_picker_${cityName ?? 'default'}';

  @override
  Widget build(BuildContext context) {
    // 注册 Controller
    Get.put(
      VenueMapPickerPageController(
        cityName: cityName,
        initialVenueAddress: initialVenueAddress,
      ),
      tag: _tag,
    );

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<VenueMapPickerPageController>(tag: _tag);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const AppBackButton(color: AppColors.backButtonDark),
          title: Text(
            l10n.selectVenue,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _confirmSelection(context, l10n),
              child: Text(
                l10n.confirm,
                style: const TextStyle(
                  color: Color(0xFFFF4458),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            // 点击其他区域时隐藏搜索结果
            final controller = Get.find<VenueMapPickerPageController>(tag: _tag);
            controller.hideSearchResults();
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              // 主布局
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressSearchSection(controllerTag: _tag, showResults: false),
                  FilterChipsSection(controllerTag: _tag),
                  MapSection(controllerTag: _tag),
                  Expanded(child: VenueListSection(controllerTag: _tag)),
                ],
              ),
              // 搜索结果浮层
              Positioned(
                top: 56, // 搜索框高度 + padding
                left: 16,
                right: 16,
                child: AddressSearchSection(controllerTag: _tag, showInputOnly: false, showResultsOnly: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context, AppLocalizations l10n) {
    final controller = Get.find<VenueMapPickerPageController>(tag: _tag);
    final result = controller.confirmSelection(l10n.noSelection, l10n.pleaseSelectVenue);
    if (result != null) {
      Get.back(result: result);
    }
  }
}
