import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Fetches a username check from the backend for a given [name].
///
/// Used exclusively as a non-blocking UX hint when pre-filling the username
/// field in the student creation form. The result is NOT uniqueness-checked.
@lazySingleton
class CheckUsernameUseCase {
  final AuthRepository _repository;

  CheckUsernameUseCase(this._repository);

  Future<Either<Failure, bool>> call(String name) =>
      _repository.checkUsername(name);
}
