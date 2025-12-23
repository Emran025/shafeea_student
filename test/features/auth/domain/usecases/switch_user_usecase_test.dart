// test/features/auth/domain/usecases/switch_user_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/auth/domain/usecases/switch_user_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SwitchUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SwitchUserUseCase(mockAuthRepository);
  });

  group('SwitchUserUseCase', () {
    const tUserId = '123';
    const tNewUser = UserEntity(
      id: 123,
      name: 'Switched User',
      email: 'switched@example.com',
      phone: '+9876543210',
      avatar: 'https://example.com/avatar2.png',
    );

    test('should return new UserEntity when switch succeeds', () async {
      // Arrange
      when(
        () => mockAuthRepository.switchUser(userId: tUserId),
      ).thenAnswer((_) async => const Right(tNewUser));

      // Act
      final result = await useCase(userId: tUserId);

      // Assert
      expect(result, const Right(tNewUser));
      verify(() => mockAuthRepository.switchUser(userId: tUserId)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return CacheFailure when user ID not found', () async {
      // Arrange
      const tFailure = CacheFailure(message: 'User not found');
      when(
        () => mockAuthRepository.switchUser(userId: tUserId),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(userId: tUserId);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.switchUser(userId: tUserId)).called(1);
    });

    test(
      'should return CacheFailure when user profile data is missing',
      () async {
        // Arrange
        const tFailure = CacheFailure(
          message: 'User switched, but profile data is missing.',
        );
        when(
          () => mockAuthRepository.switchUser(userId: tUserId),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(userId: tUserId);

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockAuthRepository.switchUser(userId: tUserId)).called(1);
      },
    );

    test('should forward the exact userId to the repository', () async {
      // Arrange
      const tDifferentUserId = '456';
      const tDifferentUser = UserEntity(
        id: 456,
        name: 'Different User',
        email: 'different@example.com',
        phone: '+1111111111',
      );
      when(
        () => mockAuthRepository.switchUser(userId: tDifferentUserId),
      ).thenAnswer((_) async => const Right(tDifferentUser));

      // Act
      await useCase(userId: tDifferentUserId);

      // Assert
      verify(
        () => mockAuthRepository.switchUser(userId: tDifferentUserId),
      ).called(1);
    });

    test('should handle switching to the same user gracefully', () async {
      // Arrange
      when(
        () => mockAuthRepository.switchUser(userId: tUserId),
      ).thenAnswer((_) async => const Right(tNewUser));

      // Act
      final result = await useCase(userId: tUserId);

      // Assert
      expect(result, const Right(tNewUser));
      verify(() => mockAuthRepository.switchUser(userId: tUserId)).called(1);
    });
  });
}
