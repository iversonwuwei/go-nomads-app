import 'dart:async';

import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../flutter_map_picker_page.dart';

/// 出发地点部分 - 支持自动完成搜索
class TravelPlanDepartureSection extends StatefulWidget {
  final String controllerTag;

  const TravelPlanDepartureSection({super.key, required this.controllerTag});

  @override
  State<TravelPlanDepartureSection> createState() => _TravelPlanDepartureSectionState();
}

class _TravelPlanDepartureSectionState extends State<TravelPlanDepartureSection> {
  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: widget.controllerTag);

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

  final RxList<PoiResult> _suggestions = <PoiResult>[].obs;
  final RxBool _isSearching = false.obs;
  final RxBool _showSuggestions = false.obs;

  @override
  void initState() {
    super.initState();
    // 监听 controller 的 departureLocation 变化，同步到输入框
    ever(_c.departureLocation, (String value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
    // 初始化输入框文本
    _textController.text = _c.departureLocation.value;

    // 监听焦点变化
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // 延迟隐藏，以便用户可以点击建议项
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _hideSuggestions();
        }
      });
    }
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      _hideSuggestions();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchAddress(value.trim());
    });
  }

  Future<void> _searchAddress(String keyword) async {
    if (keyword.isEmpty) return;

    _isSearching.value = true;
    _showSuggestions.value = true;
    _showOverlay();

    try {
      final result = await AmapPoiService.instance.searchByKeyword(
        keyword: keyword,
        pageSize: 10,
      );

      _suggestions.value = result.items;
    } catch (e) {
      debugPrint('搜索地址失败: $e');
      _suggestions.clear();
    } finally {
      _isSearching.value = false;
    }
  }

  void _selectSuggestion(PoiResult poi) {
    // 使用完整地址
    final displayAddress = poi.address.isNotEmpty ? poi.address : poi.name;
    _textController.text = displayAddress;
    _c.setDepartureLocation(displayAddress);
    _hideSuggestions();
    _focusNode.unfocus();
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // 输入框高度 + 间距
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: _buildSuggestionsDropdown(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideSuggestions() {
    _showSuggestions.value = false;
    _removeOverlay();
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 减去地图按钮的宽度和间距 (56 + 12)
      return renderBox.size.width - 68;
    }
    return 300;
  }

  Widget _buildSuggestionsDropdown() {
    return Obx(() {
      if (_isSearching.value && _suggestions.isEmpty) {
        return Container(
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

      if (_suggestions.isEmpty) {
        return Container(
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

      return Container(
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final poi = _suggestions[index];
            return InkWell(
              onTap: () => _selectSuggestion(poi),
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
          },
        ),
      );
    });
  }

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
              child: CompositedTransformTarget(
                link: _layerLink,
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
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: _onTextChanged,
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
                              // 点击定位图标，重新获取当前位置
                              _hideSuggestions();
                              _focusNode.unfocus();
                              await _c.refreshCurrentLocation();
                            },
                            tooltip: '获取当前位置',
                          ),
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(FontAwesomeIcons.xmark, size: 20),
                                  onPressed: () {
                                    _textController.clear();
                                    _c.clearDepartureLocation();
                                    _hideSuggestions();
                                  },
                                )
                              : null,
                        ),
                      )),
              ),
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
                  _hideSuggestions();
                  try {
                    final result = await Get.to(() => const FlutterMapPickerPage());
                    if (result != null && result is Map) {
                      final address = result['address'] as String? ?? '';
                      final name = result['name'] as String? ?? '';
                      final displayAddress = address.isNotEmpty ? address : name;
                      _textController.text = displayAddress;
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
          '输入地址搜索或点击地图图标选择出发地点',
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
