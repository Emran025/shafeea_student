import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/features/home/data/models/tracking_detail_model.dart';
import 'package:shafeea/core/models/bar_chart_datas.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';

import '../models/mistake_model.dart';

/// Abstract contract for the local data source for interactive tracking operations.
///
/// This defines the capabilities of the data source, separating the "what" from the "how".
/// The repository layer will depend on this contract, not the concrete implementation.
abstract class TrackingLocalDataSource {
  // =========================================================================
  //                             Core Public Methods
  // =========================================================================

  /// Fetches or creates today's DRAFT tracking details for a given enrollment ID.
  ///
  /// - If a draft record for today exists, it's fetched along with its details and mistakes.
  /// - If not, a new draft record is created. The starting point (`fromTrackingUnitId`)
  ///   is intelligently determined from the student's last completed session.
  ///
  /// Returns a map where the key is the `TrackingType` and the value is the
  /// fully assembled `TrackingDetailModel` (including mistakes).
  Future<Map<TrackingType, TrackingDetailModel>>
  getOrCreateTodayDraftTrackingDetails();

  /// Persists the current state of a list of tracking details to the database.
  ///
  /// This is intended for autosaving the "draft" session. It performs a transactional
  /// update, ensuring data integrity. It updates the detail record (e.g., score, comment),
  /// overwrites the associated mistakes with the latest list, and queues the
  /// operation for future synchronization.
  Future<void> saveDraftTrackingDetails(List<TrackingDetailModel> details);

  // =========================================================================
  //                      All Mistake Methods
  // =========================================================================

  // ... other methods

  Future<List<MistakeModel>> getAllMistakes({
    TrackingType? type, // <-- NOW OPTIONAL
    int? fromPage,
    int? toPage,
  });

  Future<List<BarChartDatas>> getErrorAnalysisChartData({
    required ChartFilter filter,
  });

  Future<void> saveDraftMistakes({ required List<MistakeModel> mistakes});
}
