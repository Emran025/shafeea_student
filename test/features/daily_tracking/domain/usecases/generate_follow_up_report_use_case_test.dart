// test/features/daily_tracking/domain/usecases/generate_follow_up_report_use_case_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/report_frequency.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/generate_follow_up_report_use_case.dart';
import 'package:shafeea/features/daily_tracking/presentation/view_models/follow_up_report_bundle_entity.dart';
import 'package:shafeea/features/daily_tracking/presentation/view_models/student_summary_entity.dart';
import 'package:shafeea/features/daily_tracking/presentation/view_models/student_performance_metrics_entity.dart';
import 'package:shafeea/features/home/domain/entities/follow_up_plan_entity.dart';
import 'package:shafeea/features/home/domain/entities/tracking_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GenerateFollowUpReportUseCase usecase;
  late MockTrackingRepository mockTrackingRepository;
  late MockFollowUpReportFactory mockFactory;

  setUp(() {
    mockTrackingRepository = MockTrackingRepository();
    mockFactory = MockFollowUpReportFactory();
    usecase = GenerateFollowUpReportUseCase(
      mockTrackingRepository,
      mockFactory,
    );
  });

  const tPlan = FollowUpPlanEntity(
    planId: '1',
    frequency: Frequency.daily,
    serverPlanId: '1',
    details: [],
  );
  final tTrackings = <TrackingEntity>[];
  const tReportBundle = FollowUpReportBundleEntity(
    followUpReports: [],
    summary: StudentSummaryEntity(
      totalPendingReports: 2,
      totalDeviation: 0,
      status: PerformanceStatus.onTrack,
      studentPerformance: StudentPerformanceMetricsEntity(
        averageBehaviourScore: 0,
        averageAchievementRate: 0,
        averageExecutionQuality: 0,
        reportCount: 0,
      ),
    ),
  );

  test(
    'should generate follow up report bundle from repository and factory',
    () async {
      // arrange
      when(
        () => mockTrackingRepository.getFollowUpPlan(),
      ).thenAnswer((_) async => const Right(tPlan));
      when(
        () => mockTrackingRepository.getFollowUpTrackings(),
      ).thenAnswer((_) async => Right(tTrackings));
      when(
        () => mockFactory.create(
          plan: any(named: 'plan'),
          trackings: any(named: 'trackings'),
          totalPendingReports: any(named: 'totalPendingReports'),
        ),
      ).thenReturn(tReportBundle);

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(tReportBundle));
      verify(() => mockTrackingRepository.getFollowUpPlan()).called(1);
      verify(() => mockTrackingRepository.getFollowUpTrackings()).called(1);
      verify(
        () => mockFactory.create(
          plan: tPlan,
          trackings: tTrackings,
          totalPendingReports: 2,
        ),
      ).called(1);
    },
  );
}
