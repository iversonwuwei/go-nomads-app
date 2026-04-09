import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/land_hub_snapshot.dart';

abstract class ILandHubRepository {
  Future<Result<LandHubSnapshot>> getLandHub();
}
