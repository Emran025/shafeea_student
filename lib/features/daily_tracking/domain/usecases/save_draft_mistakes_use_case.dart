import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/core/usecases/usecase.dart';
import 'package:shafeea/features/daily_tracking/domain/entities/mistake.dart';
import 'package:shafeea/features/daily_tracking/domain/repositories/tracking_repository.dart';

@lazySingleton
class SaveDraftMistakesUseCase extends UseCase<void, List<Mistake>> {
  final TrackingRepository repository;
  SaveDraftMistakesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<Mistake> mistakes) async {
    return await repository.saveDraftMistakes(mistakes: mistakes);
  }
}
