// test/features/home/domain/usecases/upsert_student_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/home/domain/entities/student_entity.dart';
import 'package:shafeea/features/home/domain/usecases/upsert_student_usecase.dart';

import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late UpsertStudent useCase;
  late MockStudentRepository mockStudentRepository;

  setUp(() {
    mockStudentRepository = MockStudentRepository();
    useCase = UpsertStudent(mockStudentRepository);
  });

  group('UpsertStudent', () {
    const tStudent = StudentDetailEntity(
      id: '1',
      name: 'Test Student',
      avatar: 'avatar',
      status: ActiveStatus.active,
      gender: Gender.male,
      birthDate: '2000-01-01',
      email: 'test@test.com',
      phone: '123',
      phoneZone: 1,
      whatsAppPhone: '123',
      whatsAppZone: 1,
      qualification: 'degree',
      experienceYears: 1,
      country: 'EG',
      city: 'Cairo',
      residence: 'Cairo',
      availableTime: TimeOfDay(hour: 10, minute: 0),
      stopReasons: 'none',
      bio: 'bio',
      memorizationLevel: 'all',
      createdAt: '2024',
      updatedAt: '2024',
    );

    test('should call upsertStudent from the repository', () async {
      // Arrange
      when(
        () => mockStudentRepository.upsertStudent(any()),
      ).thenAnswer((_) async => const Right(tStudent));

      // Act
      final result = await useCase(tStudent);

      // Assert
      expect(result, const Right(tStudent));
      verify(() => mockStudentRepository.upsertStudent(tStudent)).called(1);
      verifyNoMoreInteractions(mockStudentRepository);
    });

    test('should return failure when repository upsert fails', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Upsert failed');
      when(
        () => mockStudentRepository.upsertStudent(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tStudent);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockStudentRepository.upsertStudent(tStudent)).called(1);
    });
    group('registerFallbackValues', () {
      test('should register StudentDetailEntity fallback', () {
        // This is implicit in 'any()' usage if we register it,
        // but mocktail sometimes needs it.
        registerFallbackValue(tStudent);
      });
    });
  });
}
