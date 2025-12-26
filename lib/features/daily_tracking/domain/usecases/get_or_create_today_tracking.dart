import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/tracking_type.dart';
import '../../../home/domain/entities/tracking_detail_entity.dart';
import '../repositories/tracking_repository.dart';
import 'package:injectable/injectable.dart';

// Renamed for clarity to match what it returns.
@lazySingleton
class GetOrCreateTodayTrackingDetails {
  final TrackingRepository repository;

  GetOrCreateTodayTrackingDetails(this.repository);

  Future<Either<Failure, Map<TrackingType, TrackingDetailEntity>>>
  call() async {
    return await repository.getOrCreateTodayDraftTrackingDetails();
  }
}
