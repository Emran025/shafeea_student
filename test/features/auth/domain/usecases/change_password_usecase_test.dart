// test/features/auth/domain/usecases/change_password_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/entities/success_entity.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/usecases/change_password_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late ChangePasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ChangePasswordUseCase(mockAuthRepository);
  });

  group('ChangePasswordUseCase', () {
    const tCurrentPassword = 'password1234';
    const tNewPassword = 'NewPassword456!';
    final tSuccessEntity = SuccessEntity();

    test('should return SuccessEntity when password change succeeds', () async {
      // Arrange
      when(
        () => mockAuthRepository.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        ),
      ).thenAnswer((_) async => Right(tSuccessEntity));

      // Act
      final result = await useCase(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, Right(tSuccessEntity));
      verify(
        () => mockAuthRepository.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return ServerFailure when current password is incorrect',
      () async {
        // Arrange
        const tFailure = ServerFailure(
          message: 'Current password is incorrect',
        );
        when(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return ServerFailure when new password does not meet requirements',
      () async {
        // Arrange
        const tWeakPassword = '123';
        const tFailure = ServerFailure(
          message: 'Password must be at least 8 characters',
        );
        when(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tWeakPassword,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(
          currentPassword: tCurrentPassword,
          newPassword: tWeakPassword,
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tWeakPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure(message: 'No internet connection');
        when(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
      },
    );

    test('should forward both passwords correctly to repository', () async {
      // Arrange
      const tDifferentCurrent = 'password1234';
      const tDifferentNew = 'password1234!';
      when(
        () => mockAuthRepository.changePassword(
          currentPassword: tDifferentCurrent,
          newPassword: tDifferentNew,
        ),
      ).thenAnswer((_) async => Right(tSuccessEntity));

      // Act
      await useCase(
        currentPassword: tDifferentCurrent,
        newPassword: tDifferentNew,
      );

      // Assert
      verify(
        () => mockAuthRepository.changePassword(
          currentPassword: tDifferentCurrent,
          newPassword: tDifferentNew,
        ),
      ).called(1);
    });
  });
}
