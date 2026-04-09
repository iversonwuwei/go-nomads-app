import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/pages/home/domain/entities/explore_dashboard_snapshot.dart';

abstract class IExploreDashboardRepository {
  Future<Result<ExploreDashboardSnapshot>> getExploreDashboard();
}
