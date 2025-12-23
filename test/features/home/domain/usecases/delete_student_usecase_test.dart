// test/features/home/domain/usecases/delete_student_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/home/domain/usecases/delete_student_usecase.dart';
import 'package:shafeea/features/home/domain/usecases/usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late DeleteStudentUseCase useCase;
  late MockStudentRepository mockStudentRepository;

  setUp(() {
    mockStudentRepository = MockStudentRepository();
    useCase = DeleteStudentUseCase(mockStudentRepository);
  });

  group('DeleteStudentUseCase', () {
    test('should call deleteStudent from the repository', () async {
      // Arrange
      when(
        () => mockStudentRepository.deleteStudent(),
      ).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Right(unit));
      verify(() => mockStudentRepository.deleteStudent()).called(1);
      verifyNoMoreInteractions(mockStudentRepository);
    });

    test('should return failure when repository delete fails', () async {
      // Arrange
      const tFailure = CacheFailure(message: 'Delete failed');
      when(
        () => mockStudentRepository.deleteStudent(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockStudentRepository.deleteStudent()).called(1);
    });
  });
}
