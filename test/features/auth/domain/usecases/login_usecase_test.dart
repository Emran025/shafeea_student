// test/features/auth/domain/usecases/login_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/entities/login_credentials_entity.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/auth/domain/usecases/login_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late LogInUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LogInUseCase(mockAuthRepository);
  });

  group('LogInUseCase', () {
    const tCredentials = LogInCredentialsEntity(
      logIn: 'fares.abduljabbar@example.com',
      password: 'password1234',
    );

    const tUser = UserEntity(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      phone: '+1234567890',
      avatar: 'https://example.com/avatar.png',
    );

    test(
      'should return UserEntity when the call to repository is successful',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).thenAnswer((_) async => const Right(tUser));

        // Act
        final result = await useCase(credentials: tCredentials);

        // Assert
        expect(result, const Right(tUser));
        verify(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return ServerFailure when the call to repository fails',
      () async {
        // Arrange
        const tFailure = ServerFailure(message: 'Invalid credentials');
        when(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(credentials: tCredentials);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure(message: 'No internet connection');
        when(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(credentials: tCredentials);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.logIn(credentials: tCredentials),
        ).called(1);
      },
    );

    test('should forward the exact credentials to the repository', () async {
      // Arrange
      const tDifferentCredentials = LogInCredentialsEntity(
        logIn: 'fares.abduljabbar@example.com',
        password: 'password1234',
      );
      when(
        () => mockAuthRepository.logIn(credentials: tDifferentCredentials),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      await useCase(credentials: tDifferentCredentials);

      // Assert
      verify(
        () => mockAuthRepository.logIn(credentials: tDifferentCredentials),
      ).called(1);
    });
  });
}
