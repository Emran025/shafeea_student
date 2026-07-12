// test/features/auth/domain/usecases/register_student_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/features/auth/domain/entities/student_applicant.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/auth/domain/usecases/register_student_usecase.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late RegisterStudentUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = RegisterStudentUseCase(mockAuthRepository);
  });

  group('RegisterStudentUseCase', () {
    const tStudentApplicant = StudentApplicantEntity(
      name: 'Ahmed Ali',
      email: 'ahmed@example.com',
      username: 'SecurePass123!',
      password: 'SecurePass123!',
      bio: 'Student bio information',
      qualifications: 'High school diploma',
      memorizationLevel: 5,
      gender: Gender.male,
      birthDate: '2005-01-15',
      phone: '+966501234567',
      phoneZone: '+966',
      whatsapp: '+966501234567',
      whatsappZone: '+966',
      country: 'Saudi Arabia',
      residence: 'Riyadh',
    );

    const tUser = UserEntity(
      id: 101,
      name: 'Ahmed Ali',
      email: 'ahmed@example.com',
      phone: '+966501234567',
      avatar: null,
    );

    test('should return UserEntity when registration succeeds', () async {
      // Arrange
      when(
        () => mockAuthRepository.registerStudent(tStudentApplicant),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await useCase(tStudentApplicant);

      // Assert
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.registerStudent(tStudentApplicant),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return ServerFailure when registration fails with duplicate email',
      () async {
        // Arrange
        const tFailure = ServerFailure(message: 'Email already exists');
        when(
          () => mockAuthRepository.registerStudent(tStudentApplicant),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(tStudentApplicant);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.registerStudent(tStudentApplicant),
        ).called(1);
      },
    );

    test('should return ServerFailure when validation fails', () async {
      // Arrange
      const tFailure = ServerFailure(
        message: 'Password must be at least 8 characters',
      );
      when(
        () => mockAuthRepository.registerStudent(tStudentApplicant),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tStudentApplicant);

      // Assert
      expect(result, const Left(tFailure));
      verify(
        () => mockAuthRepository.registerStudent(tStudentApplicant),
      ).called(1);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const tFailure = NetworkFailure(message: 'No internet connection');
        when(
          () => mockAuthRepository.registerStudent(tStudentApplicant),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(tStudentApplicant);

        // Assert
        expect(result, const Left(tFailure));
        verify(
          () => mockAuthRepository.registerStudent(tStudentApplicant),
        ).called(1);
      },
    );

    test('should forward the exact student data to the repository', () async {
      // Arrange
      const tDifferentStudent = StudentApplicantEntity(
        name: 'Fatima Hassan',
        email: 'fatima@example.com',
        password: 'AnotherPass456!',
        username: 'AnotherPass456!',
        bio: 'Different bio',
        qualifications: 'Bachelor degree',
        memorizationLevel: 10,
        gender: Gender.female,
      );
      when(
        () => mockAuthRepository.registerStudent(tDifferentStudent),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      await useCase(tDifferentStudent);

      // Assert
      verify(
        () => mockAuthRepository.registerStudent(tDifferentStudent),
      ).called(1);
    });

    test('should handle optional fields correctly', () async {
      // Arrange
      const tMinimalStudent = StudentApplicantEntity(
        name: 'Minimal User',
        email: 'minimal@example.com',
        password: 'MinPass123!',
        username: 'MinPass123!',
        bio: 'Minimal bio',
        qualifications: 'None',
      );
      when(
        () => mockAuthRepository.registerStudent(tMinimalStudent),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await useCase(tMinimalStudent);

      // Assert
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.registerStudent(tMinimalStudent),
      ).called(1);
    });
  });
}
