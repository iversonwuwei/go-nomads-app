import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/domain/entities/city_option.dart';
import 'package:go_nomads_app/features/location/presentation/controllers/location_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 用户选择国家和城市的结果
class LocationSelectionResult {
  final String? countryId;
  final String? countryName;
  final String? cityId;
  final String? cityName;

  const LocationSelectionResult({
    this.countryId,
    this.countryName,
    this.cityId,
    this.cityName,
  });
}

/// 城市选择组件：显示一个表单字段，点击后弹出国家+城市联动选择器
class LocationPickerField extends StatefulWidget {
  final LocationStateController? locationController;
  final String? initialCountryId;
  final String? initialCountryName;
  final String? initialCityId;
  final String? initialCityName;
  final ValueChanged<LocationSelectionResult>? onChanged;
  final FormFieldValidator<LocationSelectionResult?>? validator;
  final String? label;
  final bool required;
  final bool enabled;

  const LocationPickerField({
    super.key,
    this.locationController,
    this.initialCountryId,
    this.initialCountryName,
    this.initialCityId,
    this.initialCityName,
    this.onChanged,
    this.validator,
    this.label,
    this.required = false,
    this.enabled = true,
  });

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  late final LocationStateController _locationController;

  String? _selectedCountryId;
  String? _selectedCountryName;
  String? _selectedCityId;
  String? _selectedCityName;

  @override
  void initState() {
    super.initState();
    _locationController = widget.locationController ?? Get.find<LocationStateController>();
    _selectedCountryId = widget.initialCountryId;
    _selectedCountryName = widget.initialCountryName;
    _selectedCityId = widget.initialCityId;
    _selectedCityName = widget.initialCityName;

    _ensureLocationDataLoaded();
  }

  @override
  void didUpdateWidget(covariant LocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCountryId != widget.initialCountryId ||
        oldWidget.initialCountryName != widget.initialCountryName ||
        oldWidget.initialCityId != widget.initialCityId ||
        oldWidget.initialCityName != widget.initialCityName) {
      _selectedCountryId = widget.initialCountryId;
      _selectedCountryName = widget.initialCountryName;
      _selectedCityId = widget.initialCityId;
      _selectedCityName = widget.initialCityName;
    }
  }

  void _ensureLocationDataLoaded() {
    if (_locationController.countries.isEmpty) {
      _locationController.loadCountries();
    }

    if (_selectedCountryId != null) {
      _locationController.loadCitiesByCountry(_selectedCountryId!);
    }
  }

  void _handleSelection(LocationSelectionResult result, FormFieldState<LocationSelectionResult?> field) {
    setState(() {
      _selectedCountryId = result.countryId;
      _selectedCountryName = result.countryName;
      _selectedCityId = result.cityId;
      _selectedCityName = result.cityName;
    });
    field.didChange(result);
    widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelText = widget.label ?? l10n.city;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.required ? '$labelText *' : labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final isLoadingCountries = _locationController.isLoadingCountries.value;
          final isLoadingCities = _locationController.isLoadingCities.value;
          final isLoading = isLoadingCountries || isLoadingCities;

          return FormField<LocationSelectionResult?>(
            initialValue: _currentSelection,
            validator: (value) {
              final effectiveValue = value ?? _currentSelection;
              if (widget.validator != null) {
                return widget.validator!(effectiveValue);
              }
              if (!widget.enabled) {
                return null;
              }
              if (widget.required) {
                final hasCity =
                    (effectiveValue?.cityId?.isNotEmpty ?? false) || (effectiveValue?.cityName?.isNotEmpty ?? false);
                if (!hasCity) {
                  return l10n.selectCity;
                }
              }
              return null;
            },
            builder: (field) {
              String? displayText;
              final currentCity = _selectedCityName;
              final currentCountry = _selectedCountryName;
              if (currentCity != null && currentCity.isNotEmpty) {
                displayText = (currentCountry != null && currentCountry.isNotEmpty)
                    ? '$currentCity, $currentCountry'
                    : currentCity;
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (!widget.enabled || isLoading)
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        _showLocationPicker(l10n, field);
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: l10n.selectCity,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: (!widget.enabled || isLoading) ? Colors.grey[200] : Colors.white,
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            widget.enabled ? FontAwesomeIcons.chevronDown : FontAwesomeIcons.lock,
                            size: widget.enabled ? 18 : 16,
                            color: widget.enabled ? null : Colors.grey,
                          ),
                    errorText: field.errorText,
                  ),
                  isEmpty: displayText == null || displayText.isEmpty,
                  child: Text(
                    displayText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: displayText == null || displayText.isEmpty
                              ? Theme.of(context).hintColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  LocationSelectionResult? get _currentSelection => LocationSelectionResult(
        countryId: _selectedCountryId,
        countryName: _selectedCountryName,
        cityId: _selectedCityId,
        cityName: _selectedCityName,
      );

  void _showLocationPicker(AppLocalizations l10n, FormFieldState<LocationSelectionResult?> cityField) {
    final RxnString tempSelectedCountryId = RxnString(_selectedCountryId);
    final RxnString tempSelectedCountry = RxnString(_selectedCountryName);
    final RxnString tempSelectedCityId = RxnString(_selectedCityId);
    final RxnString tempSelectedCity = RxnString(_selectedCityName);

    final ScrollController countryScrollController = ScrollController();
    final ScrollController cityScrollController = ScrollController();

    if (_locationController.countries.isEmpty) {
      _locationController.loadCountries();
    }

    if (_selectedCountryId != null) {
      _locationController.loadCitiesByCountry(_selectedCountryId!);
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    l10n.selectCity,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(() => TextButton(
                        onPressed: tempSelectedCityId.value != null
                            ? () {
                                _handleSelection(
                                  LocationSelectionResult(
                                    countryId: tempSelectedCountryId.value,
                                    countryName: tempSelectedCountry.value,
                                    cityId: tempSelectedCityId.value,
                                    cityName: tempSelectedCity.value,
                                  ),
                                  cityField,
                                );
                                Get.back();
                              }
                            : null,
                        child: Text(
                          l10n.done,
                          style: TextStyle(
                            color: tempSelectedCityId.value != null ? const Color(0xFFFF4458) : Colors.grey,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              l10n.country,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(() {
                              final countryList = _locationController.countries;
                              final isLoadingCountries = _locationController.isLoadingCountries.value;
                              final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();

                              if (isLoadingCountries) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final countryEntries = countryList
                                  .where((country) => country.isActive)
                                  .map((country) => MapEntry(country, country.displayName(localeCode)))
                                  .where((entry) => entry.value.isNotEmpty)
                                  .toList()
                                ..sort((a, b) => a.value.compareTo(b.value));

                              if (tempSelectedCountryId.value != null) {
                                final selectedIndex =
                                    countryEntries.indexWhere((e) => e.key.id == tempSelectedCountryId.value);
                                if (selectedIndex > 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (countryScrollController.hasClients) {
                                      countryScrollController.animateTo(
                                        selectedIndex * 48.0,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                }
                              }

                              return ListView.builder(
                                controller: countryScrollController,
                                itemCount: countryEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = countryEntries[index];
                                  final country = entry.key;
                                  final displayName = entry.value;

                                  return Obx(() {
                                    final isSelected = tempSelectedCountryId.value == country.id;
                                    return ListTile(
                                      dense: true,
                                      selected: isSelected,
                                      selectedTileColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                                      title: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                      onTap: () {
                                        tempSelectedCountryId.value = country.id;
                                        tempSelectedCountry.value = displayName;
                                        tempSelectedCityId.value = null;
                                        tempSelectedCity.value = null;
                                        _locationController.loadCitiesByCountry(country.id);
                                      },
                                    );
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            l10n.city,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            final selectedCountryId = tempSelectedCountryId.value;
                            final cityMap = _locationController.citiesByCountry;
                            final _ = cityMap.length;
                            final isLoadingCities = _locationController.isLoadingCities.value;

                            if (selectedCountryId == null) {
                              return Center(
                                child: Text(
                                  l10n.selectCountryFirst,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              );
                            }

                            if (isLoadingCities) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final cities = cityMap[selectedCountryId] ?? <CityOption>[];
                            final sortedCities = List<CityOption>.from(cities)
                              ..sort((a, b) => a.name.compareTo(b.name));

                            if (sortedCities.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noData,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              );
                            }

                            if (tempSelectedCityId.value != null) {
                              final selectedIndex = sortedCities.indexWhere((c) => c.id == tempSelectedCityId.value);
                              if (selectedIndex > 0) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (cityScrollController.hasClients) {
                                    cityScrollController.animateTo(
                                      selectedIndex * 48.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                });
                              }
                            }

                            return ListView.builder(
                              controller: cityScrollController,
                              itemCount: sortedCities.length,
                              itemBuilder: (context, index) {
                                final city = sortedCities[index];

                                return Obx(() {
                                  final isSelected = tempSelectedCityId.value == city.id;
                                  return ListTile(
                                    dense: true,
                                    selected: isSelected,
                                    selectedTileColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                                    title: Text(
                                      city.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            FontAwesomeIcons.check,
                                            size: 14,
                                            color: Color(0xFFFF4458),
                                          )
                                        : null,
                                    onTap: () {
                                      tempSelectedCityId.value = city.id;
                                      tempSelectedCity.value = city.name;
                                    },
                                  );
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
