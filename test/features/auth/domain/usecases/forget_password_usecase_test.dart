// test/features/auth/domain/usecases/forget_password_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/entities/success_entity.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/usecases/forget_password_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late ForgetPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ForgetPasswordUseCase(mockAuthRepository);
  });

  group('ForgetPasswordUseCase', () {
    const tEmail = 'test@example.com';
    final tSuccessEntity = SuccessEntity();

    test(
      'should return SuccessEntity when forget password request succeeds',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.forgetPassword(email: tEmail),
        ).thenAnswer((_) async =>  Right(tSuccessEntity));

        // Act
        final result = await useCase(email: tEmail);

        // Assert
        expect(result,  Right(tSuccessEntity));
        verify(
          () => mockAuthRepository.forgetPassword(email: tEmail),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return ServerFailure when email is not found', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Email not found');
      when(
        () => mockAuthRepository.forgetPassword(email: tEmail),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(email: tEmail);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.forgetPassword(email: tEmail)).called(1);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure(message: 'No internet connection');
        when(
          () => mockAuthRepository.forgetPassword(email: tEmail),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(email: tEmail);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.forgetPassword(email: tEmail),
        ).called(1);
      },
    );

    test('should forward the exact email to the repository', () async {
      // Arrange
      const tDifferentEmail = 'different@example.com';
      when(
        () => mockAuthRepository.forgetPassword(email: tDifferentEmail),
      ).thenAnswer((_) async => Right(tSuccessEntity));

      // Act
      await useCase(email: tDifferentEmail);

      // Assert
      verify(
        () => mockAuthRepository.forgetPassword(email: tDifferentEmail),
      ).called(1);
    });

    test('should return ServerFailure when email format is invalid', () async {
      // Arrange
      const tInvalidEmail = 'invalid-email';
      const tFailure = ServerFailure(message: 'Invalid email format');
      when(
        () => mockAuthRepository.forgetPassword(email: tInvalidEmail),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(email: tInvalidEmail);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockAuthRepository.forgetPassword(email: tInvalidEmail),
      ).called(1);
    });
  });
}
