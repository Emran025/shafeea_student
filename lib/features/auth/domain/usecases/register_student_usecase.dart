import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/core/entities/success_entity.dart';
import '../entities/student_applicant.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';


@lazySingleton

class RegisterStudentUseCase {
  
  final AuthRepository _authRepository;

  RegisterStudentUseCase(this._authRepository);

  Future<Either<Failure, SuccessEntity>> call(StudentApplicant student) async {
    return await _authRepository.registerStudent(student);
  }
}