import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/pages/profile/domain/entities/profile_snapshot.dart';

abstract class IProfileSnapshotRepository {
  Future<Result<ProfileSnapshot>> getProfileSnapshot();
}
