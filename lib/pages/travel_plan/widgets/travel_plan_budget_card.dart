import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 预算卡片组件 - 无状态组件
class TravelPlanBudgetCard extends StatelessWidget {
  final TripBudget budget;
  final String transportationLabel;
  final String accommodationLabel;
  final String foodLabel;
  final String activitiesLabel;
  final String miscellaneousLabel;
  final String totalLabel;

  const TravelPlanBudgetCard({
    super.key,
    required this.budget,
    required this.transportationLabel,
    required this.accommodationLabel,
    required this.foodLabel,
    required this.activitiesLabel,
    required this.miscellaneousLabel,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildBudgetRow(transportationLabel, budget.transportation),
          Divider(height: 24),
          _buildBudgetRow(accommodationLabel, budget.accommodation),
          Divider(height: 24),
          _buildBudgetRow(foodLabel, budget.food),
          Divider(height: 24),
          _buildBudgetRow(activitiesLabel, budget.activities),
          Divider(height: 24),
          _buildBudgetRow(miscellaneousLabel, budget.miscellaneous),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${budget.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4458),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 交通卡片组件 - 无状态组件
class TravelPlanTransportationCard extends StatelessWidget {
  final TripTransportation transportation;
  final String estimatedCostLabel;

  const TravelPlanTransportationCard({
    super.key,
    required this.transportation,
    required this.estimatedCostLabel,
  });

  @override
  Widget build(BuildContext context) {
    // 解析航班推荐信息
    final arrivalDetails = transportation.arrival?.details ?? '';
    final flightRecommendationIndex = arrivalDetails.indexOf('\n\n航班推荐：\n');

    String generalInfo = arrivalDetails;
    List<String> flights = [];

    if (flightRecommendationIndex != -1) {
      generalInfo = arrivalDetails.substring(0, flightRecommendationIndex);
      final flightSection = arrivalDetails.substring(flightRecommendationIndex + 8);
      flights = flightSection.split('\n').where((line) => line.trim().isNotEmpty).toList();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 到达交通
          Row(
            children: [
              Icon(FontAwesomeIcons.plane, color: Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                transportation.arrival?.method ?? 'N/A',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            generalInfo,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),

          // 航班推荐卡片
          if (flights.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _FlightRecommendations(flights: flights),
          ],

          SizedBox(height: 12.h),
          // 预计费用
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$estimatedCostLabel:'),
                Text(
                  '\$${transportation.arrival?.estimatedCost.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),

          // 本地交通
          Row(
            children: [
              Icon(FontAwesomeIcons.trainSubway, color: Color(0xFFFF4458), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                transportation.localTransport?.method ?? 'N/A',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            transportation.localTransport?.details ?? 'No details available',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// 航班推荐组件
class _FlightRecommendations extends StatelessWidget {
  final List<String> flights;

  const _FlightRecommendations({required this.flights});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF4458).withValues(alpha: 0.05),
            const Color(0xFFFF6B7A).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFF4458).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.plane,
                color: Color(0xFFFF4458),
                size: 18.r,
              ),
              SizedBox(width: 6.w),
              Text(
                '航班推荐',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF4458),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${flights.length}个选择',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...flights.asMap().entries.map((entry) {
            final index = entry.key;
            final flight = entry.value;
            return _FlightCard(
              flight: flight,
              isLast: index == flights.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

/// 航班卡片组件
class _FlightCard extends StatelessWidget {
  final String flight;
  final bool isLast;

  const _FlightCard({required this.flight, required this.isLast});

  @override
  Widget build(BuildContext context) {
    // 解析航班信息
    final parts = flight.split(' - ');
    if (parts.length < 2) {
      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
        child: Text(
          flight,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    // 解析第一部分：航空公司 航班号 (时段)
    final firstPart = parts[0];
    final timeSlotMatch = RegExp(r'\(([^)]+)\)').firstMatch(firstPart);
    final timeSlot = timeSlotMatch?.group(1) ?? '';
    final airlineAndFlight = firstPart.replaceAll(RegExp(r'\s*\([^)]+\)'), '').trim();

    // 解析第二部分：价格, 时长
    final secondPart = parts[1];
    final priceDuration = secondPart.split(', ');
    final price = priceDuration.isNotEmpty ? priceDuration[0].trim() : '';
    final duration = priceDuration.length > 1 ? priceDuration[1].trim() : '';

    // 备注
    final notes = parts.length > 2 ? parts.sublist(2).join(' - ') : '';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 航空公司和航班号
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airlineAndFlight.split(' ')[0], // 航空公司
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      airlineAndFlight.split(' ').skip(1).join(' '), // 航班号
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 时段标签
              if (timeSlot.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getTimeSlotColor(timeSlot),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    timeSlot,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          // 价格和时长
          Wrap(
            spacing: 12.w,
            runSpacing: 8.w,
            children: [
              _InfoTag(
                icon: FontAwesomeIcons.dollarSign,
                label: price,
                iconColor: Colors.green[600],
                backgroundColor: Colors.green.withValues(alpha: 0.08),
              ),
              _InfoTag(
                icon: FontAwesomeIcons.clock,
                label: duration,
                iconColor: Colors.indigo[500],
                backgroundColor: Colors.indigo.withValues(alpha: 0.07),
              ),
            ],
          ),
          // 备注信息
          if (notes.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(FontAwesomeIcons.circleInfo, size: 14.r, color: Colors.blue[400]),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTimeSlotColor(String timeSlot) {
    if (timeSlot.contains('早')) {
      return Colors.orange;
    } else if (timeSlot.contains('午')) {
      return Colors.blue;
    } else if (timeSlot.contains('晚')) {
      return Colors.purple;
    }
    return Colors.grey;
  }
}

/// 信息标签组件
class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;

  const _InfoTag({
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor ?? Colors.grey[700]),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
