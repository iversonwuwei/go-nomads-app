import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';

class ProfileSnapshot {
  final User user;
  final NomadStats nomadStats;
  final List<String> favoriteCityIds;
  final TravelPlanSummary? latestTravelPlan;
  final City? nextDestinationCity;
  final DateTime lastUpdatedAt;

  const ProfileSnapshot({
    required this.user,
    required this.nomadStats,
    required this.favoriteCityIds,
    required this.latestTravelPlan,
    required this.nextDestinationCity,
    required this.lastUpdatedAt,
  });
}
