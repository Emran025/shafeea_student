// test/features/auth/domain/usecases/logout_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/entities/success_entity.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/usecases/logout_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late LogOutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LogOutUseCase(mockAuthRepository);
  });

  group('LogOutUseCase', () {
    final tSuccessEntity = SuccessEntity();

    group('with deleteCredentials: true', () {
      test('should return SuccessEntity when logout succeeds', () async {
        // Arrange
        when(
          () => mockAuthRepository.logOut(deleteCredentials: true),
        ).thenAnswer((_) async => Right(tSuccessEntity));

        // Act
        final result = await useCase(deleteCredentials: true);

        // Assert
        expect(result, Right(tSuccessEntity));
        verify(
          () => mockAuthRepository.logOut(deleteCredentials: true),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      });

      test('should return CacheFailure when logout fails', () async {
        // Arrange
        const tFailure = CacheFailure(message: 'Failed to clear cache');
        when(
          () => mockAuthRepository.logOut(deleteCredentials: true),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(deleteCredentials: true);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.logOut(deleteCredentials: true),
        ).called(1);
      });
    });

    group('with deleteCredentials: false', () {
      test(
        'should return SuccessEntity when switching screen succeeds',
        () async {
          // Arrange
          when(
            () => mockAuthRepository.logOut(deleteCredentials: false),
          ).thenAnswer((_) async => Right(tSuccessEntity));

          // Act
          final result = await useCase(deleteCredentials: false);

          // Assert
          expect(result, Right(tSuccessEntity));
          verify(
            () => mockAuthRepository.logOut(deleteCredentials: false),
          ).called(1);
          verifyNoMoreInteractions(mockAuthRepository);
        },
      );

      test('should return ServerFailure when token is invalid', () async {
        // Arrange
        const tFailure = ServerFailure(message: 'Token is invalid');
        when(
          () => mockAuthRepository.logOut(deleteCredentials: false),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(deleteCredentials: false);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.logOut(deleteCredentials: false),
        ).called(1);
      });
    });

    test(
      'should call repository with correct deleteCredentials parameter',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.logOut(
            deleteCredentials: any(named: 'deleteCredentials'),
          ),
        ).thenAnswer((_) async => Right(tSuccessEntity));

        // Act - Test with true
        await useCase(deleteCredentials: true);

        // Assert - Verify true was passed
        verify(
          () => mockAuthRepository.logOut(deleteCredentials: true),
        ).called(1);

        // Act - Test with false
        await useCase(deleteCredentials: false);

        // Assert - Verify false was passed
        verify(
          () => mockAuthRepository.logOut(deleteCredentials: false),
        ).called(1);
      },
    );
  });
}
