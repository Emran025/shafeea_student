import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/school_entity.dart';
import '../repositories/auth_repository.dart';

/// Fetches the list of available schools from the backend.
///
/// This is a public endpoint — no authentication is required.
@lazySingleton
class GetSchoolsUseCase {
  final AuthRepository _repository;

  GetSchoolsUseCase(this._repository);

  Future<Either<Failure, List<SchoolEntity>>> call() =>
      _repository.getSchools();
}
