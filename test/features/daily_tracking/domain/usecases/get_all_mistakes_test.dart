// test/features/daily_tracking/domain/usecases/get_all_mistakes_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/models/mistake_type.dart';
import 'package:shafeea/features/daily_tracking/domain/entities/mistake.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_all_mistakes.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetAllMistakes usecase;
  late MockTrackingRepository mockTrackingRepository;

  setUp(() {
    mockTrackingRepository = MockTrackingRepository();
    usecase = GetAllMistakes(mockTrackingRepository);
  });

  const tMistakes = [
    Mistake(
      id: 'uuid-1',
      trackingDetailId: 'td-1',
      ayahIdQuran: 1,
      wordIndex: 5,
      mistakeType: MistakeType.memory,
    ),
  ];

  test('should get all mistakes from the repository', () async {
    // arrange
    when(
      () => mockTrackingRepository.getAllMistakes(
        type: any(named: 'type'),
        fromPage: any(named: 'fromPage'),
        toPage: any(named: 'toPage'),
      ),
    ).thenAnswer((_) async => Right(tMistakes));

    // act
    final result = await usecase(
      const GetAllMistakesParams(type: TrackingType.memorization),
    );

    // assert
    expect(result, Right(tMistakes));
    verify(
      () => mockTrackingRepository.getAllMistakes(
        type: TrackingType.memorization,
        fromPage: null,
        toPage: null,
      ),
    );
    verifyNoMoreInteractions(mockTrackingRepository);
  });
}
