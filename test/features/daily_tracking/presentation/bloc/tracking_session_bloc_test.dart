// test/features/daily_tracking/presentation/bloc/tracking_session_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/utils/data_status.dart';
import 'package:shafeea/features/daily_tracking/presentation/bloc/tracking_session_bloc.dart';
import 'package:shafeea/features/home/domain/entities/tracking_detail_entity.dart';
import 'package:shafeea/core/entities/tracking_unit.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/daily_tracking/presentation/view_models/follow_up_report_bundle_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late TrackingSessionBloc bloc;
  late MockGetOrCreateTodayTrackingDetails mockGetOrCreateTodayTrackingDetails;
  late MockGetAllMistakes mockGetAllMistakes;
  late MockGenerateFollowUpReportUseCase mockGenerateFollowUpReportUC;
  late MockSaveTaskProgress mockSaveTaskProgress;
  late MocksaveDraftMistakes mockSaveDraftMistakes;

  setUp(() {
    mockGetOrCreateTodayTrackingDetails = MockGetOrCreateTodayTrackingDetails();
    mockGetAllMistakes = MockGetAllMistakes();
    mockGenerateFollowUpReportUC = MockGenerateFollowUpReportUseCase();
    mockSaveTaskProgress = MockSaveTaskProgress();
    mockSaveDraftMistakes = MocksaveDraftMistakes();

    bloc = TrackingSessionBloc(
      getOrCreateTodayTrackingDetails: mockGetOrCreateTodayTrackingDetails,
      getAllMistakes: mockGetAllMistakes,
      generateFollowUpReportUC: mockGenerateFollowUpReportUC,
      saveTaskProgress: mockSaveTaskProgress,
      saveDraftMistakesUC: mockSaveDraftMistakes,
    );
  });

  registerFallbackValues();

  final tTrackingDetail = TrackingDetailEntity(
    id: 1,
    uuid: 'uuid-1',
    trackingId: '1',
    trackingTypeId: TrackingType.memorization,
    fromTrackingUnitId: TrackingUnitDetail(
      1,
      1,
      'Al-Baqarah',
      1,
      1,
      'Al-Baqarah',
      1,
      7,
    ),
    toTrackingUnitId: TrackingUnitDetail(
      1,
      1,
      'Al-Baqarah',
      1,
      1,
      'Al-Baqarah',
      1,
      7,
    ),
    actualAmount: 7,
    comment: 'Excellent',
    status: 'completed',
    score: 10,
    gap: 0.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    mistakes: [],
  );

  final tTrackingData = {TrackingType.memorization: tTrackingDetail};

  group('SessionStarted', () {
    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, success] when session is started successfully',
      build: () {
        when(
          () => mockGetOrCreateTodayTrackingDetails(),
        ).thenAnswer((_) async => Right(tTrackingData));
        return bloc;
      },
      act: (bloc) => bloc.add(const SessionStarted()),
      expect: () => [
        const TrackingSessionState(status: DataStatus.loading),
        TrackingSessionState(
          status: DataStatus.success,
          taskProgress: tTrackingData,
        ),
      ],
      verify: (_) {
        verify(() => mockGetOrCreateTodayTrackingDetails()).called(1);
      },
    );

    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, failure] when session starting fails',
      build: () {
        when(
          () => mockGetOrCreateTodayTrackingDetails(),
        ).thenAnswer((_) async => const Left(CacheFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SessionStarted()),
      expect: () => [
        const TrackingSessionState(status: DataStatus.loading),
        const TrackingSessionState(
          status: DataStatus.failure,
          errorMessage: 'Error',
        ),
      ],
    );
  });

  group('TaskTypeChanged', () {
    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, success] with updated task type',
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const TaskTypeChanged(newType: TrackingType.review)),
      expect: () => [
        const TrackingSessionState(status: DataStatus.loading),
        const TrackingSessionState(
          status: DataStatus.success,
          currentTaskType: TrackingType.review,
        ),
      ],
    );
  });

  group('HistoricalMistakesRequested', () {
    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, success] with mistakes when requested successfully',
      build: () {
        when(
          () => mockGetAllMistakes(any()),
        ).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const HistoricalMistakesRequested()),
      expect: () => [
        const TrackingSessionState(
          historicalMistakesStatus: DataStatus.loading,
        ),
        const TrackingSessionState(
          historicalMistakesStatus: DataStatus.success,
          historicalMistakes: [],
        ),
      ],
    );

    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, failure] when requesting mistakes fails',
      build: () {
        when(
          () => mockGetAllMistakes(any()),
        ).thenAnswer((_) async => const Left(CacheFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const HistoricalMistakesRequested()),
      expect: () => [
        const TrackingSessionState(
          historicalMistakesStatus: DataStatus.loading,
        ),
        const TrackingSessionState(
          historicalMistakesStatus: DataStatus.failure,
          errorMessage: 'Error',
        ),
      ],
    );
  });

  group('RecitationRangeEnded', () {
    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should update progress and emit [loading, success] when range ends',
      build: () {
        when(
          () => mockSaveTaskProgress(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      seed: () => TrackingSessionState(
        taskProgress: tTrackingData,
        status: DataStatus.success,
      ),
      act: (bloc) =>
          bloc.add(const RecitationRangeEnded(pageNumber: 1, ayah: 7)),
      expect: () => [
        isA<TrackingSessionState>().having(
          (s) => s.taskProgress[TrackingType.memorization]?.gap,
          'gap',
          1.7,
        ),
        isA<TrackingSessionState>().having(
          (s) => s.status,
          'status',
          DataStatus.loading,
        ),
        isA<TrackingSessionState>().having(
          (s) => s.status,
          'status',
          DataStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => mockSaveTaskProgress(any())).called(1);
      },
    );
  });

  group('FollowUpReportFetched', () {
    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, success] when report is fetched successfully',
      build: () {
        when(
          () => mockGenerateFollowUpReportUC(),
        ).thenAnswer((_) async => Right(MockFollowUpReportBundleEntity()));
        return bloc;
      },
      act: (bloc) => bloc.add(const FollowUpReportFetched()),
      expect: () => [
        const TrackingSessionState(
          followUpReportStatus: FollowUpReportStatus.loading,
        ),
        isA<TrackingSessionState>().having(
          (s) => s.followUpReportStatus,
          'status',
          FollowUpReportStatus.success,
        ),
      ],
    );

    blocTest<TrackingSessionBloc, TrackingSessionState>(
      'should emit [loading, failure] when report fetching fails',
      build: () {
        when(
          () => mockGenerateFollowUpReportUC(),
        ).thenAnswer((_) async => const Left(CacheFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FollowUpReportFetched()),
      expect: () => [
        const TrackingSessionState(
          followUpReportStatus: FollowUpReportStatus.loading,
        ),
        const TrackingSessionState(
          followUpReportStatus: FollowUpReportStatus.failure,
        ),
      ],
    );
  });
}

class MockFollowUpReportBundleEntity extends Mock
    implements FollowUpReportBundleEntity {}
