// test/features/settings/domain/usecases/get_faqs_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/settings/domain/entities/faq_entity.dart';
import 'package:shafeea/features/settings/domain/usecases/get_faqs_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetFaqsUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetFaqsUseCase(mockRepository);
  });

  const tPage = 1;
  const tFaqs = [
    FaqEntity(id: 1, question: 'Question 1', answer: 'Answer 1', viewCount: 10),
  ];

  test('should get FAQs from the repository', () async {
    // Arrange
    when(
      () => mockRepository.getFaqs(any()),
    ).thenAnswer((_) async => const Right(tFaqs));

    // Act
    final result = await useCase(const GetFaqsParams(page: tPage));

    // Assert
    expect(result, const Right(tFaqs));
    verify(() => mockRepository.getFaqs(tPage)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    when(
      () => mockRepository.getFaqs(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));

    // Act
    final result = await useCase(const GetFaqsParams(page: tPage));

    // Assert
    expect(result, const Left(ServerFailure(message: 'error')));
    verify(() => mockRepository.getFaqs(tPage)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
