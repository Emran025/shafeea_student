// test/features/home/presentation/bloc/student_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/features/home/data/models/assigned_halaqas_model.dart';
import 'package:shafeea/features/home/data/models/follow_up_plan_model.dart';
import 'package:shafeea/features/home/domain/entities/plan_for_the_day_entity.dart';
import 'package:shafeea/features/home/domain/entities/student_entity.dart';
import 'package:shafeea/features/home/domain/entities/student_info_entity.dart';
import 'package:shafeea/features/home/presentation/bloc/student_bloc.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late StudentBloc studentBloc;
  late MockGetStudentById mockGetStudentById;
  late MockUpsertStudent mockUpsertStudent;
  late MockDeleteStudentUseCase mockDeleteStudentUseCase;
  late MockGetPlanForTheDay mockGetPlanForTheDay;

  setUp(() {
    mockGetStudentById = MockGetStudentById();
    mockUpsertStudent = MockUpsertStudent();
    mockDeleteStudentUseCase = MockDeleteStudentUseCase();
    mockGetPlanForTheDay = MockGetPlanForTheDay();

    studentBloc = StudentBloc(
      getStudentInfo: mockGetStudentById,
      upsertStudent: mockUpsertStudent,
      deleteStudent: mockDeleteStudentUseCase,
      getPlanForTheDay: mockGetPlanForTheDay,
    );
  });

  tearDown(() {
    studentBloc.close();
  });

  const tStudentDetail = StudentDetailEntity(
    id: '1',
    name: 'Ahmed Ali',
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

  final tStudentInfo = StudentInfoEntity(
    studentDetailEntity: tStudentDetail,
    assignedHalaqa: AssignedHalaqasModel.defaultAssigned().toEntity(),
    followUpPlan: FollowUpPlanModel.defaultPlan().toEntity(),
  );

  final tPlanForTheDay = PlanForTheDayEntity(
    section: const [],
    endDate: DateTime(2024, 1, 1),
  );

  group('StudentDetailsFetched', () {
    blocTest<StudentBloc, StudentState>(
      'should emit [loading, success] when data is fetched successfully',
      build: () {
        when(
          () => mockGetStudentById(any()),
        ).thenAnswer((_) async => Right(tStudentInfo));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const StudentDetailsFetched()),
      expect: () => [
        const StudentState(detailsStatus: StudentInfoStatus.loading),
        StudentState(
          detailsStatus: StudentInfoStatus.success,
          selectedStudent: tStudentInfo,
        ),
      ],
      verify: (_) {
        verify(() => mockGetStudentById(any())).called(1);
      },
    );

    blocTest<StudentBloc, StudentState>(
      'should emit [loading, failure] when fetching data fails',
      build: () {
        when(
          () => mockGetStudentById(any()),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const StudentDetailsFetched()),
      expect: () => [
        const StudentState(detailsStatus: StudentInfoStatus.loading),
        const StudentState(
          detailsStatus: StudentInfoStatus.failure,
          detailsFailure: ServerFailure(message: 'error'),
        ),
      ],
    );
  });

  group('StudentUpserted', () {
    blocTest<StudentBloc, StudentState>(
      'should emit [submitting, success] when upsert is successful',
      build: () {
        when(
          () => mockUpsertStudent(any()),
        ).thenAnswer((_) async => const Right(tStudentDetail));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const StudentUpserted(tStudentDetail)),
      expect: () => [
        const StudentState(
          submissionStatus: StudentSubmissionStatus.submitting,
        ),
        const StudentState(submissionStatus: StudentSubmissionStatus.success),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'should emit [submitting, failure] when upsert fails',
      build: () {
        when(
          () => mockUpsertStudent(any()),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const StudentUpserted(tStudentDetail)),
      expect: () => [
        const StudentState(
          submissionStatus: StudentSubmissionStatus.submitting,
        ),
        const StudentState(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: ServerFailure(message: 'error'),
        ),
      ],
    );
  });

  group('PlanForTheDayRequested', () {
    blocTest<StudentBloc, StudentState>(
      'should emit [loading, success] when plan is fetched successfully',
      build: () {
        when(
          () => mockGetPlanForTheDay(any()),
        ).thenAnswer((_) async => Right(tPlanForTheDay));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const PlanForTheDayRequested()),
      expect: () => [
        const StudentState(planForTheDayStatus: PlanForTheDayStatus.loading),
        StudentState(
          planForTheDayStatus: PlanForTheDayStatus.success,
          planForTheDay: tPlanForTheDay,
        ),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'should emit [loading, failure] when plan fetching fails',
      build: () {
        when(
          () => mockGetPlanForTheDay(any()),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return studentBloc;
      },
      act: (bloc) => bloc.add(const PlanForTheDayRequested()),
      expect: () => [
        const StudentState(planForTheDayStatus: PlanForTheDayStatus.loading),
        const StudentState(
          planForTheDayStatus: PlanForTheDayStatus.failure,
          planForTheDayFailure: ServerFailure(message: 'error'),
        ),
      ],
    );
  });
}
