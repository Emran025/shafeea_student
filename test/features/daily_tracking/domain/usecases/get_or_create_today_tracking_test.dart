// test/features/daily_tracking/domain/usecases/get_or_create_today_tracking_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/entities/tracking_unit.dart';
import 'package:shafeea/features/home/domain/entities/tracking_detail_entity.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_or_create_today_tracking.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetOrCreateTodayTrackingDetails usecase;
  late MockTrackingRepository mockTrackingRepository;

  setUp(() {
    mockTrackingRepository = MockTrackingRepository();
    usecase = GetOrCreateTodayTrackingDetails(mockTrackingRepository);
  });

  final tTrackingDetails = {
    TrackingType.memorization: TrackingDetailEntity(
      id: 1,
      uuid: 'uuid-1',
      trackingId: 'tracking-1',
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
    ),
  };

  test('should get today tracking details from the repository', () async {
    // arrange
    when(
      () => mockTrackingRepository.getOrCreateTodayDraftTrackingDetails(),
    ).thenAnswer((_) async => Right(tTrackingDetails));

    // act
    final result = await usecase();

    // assert
    expect(result, Right(tTrackingDetails));
    verify(() => mockTrackingRepository.getOrCreateTodayDraftTrackingDetails());
    verifyNoMoreInteractions(mockTrackingRepository);
  });
}
