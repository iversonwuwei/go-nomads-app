import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/inbox_summary.dart';

abstract class IInboxSummaryRepository {
  Future<Result<InboxSummary>> getInboxSummary({int recentLimit = 5});
}