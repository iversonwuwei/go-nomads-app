import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_page.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

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
        const SizedBox(height: 12),
        _DepartureInputRow(controllerTag: controllerTag),
        const SizedBox(height: 8),
        Text(
          '输入地址搜索或点击地图图标选择出发地点',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
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
        const SizedBox(width: 12),
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
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF4458),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在获取当前位置...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4458), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: IconButton(
          icon: const Icon(
            FontAwesomeIcons.locationCrosshairs,
            color: Color(0xFFFF4458),
            size: 18,
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
                icon: const Icon(FontAwesomeIcons.xmark, size: 20),
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
        margin: const EdgeInsets.only(top: 4),
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
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
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF4458),
            ),
          ),
          SizedBox(width: 12),
          Text('搜索中...', style: TextStyle(color: Colors.grey)),
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
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                FontAwesomeIcons.locationDot,
                size: 14,
                color: Color(0xFFFF4458),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (poi.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      poi.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 8,
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
    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Departure Date', icon: FontAwesomeIcons.calendarDays),
        const SizedBox(height: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.calendar,
                  color: controller.departureDate.value != null ? const Color(0xFFFF4458) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.departureDate.value != null
                        ? '${controller.departureDate.value!.year}-${controller.departureDate.value!.month.toString().padLeft(2, '0')}-${controller.departureDate.value!.day.toString().padLeft(2, '0')}'
                        : 'Select departure date',
                    style: TextStyle(
                      fontSize: 15,
                      color: controller.departureDate.value != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
                if (controller.departureDate.value != null)
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark, size: 20),
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
        Icon(icon, size: 20, color: const Color(0xFFFF4458)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
