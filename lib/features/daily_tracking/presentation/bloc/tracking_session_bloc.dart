import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/tracking_unit_cache.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/mistake_type.dart';
import '../../../../core/utils/data_status.dart';

// Import your existing domain entities
import 'package:shafeea/core/models/tracking_type.dart';

// Import our new domain entities and use cases
import '../../../home/domain/entities/tracking_detail_entity.dart';
import '../../domain/entities/mistake.dart';
import '../../domain/usecases/get_all_mistakes.dart';
import '../../domain/usecases/get_or_create_today_tracking.dart';
import '../../domain/usecases/save_draft_mistakes_use_case.dart';
import '../../domain/usecases/save_task_progress.dart';
import '../../domain/usecases/generate_follow_up_report_use_case.dart';
import '../view_models/follow_up_report_bundle_entity.dart';
part 'tracking_session_event.dart';
part 'tracking_session_state.dart';

class TrackingSessionBloc
    extends Bloc<TrackingSessionEvent, TrackingSessionState> {
  final GetOrCreateTodayTrackingDetails _getOrCreateTodayTrackingDetails;
  final GetAllMistakes _getAllMistakes;
  final GenerateFollowUpReportUseCase _generateFollowUpReportUC;
  final SaveTaskProgress _saveTaskProgress;
  final SaveDraftMistakesUseCase _saveDraftMistakesUC;

  TrackingSessionBloc({
    required GetOrCreateTodayTrackingDetails getOrCreateTodayTrackingDetails,
    required GetAllMistakes getAllMistakes,
    required GenerateFollowUpReportUseCase generateFollowUpReportUC,
    required SaveTaskProgress saveTaskProgress,
    required SaveDraftMistakesUseCase saveDraftMistakesUC,
  }) : _getOrCreateTodayTrackingDetails = getOrCreateTodayTrackingDetails,
       _getAllMistakes = getAllMistakes,
       _generateFollowUpReportUC = generateFollowUpReportUC,
       _saveTaskProgress = saveTaskProgress,
       _saveDraftMistakesUC = saveDraftMistakesUC,

       super(const TrackingSessionState()) {
    on<SessionStarted>(_onSessionStarted);
    on<TaskTypeChanged>(_onTaskTypeChanged);
    on<WordTappedForMistake>(_onWordTappedForMistake);

    on<HistoricalMistakesRequested>(_onHistoricalMistakesRequested);
    on<RecitationRangeEnded>(_onRecitationRangeEnded);
    on<FollowUpReportFetched>(_onFetchReport, transformer: droppable());
  }
  Future<void> _onSessionStarted(
    SessionStarted event,
    Emitter<TrackingSessionState> emit,
  ) async {
    emit(state.copyWith(status: DataStatus.loading));

    // Using the updated use case
    final result = await _getOrCreateTodayTrackingDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DataStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (trackingData) {
        emit(
          state.copyWith(
            status: DataStatus.success,
            taskProgress: trackingData,
          ),
        );
      },
    );
  }

  void _onTaskTypeChanged(
    TaskTypeChanged event,
    Emitter<TrackingSessionState> emit,
  ) {
    emit(state.copyWith(status: DataStatus.loading));
    emit(
      state.copyWith(
        currentTaskType: event.newType,
        status: DataStatus.success,
      ),
    );
  }

  void _onRecitationRangeEnded(
    RecitationRangeEnded event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentDetail = state.currentTaskDetail;
    if (currentDetail == null) return;

    // Create a new TrackingUnitDetail for the end point
    //  double gap = double.parse("${event.pageCount}.${event.ayah}");

    int gapPageCount = event.pageNumber;

    int addedNumber = 0;

    while (gapPageCount > currentDetail.toTrackingUnitId.toPage &&
        TrackingUnitCache.instance
                .byIndex((currentDetail.toTrackingUnitId.id - 1) + addedNumber)
                .unitId ==
            currentDetail.toTrackingUnitId.unitId) {
      final row = TrackingUnitCache.instance.byIndex(
        (currentDetail.toTrackingUnitId.id - 1) + addedNumber,
      );
      gapPageCount -= (row.toAyah - row.fromAyah);
      ++addedNumber;
    }
    final newToTrackingUnitId = TrackingUnitCache.instance.byIndex(
      (currentDetail.toTrackingUnitId.id - 1) + addedNumber,
    );
    final gap = double.parse("$gapPageCount.${event.ayah}");

    // Manually rebuild the entity with the new `toTrackingUnitId`
    final updatedDetail = TrackingDetailEntity(
      id: currentDetail.id,
      uuid: currentDetail.uuid,
      trackingId: currentDetail.trackingId,
      trackingTypeId: currentDetail.trackingTypeId,
      fromTrackingUnitId: currentDetail.fromTrackingUnitId,
      toTrackingUnitId: newToTrackingUnitId.toEntity(),
      actualAmount: currentDetail.actualAmount,
      comment: currentDetail.comment,
      status: currentDetail.status,
      score: currentDetail.score,
      gap: gap,
      createdAt: currentDetail.createdAt,
      updatedAt: currentDetail.updatedAt,
      mistakes: currentDetail.mistakes,
    );
    await _updateStateWithNewDetail(emit, updatedDetail);
  }

  void _onWordTappedForMistake(
    WordTappedForMistake event,
    Emitter<TrackingSessionState> emit,
  ) async {
    final currentTaskDetail = state.currentTaskDetail;

    if (currentTaskDetail == null) return;

    final List<Mistake> updatedMistakes = List.from(currentTaskDetail.mistakes);
    final existingMistake = updatedMistakes.firstWhereOrNull(
      (m) => m.ayahIdQuran == event.ayahId && m.wordIndex == event.wordIndex,
    );

    if (existingMistake != null) {
      updatedMistakes.remove(existingMistake);
    } else {
      final newMistake = Mistake(
        id: const Uuid().v4(),
        trackingDetailId: "${currentTaskDetail.id}",
        ayahIdQuran: event.ayahId,
        wordIndex: event.wordIndex,
        mistakeType: event.newMistakeType,
      );
      updatedMistakes.add(newMistake);
    }

    final updatedTaskDetail = TrackingDetailEntity(
      id: currentTaskDetail.id,
      uuid: currentTaskDetail.uuid,
      trackingId: currentTaskDetail.trackingId,
      trackingTypeId: currentTaskDetail.trackingTypeId,
      fromTrackingUnitId: currentTaskDetail.fromTrackingUnitId,
      toTrackingUnitId: currentTaskDetail.toTrackingUnitId,
      actualAmount: currentTaskDetail.actualAmount,
      comment: currentTaskDetail.comment,
      status: currentTaskDetail.status,
      score: currentTaskDetail.score,
      gap: currentTaskDetail.gap,
      createdAt: currentTaskDetail.createdAt,
      updatedAt: currentTaskDetail.updatedAt,
      mistakes: updatedMistakes, // <-- PASS THE UPDATED MISTAKES LIST
    );
    // ========================================================

    final updatedProgress = Map<TrackingType, TrackingDetailEntity>.from(
      state.taskProgress,
    );

    updatedProgress[state.currentTaskType] = updatedTaskDetail;

    emit(state.copyWith(taskProgress: updatedProgress));

    await _saveDraftMistakesUC(updatedMistakes);
  }

  // The helper method remains the same and is still very useful.
  Future<void> _updateStateWithNewDetail(
    Emitter<TrackingSessionState> emit,
    TrackingDetailEntity updatedDetail,
  ) async {
    final updatedProgress = Map<TrackingType, TrackingDetailEntity>.from(
      state.taskProgress,
    );

    updatedProgress[state.currentTaskType] = updatedDetail;
    emit(state.copyWith(taskProgress: updatedProgress));
    // Then, call the use case to persist this final entity to the database.
    emit(state.copyWith(status: DataStatus.loading));
    final result = await _saveTaskProgress(
      SaveTaskProgressParams(detail: updatedDetail),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: DataStatus.success)),
    );
  }

  // In TrackingSessionBloc
  Future<void> _onHistoricalMistakesRequested(
    HistoricalMistakesRequested event,
    Emitter<TrackingSessionState> emit,
  ) async {
    emit(state.copyWith(historicalMistakesStatus: DataStatus.loading));

    // Call the UseCase without a type to fetch all mistakes.
    final result = await _getAllMistakes(
      GetAllMistakesParams(
        // No type specified, so we get all types.
        // We can pass page filters from the event if needed.
        fromPage: event.fromPage,
        toPage: event.toPage,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          historicalMistakesStatus: DataStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (allMistakesList) {
        emit(
          state.copyWith(
            historicalMistakesStatus: DataStatus.success,
            historicalMistakes: allMistakesList,
          ),
        );
      },
    );
  }

  Future<void> _onFetchReport(
    FollowUpReportFetched event,
    Emitter<TrackingSessionState> emit,
  ) async {
    emit(
      state.copyWith(
        followUpReportStatus: FollowUpReportStatus.loading,
        clearFollowUpReportFailure: true,
      ),
    );

    final result = await _generateFollowUpReportUC();

    result.fold(
      (failure) => emit(
        state.copyWith(followUpReportStatus: FollowUpReportStatus.failure),
      ),
      (followUpReport) {
        emit(
          state.copyWith(
            followUpReportStatus: FollowUpReportStatus.success,
            followUpReport: followUpReport,
          ),
        );
      },
    );
  }
}
