import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/student_applicant.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';


@lazySingleton

class RegisterStudentUseCase {
  
  final AuthRepository _authRepository;

  RegisterStudentUseCase(this._authRepository);

  Future<Either<Failure, UserEntity>> call(StudentApplicantEntity student) async {
    return await _authRepository.registerStudent(student);
  }
}