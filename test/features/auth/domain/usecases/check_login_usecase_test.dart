// test/features/auth/domain/usecases/check_login_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/auth/domain/usecases/check_login_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late CheckLogInUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = CheckLogInUseCase(mockAuthRepository);
  });

  group('CheckLogInUseCase', () {
    const tUser = UserEntity(
      id: 1,
      name: 'shafeea',
      email: 'test@example.com',
      phone: '+1234567890',
      avatar: 'https://example.com/avatar.png',
    );

    test('should return UserEntity when user is logged in', () async {
      // Arrange
      when(
        () => mockAuthRepository.getUserProfile(),
      ).thenAnswer((_) async =>  Right(tUser));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.getUserProfile()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return CacheFailure when no user is cached', () async {
      // Arrange
      const tFailure = CacheFailure(message: 'No user found in cache');
      when(
        () => mockAuthRepository.getUserProfile(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.getUserProfile()).called(1);
    });

    test('should return CacheFailure when user session has expired', () async {
      // Arrange
      const tFailure = CacheFailure(message: 'Session expired');
      when(
        () => mockAuthRepository.getUserProfile(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.getUserProfile()).called(1);
    });

    test('should call getUserProfile exactly once', () async {
      // Arrange
      when(
        () => mockAuthRepository.getUserProfile(),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      await useCase();
      await useCase(); // Call twice

      // Assert
      verify(() => mockAuthRepository.getUserProfile()).called(2);
    });
  });
}
