import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/city_detail_controller.dart';
import '../generated/app_localizations.dart';
import '../widgets/app_toast.dart';
import 'amap_native_picker_page.dart';
import 'travel_plan_page.dart';

/// 创建旅行计划页面 - 完整页面版本
class CreateTravelPlanPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CreateTravelPlanPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CreateTravelPlanPage> createState() => _CreateTravelPlanPageState();
}

class _CreateTravelPlanPageState extends State<CreateTravelPlanPage> {
  int duration = 7;
  String budget = 'medium';
  String travelStyle = 'culture';
  List<String> interests = [];
  String departureLocation = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFF4458),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiTravelPlanner,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      l10n.planYourTrip(widget.cityName),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            l10n.aiPoweredPlanning,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tellPreferences(widget.cityName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Form Section
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Departure Location
                      _buildSectionTitle(
                          l10n.departureLocation, Icons.location_on_outlined),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: departureLocation),
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
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF4458),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: departureLocation.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            departureLocation = '';
                                          });
                                        },
                                      )
                                    : null,
                              ),
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
                                  color: const Color(0xFFFF4458)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.map_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  final result = await Get.to(
                                    () => const AmapNativePickerPage(),
                                  );
                                  if (result != null && result is Map) {
                                    final address =
                                        result['address'] as String? ?? '';
                                    setState(() {
                                      departureLocation = address;
                                    });
                                  }
                                } catch (e) {
                                  AppToast.error(
                                    '${l10n.failedToOpenMap}: $e',
                                    title: l10n.error,
                                  );
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Trip Duration
                      _buildSectionTitle(
                          l10n.tripDuration, Icons.calendar_today_outlined),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Slider(
                              value: duration.toDouble(),
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: l10n.days(duration),
                              activeColor: const Color(0xFFFF4458),
                              inactiveColor: Colors.grey[300],
                              onChanged: (value) {
                                setState(() => duration = value.toInt());
                              },
                            ),
                            Text(
                              duration == 1 ? l10n.day(1) : l10n.days(duration),
                              style: const TextStyle(
                                color: Color(0xFFFF4458),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Budget Level
                      _buildSectionTitle(
                          l10n.budget, Icons.attach_money_outlined),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildBudgetChip(l10n.low, budget == 'low', () {
                              setState(() => budget = 'low');
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBudgetChip(
                                l10n.medium, budget == 'medium', () {
                              setState(() => budget = 'medium');
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBudgetChip(l10n.high, budget == 'high',
                                () {
                              setState(() => budget = 'high');
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Travel Style
                      _buildSectionTitle(
                          l10n.travelStyle, Icons.style_outlined),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStyleChip(
                              l10n.culture, 'culture', Icons.museum_outlined),
                          _buildStyleChip(l10n.adventure, 'adventure',
                              Icons.landscape_outlined),
                          _buildStyleChip(l10n.relaxation, 'relaxation',
                              Icons.spa_outlined),
                          _buildStyleChip(
                              l10n.foodie, 'food', Icons.restaurant_outlined),
                          _buildStyleChip(l10n.nightlife, 'nightlife',
                              Icons.nightlife_outlined),
                          _buildStyleChip(l10n.shopping, 'shopping',
                              Icons.shopping_bag_outlined),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Interests
                      _buildSectionTitle(
                          l10n.interests, Icons.interests_outlined),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInterestChip(l10n.photography),
                          _buildInterestChip(l10n.history),
                          _buildInterestChip('Art'),
                          _buildInterestChip(l10n.nature),
                          _buildInterestChip('Beach'),
                          _buildInterestChip('Temples'),
                          _buildInterestChip('Markets'),
                          _buildInterestChip('Coffee'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => _generatePlan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.generatePlan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
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

  Widget _buildBudgetChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(String label, String value, IconData icon) {
    final isSelected = travelStyle == value;
    return GestureDetector(
      onTap: () {
        setState(() => travelStyle = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    final isSelected = interests.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            interests.remove(label);
          } else {
            interests.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _generatePlan() {
    final controller = Get.find<CityDetailController>();

    // Navigate to TravelPlanPage with all parameters
    Get.to(
      () => TravelPlanPage(
        cityId: widget.cityId,
        cityName: widget.cityName,
        duration: duration,
        budget: budget,
        travelStyle: travelStyle,
        interests: interests,
        departureLocation: departureLocation,
      ),
    );

    // Show generating message
    controller.isGeneratingPlan.value = true;
  }
}
