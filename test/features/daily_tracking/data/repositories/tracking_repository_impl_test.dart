// test/features/daily_tracking/data/repositories/tracking_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/core/models/report_frequency.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/features/daily_tracking/data/repositories/tracking_repository_impl.dart';
import 'package:shafeea/features/home/data/models/follow_up_plan_model.dart';
import 'package:shafeea/features/home/data/models/tracking_detail_model.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';
import 'package:shafeea/core/models/tracking_unit_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late TrackingRepositoryImpl repository;
  late MockTrackingLocalDataSource mockLocalDataSource;
  late MockStudentLocalDataSource mockStudentLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockTrackingLocalDataSource();
    mockStudentLocalDataSource = MockStudentLocalDataSource();
    repository = TrackingRepositoryImpl(
      localDataSource: mockLocalDataSource,
      studentLocalDataSource: mockStudentLocalDataSource,
    );
  });

  final tTrackingDetailModel = TrackingDetailModel(
    id: 1,
    uuid: 'uuid-1',
    trackingId: 1,
    trackingTypeId: TrackingType.memorization,
    fromTrackingUnitId: TrackingUnitDetailModel(
     id:  1,
     unitId:  1,
     fromSurahName:  'Al-Baqarah',
     fromPage:  1,
     fromAyah:  1,
     toSurahName:  'Al-Baqarah',
     toPage:  1,
     toAyah:  7,
    ),
    toTrackingUnitId: TrackingUnitDetailModel(
     id:  1,
     unitId: 1,
     fromSurahName: 'Al-Baqarah',
     fromPage: 1,
     fromAyah: 1,
     toSurahName: 'Al-Baqarah',
     toPage: 1,
     toAyah: 7,
    ),
    actualAmount: 7,
    comment: 'Excellent',
    score: 10,
    status: 'completed',
    createdAt: '2024-01-01T00:00:00.000',
    updatedAt: '2024-01-01T00:00:00.000',
    mistakes: [],
  );

  final tTrackingDetailEntity = tTrackingDetailModel.toEntity();

  group('getOrCreateTodayDraftTrackingDetails', () {
    test(
      'should return mapping of tracking details when call to local data source is successful',
      () async {
        // arrange
        final tModelsMap = {TrackingType.memorization: tTrackingDetailModel};
        when(
          () => mockLocalDataSource.getOrCreateTodayDraftTrackingDetails(),
        ).thenAnswer((_) async => tModelsMap);

        // act
        final result = await repository.getOrCreateTodayDraftTrackingDetails();

        // assert
        verify(
          () => mockLocalDataSource.getOrCreateTodayDraftTrackingDetails(),
        );
        expect(result.isRight(), true);
      },
    );

    test(
      'should return CacheFailure when call to local data source is unsuccessful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getOrCreateTodayDraftTrackingDetails(),
        ).thenThrow(CacheException(message: 'Cache Error'));

        // act
        final result = await repository.getOrCreateTodayDraftTrackingDetails();

        // assert
        verify(
          () => mockLocalDataSource.getOrCreateTodayDraftTrackingDetails(),
        );
        expect(result, const Left(CacheFailure(message: 'Cache Error')));
      },
    );
  });

  group('saveDraftTaskProgress', () {
    test(
      'should return unit when call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.saveDraftTrackingDetails(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.saveDraftTaskProgress(
          tTrackingDetailEntity,
        );

        // assert
        expect(result, const Right(unit));
      },
    );

    test(
      'should return CacheFailure when call to local data source is unsuccessful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.saveDraftTrackingDetails(any()),
        ).thenThrow(CacheException(message: 'Cache Error'));

        // act
        final result = await repository.saveDraftTaskProgress(
          tTrackingDetailEntity,
        );

        // assert
        expect(result, const Left(CacheFailure(message: 'Cache Error')));
      },
    );
  });

  group('getAllMistakes', () {
    test(
      'should return list of mistakes when call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getAllMistakes(
            type: any(named: 'type'),
            fromPage: any(named: 'fromPage'),
            toPage: any(named: 'toPage'),
          ),
        ).thenAnswer((_) async => []);

        // act
        final result = await repository.getAllMistakes(
          type: TrackingType.memorization,
        );

        // assert
        verify(
          () => mockLocalDataSource.getAllMistakes(
            type: TrackingType.memorization,
          ),
        );
        expect(result.isRight(), true);
      },
    );
  });

  group('getErrorAnalysisChartData', () {
    test(
      'should return bar chart data when call to local data source is successful',
      () async {
        // arrange
        const tFilter = ChartFilter(timePeriod: 'month');
        when(
          () => mockLocalDataSource.getErrorAnalysisChartData(
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => []);

        // act
        final result = await repository.getErrorAnalysisChartData(
          filter: tFilter,
        );

        // assert
        verify(
          () => mockLocalDataSource.getErrorAnalysisChartData(filter: tFilter),
        );
        expect(result.isRight(), true);
      },
    );
  });

  group('getFollowUpPlan', () {
    test(
      'should return follow up plan when call to student local data source is successful',
      () async {
        // arrange
        final tPlanModel = FollowUpPlanModel(
          planId: '1',
          frequency: Frequency.daily,
          serverPlanId: '1',
          details: [],
        );
        when(
          () => mockStudentLocalDataSource.getFollowUpPlan(),
        ).thenAnswer((_) async => tPlanModel);

        // act
        final result = await repository.getFollowUpPlan();

        // assert
        verify(() => mockStudentLocalDataSource.getFollowUpPlan());
        expect(result.isRight(), true);
      },
    );

    test(
      'should return ServerFailure when student local data source throws ServerException',
      () async {
        // arrange
        when(
          () => mockStudentLocalDataSource.getFollowUpPlan(),
        ).thenThrow(ServerException(message: 'Server Error'));

        // act
        final result = await repository.getFollowUpPlan();

        // assert
        expect(result, const Left(ServerFailure(message: 'Server Error')));
      },
    );
  });

  group('getFollowUpTrackings', () {
    test(
      'should return list of trackings when call to student local data source is successful',
      () async {
        // arrange
        when(
          () => mockStudentLocalDataSource.getFollowUpTrackings(),
        ).thenAnswer((_) async => []);

        // act
        final result = await repository.getFollowUpTrackings();

        // assert
        verify(() => mockStudentLocalDataSource.getFollowUpTrackings());
        expect(result.isRight(), true);
      },
    );
  });
}
