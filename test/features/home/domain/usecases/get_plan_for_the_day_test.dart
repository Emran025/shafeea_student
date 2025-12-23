// test/features/home/domain/usecases/get_plan_for_the_day_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/home/domain/entities/plan_for_the_day_entity.dart';
import 'package:shafeea/features/home/domain/usecases/get_plan_for_the_day.dart';
import 'package:shafeea/features/home/domain/usecases/usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetPlanForTheDay useCase;
  late MockStudentRepository mockStudentRepository;

  setUp(() {
    mockStudentRepository = MockStudentRepository();
    useCase = GetPlanForTheDay(mockStudentRepository);
  });

  group('GetPlanForTheDay', () {
    final tPlan = PlanForTheDayEntity(
      endDate: DateTime(2025, 12, 31),
      section: [],
    );

    test('should get plan for the day from the repository', () async {
      // Arrange
      when(
        () => mockStudentRepository.getPlanForTheDay(),
      ).thenAnswer((_) async => Right(tPlan));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Right(tPlan));
      verify(() => mockStudentRepository.getPlanForTheDay()).called(1);
      verifyNoMoreInteractions(mockStudentRepository);
    });

    test('should return failure when repository fails to get plan', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Server error');
      when(
        () => mockStudentRepository.getPlanForTheDay(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockStudentRepository.getPlanForTheDay()).called(1);
    });
  });
}
