import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../flutter_map_picker_page.dart';

/// 出发地点部分
class TravelPlanDepartureSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanDepartureSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.departureLocation, FontAwesomeIcons.locationDot),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _c.isLoadingLocation.value
                  ? Container(
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
                    )
                  : TextField(
                      controller: TextEditingController(text: _c.departureLocation.value),
                      readOnly: true,
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
                        prefixIcon: const Icon(
                          FontAwesomeIcons.locationCrosshairs,
                          color: Color(0xFFFF4458),
                          size: 18,
                        ),
                        suffixIcon: _c.departureLocation.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(FontAwesomeIcons.xmark, size: 20),
                                onPressed: _c.clearDepartureLocation,
                              )
                            : null,
                      ),
                    )),
            ),
            const SizedBox(width: 12),
            Container(
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
                  try {
                    final result = await Get.to(() => const FlutterMapPickerPage());
                    if (result != null && result is Map) {
                      // 优先使用完整地址，其次使用名称，最后使用简短地址
                      final address = result['address'] as String? ?? '';
                      final name = result['name'] as String? ?? '';
                      // 选择更详细的地址显示
                      final displayAddress = address.isNotEmpty ? address : name;
                      _c.setDepartureLocation(displayAddress);
                    }
                  } catch (e) {
                    AppToast.error('${l10n.failedToOpenMap}: $e', title: l10n.error);
                  }
                },
                tooltip: l10n.selectOnMap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tapMapIcon,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF4458)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}

/// 出发日期部分
class TravelPlanDateSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanDateSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Departure Date', FontAwesomeIcons.calendarDays),
        const SizedBox(height: 12),
        Obx(() => InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _c.departureDate.value ?? DateTime.now(),
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
                  _c.setDepartureDate(picked);
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
                      color: _c.departureDate.value != null ? const Color(0xFFFF4458) : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _c.departureDate.value != null
                            ? '${_c.departureDate.value!.year}-${_c.departureDate.value!.month.toString().padLeft(2, '0')}-${_c.departureDate.value!.day.toString().padLeft(2, '0')}'
                            : 'Select departure date',
                        style: TextStyle(
                          fontSize: 15,
                          color: _c.departureDate.value != null ? Colors.black87 : Colors.grey[400],
                        ),
                      ),
                    ),
                    if (_c.departureDate.value != null)
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.xmark, size: 20),
                        onPressed: _c.clearDepartureDate,
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF4458)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
