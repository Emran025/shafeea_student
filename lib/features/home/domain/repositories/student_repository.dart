import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../settings/domain/entities/export_config.dart';
import '../../../settings/domain/entities/import_config.dart';
import '../../../settings/domain/entities/import_summary.dart';
import '../entities/follow_up_plan_entity.dart';
import '../entities/plan_for_the_day_entity.dart';
import '../entities/student_entity.dart';
import '../entities/student_info_entity.dart';

/// Defines the abstract contract for the student data repository.
///
/// This interface is the single gateway for the domain layer to interact with
/// all student-related data, abstracting away the complexities of data sources,
/// caching, and synchronization.
abstract interface class StudentRepository {
  /// Returns [Either<Failure, StudentDetailEntity>]:
  /// - Right(StudentDetailEntity) on success.
  /// - Left(Failure) if the student is not found or another error occurs.
  Future<Either<Failure, StudentInfoEntity>> getStudentInfo();

  /// Creates a new student or updates an existing one.
  ///
  /// Returns [Either<Failure, StudentDetailEntity>]:
  /// - Right(StudentDetailEntity) on success, returning the created/updated student.
  /// - Left(Failure) on error.
  Future<Either<Failure, StudentDetailEntity>> upsertStudent(
    StudentDetailEntity student,
  );

  /// Deletes a student by their ID.
  ///
  /// Returns [Either<Failure, Unit>]:
  /// - Right(unit) on successful deletion. `unit` is a void-like type from dartz.
  /// - Left(Failure) on error.
  Future<Either<Failure, Unit>> deleteStudent();

  Future<Either<Failure, PlanForTheDayEntity>> getPlanForTheDay();

  Future<Either<Failure, String>> exportFollowUpReports({
    required ExportConfig config,
  });
  Future<Either<Failure, ImportSummary>> importFollowUpReports({
    required ImportConfig config,
  });
  Future<Either<Failure, FollowUpPlanEntity>> saveLocalPlan(FollowUpPlanEntity plan);
}
