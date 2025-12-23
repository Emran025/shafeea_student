// test/features/home/data/repositories_impl/student_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/features/home/data/models/student_model.dart';
import 'package:shafeea/features/home/data/models/student_info_model.dart';
import 'package:shafeea/features/home/data/repositories_impl/student_repository_impl.dart';
import 'package:shafeea/features/home/domain/entities/student_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late StudentRepositoryImpl repository;
  late MockStudentLocalDataSource mockLocalDataSource;
  late MockTrackingLocalDataSource mockTrackingLocalDataSource;
  late MockStudentRemoteDataSource mockRemoteDataSource;
  late MockStudentSyncService mockSyncService;

  setUp(() {
    mockLocalDataSource = MockStudentLocalDataSource();
    mockTrackingLocalDataSource = MockTrackingLocalDataSource();
    mockRemoteDataSource = MockStudentRemoteDataSource();
    mockSyncService = MockStudentSyncService();

    repository = StudentRepositoryImpl(
      localDataSource: mockLocalDataSource,
      trackingLocalDataSource: mockTrackingLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      syncService: mockSyncService,
    );

    registerFallbackValue(
      StudentModel.fromEntity(
        const StudentDetailEntity(
          id: '1',
          name: 'name',
          avatar: 'avatar',
          status: ActiveStatus.active,
          gender: Gender.male,
          birthDate: 'birthDate',
          email: 'email',
          phone: 'phone',
          phoneZone: 1,
          whatsAppPhone: 'whatsAppPhone',
          whatsAppZone: 1,
          qualification: 'qualification',
          experienceYears: 1,
          country: 'country',
          residence: 'residence',
          city: 'city',
          availableTime: TimeOfDay(hour: 0, minute: 0),
          stopReasons: 'stopReasons',
          bio: 'bio',
          memorizationLevel: 'all',
          createdAt: 'createdAt',
          updatedAt: 'updatedAt',
        ),
      ),
    );
  });

  group('upsertStudent', () {
    const tStudent = StudentDetailEntity(
      id: '1',
      name: 'Test Student',
      avatar: 'avatar',
      status: ActiveStatus.active,
      gender: Gender.male,
      birthDate: '2000-01-01',
      email: 'test@email.com',
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

    test(
      'should save student locally and return student entity on success',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.upsertStudent(any()),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.upsertStudent(tStudent);

        // Assert
        verify(() => mockLocalDataSource.upsertStudent(any())).called(1);
        expect(result, equals(const Right(tStudent)));
      },
    );
    group('registerFallbackValues', () {
      test('should register StudentModel fallback', () {
        // Logic handled in setUp
      });
    });
  });

  group('getStudentInfo', () {
    final tStudentInfoModel = StudentInfoModel.studentWithDefaultInfo(
      student: StudentModel.fromEntity(
        const StudentDetailEntity(
          id: '1',
          name: 'name',
          avatar: 'avatar',
          status: ActiveStatus.active,
          gender: Gender.male,
          birthDate: 'birthDate',
          email: 'email',
          phone: 'phone',
          phoneZone: 1,
          whatsAppPhone: 'whatsAppPhone',
          whatsAppZone: 1,
          qualification: 'qualification',
          experienceYears: 1,
          country: 'country',
          residence: 'residence',
          city: 'city',
          availableTime: TimeOfDay(hour: 0, minute: 0),
          stopReasons: 'stopReasons',
          bio: 'bio',
          memorizationLevel: 'all',
          createdAt: 'createdAt',
          updatedAt: 'updatedAt',
        ),
      ),
    );

    test(
      'should return student info from local data source after syncing',
      () async {
        // Arrange
        when(
          () => mockSyncService.performTrackingsSync(),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalDataSource.getStudentInfo(),
        ).thenAnswer((_) async => tStudentInfoModel);

        // Act
        final result = await repository.getStudentInfo();

        // Assert
        verify(() => mockSyncService.performTrackingsSync()).called(1);
        verify(() => mockLocalDataSource.getStudentInfo()).called(1);
        expect(result, equals(Right(tStudentInfoModel.toStudentInfoEntity())));
      },
    );
  });
}
