// lib/features/students/domain/usecases/upsert_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/follow_up_plan_entity.dart';
import '../repositories/student_repository.dart';

@lazySingleton
class SaveStudentPlan {
  final StudentRepository repository;

  SaveStudentPlan(this.repository);
 
  Future<Either<Failure, FollowUpPlanEntity>> call(
    FollowUpPlanEntity student,
  ) async {
    return await repository.saveLocalPlan(student);
  }
}
