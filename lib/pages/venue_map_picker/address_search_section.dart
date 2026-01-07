import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/venue_map_picker_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/amap_poi_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 地址搜索组件
class AddressSearchSection extends GetView<VenueMapPickerPageController> {
  final String controllerTag;

  /// 是否只显示搜索框（不显示结果）
  final bool showResults;

  /// 是否只显示输入框
  final bool showInputOnly;

  /// 是否只显示搜索结果（用于悬浮层）
  final bool showResultsOnly;

  const AddressSearchSection({
    super.key,
    required this.controllerTag,
    this.showResults = true,
    this.showInputOnly = false,
    this.showResultsOnly = false,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 只显示搜索结果（用于悬浮层）
    if (showResultsOnly) {
      return Obx(() => controller.showSearchResults.value ? _buildSearchResults(l10n) : const SizedBox.shrink());
    }

    // 只显示输入框或完整组件
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索输入框
          _buildSearchInput(l10n),
          // 搜索结果列表（仅当 showResults 为 true 时显示）
          if (showResults)
            Obx(() => controller.showSearchResults.value ? _buildSearchResults(l10n) : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSearchInput(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        onChanged: controller.onSearchChanged,
        onTap: () {
          if (controller.searchController.text.isNotEmpty && controller.searchResults.isNotEmpty) {
            controller.showSearchResults.value = true;
          }
        },
        decoration: InputDecoration(
          hintText: l10n.searchAddress,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 16,
            color: Color(0xFFFF4458),
          ),
          suffixIcon: Obx(() {
            if (controller.isSearching.value) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
                  ),
                ),
              );
            }
            if (controller.searchController.text.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    return Obx(() {
      final results = controller.searchResults;

      if (controller.isSearching.value && results.isEmpty) {
        return _buildSearchResultsContainer(
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
              ),
            ),
          ),
        );
      }

      if (results.isEmpty) {
        return _buildSearchResultsContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                l10n.noResults,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ),
        );
      }

      return _buildSearchResultsContainer(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: results.length > 8 ? 8 : results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.grey.shade200,
            indent: 48,
          ),
          itemBuilder: (context, index) {
            final poi = results[index];
            return _buildSearchResultItem(poi);
          },
        ),
      );
    });
  }

  Widget _buildSearchResultsContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  Widget _buildSearchResultItem(PoiResult poi) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectSearchResult(poi),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.locationDot,
                  size: 16,
                  color: Color(0xFFFF4458),
                ),
              ),
              const SizedBox(width: 12),
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
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (poi.address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        poi.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (poi.distance != null && poi.distance!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    poi.formattedDistance,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
