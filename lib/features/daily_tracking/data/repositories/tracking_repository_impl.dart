import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/models/bar_chart_datas.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';

// Domain Layer imports
import '../../../../core/error/failures.dart';
import '../../../home/data/datasources/student_local_data_source.dart';
import '../../../home/data/models/follow_up_plan_model.dart';
import '../../../home/data/models/tracking_detail_model.dart';
import '../../../home/data/models/tracking_model.dart';
import '../../../home/domain/entities/follow_up_plan_entity.dart';
import '../../../home/domain/entities/tracking_detail_entity.dart';
import '../../../home/domain/entities/tracking_entity.dart';
import '../../domain/entities/mistake.dart';
import '../../domain/repositories/tracking_repository.dart';

// Data Layer imports
import '../datasources/tracking_local_data_source.dart';
import '../models/mistake_model.dart';

/// The concrete implementation of the [TrackingRepository] contract.
///
/// This repository acts as a mediator between the domain layer (UseCases) and
/// the data layer (DataSources). It is responsible for fetching data models
/// from the data source, converting them into clean domain entities, and
/// handling exceptions by converting them into user-friendly `Failure` objects.
@LazySingleton(as: TrackingRepository)
final class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource _localDataSource;
  final StudentLocalDataSource _studentLocalDataSource;

  TrackingRepositoryImpl({
    required TrackingLocalDataSource localDataSource,
    required StudentLocalDataSource studentLocalDataSource,
  }) : _localDataSource = localDataSource,
       _studentLocalDataSource = studentLocalDataSource;

  @override
  Future<Either<Failure, Map<TrackingType, TrackingDetailEntity>>>
  getOrCreateTodayDraftTrackingDetails() {
    // REFINEMENT: Wrap the logic in a generic helper for conciseness and robustness.
    return _tryCatch<Map<TrackingType, TrackingDetailEntity>>(() async {
      final modelsMap = await _localDataSource
          .getOrCreateTodayDraftTrackingDetails();

      return modelsMap.map((key, model) => MapEntry(key, model.toEntity()));
    });
  }

  @override
  Future<Either<Failure, Unit>> saveDraftTaskProgress(
    TrackingDetailEntity detail,
  ) {
    return _tryCatch<Unit>(() async {
      final detailModel = TrackingDetailModel.fromEntity(detail);
      log("===========================");

      await _localDataSource.saveDraftTrackingDetails([detailModel]);

      return unit; // Return the dartz unit object on success
    });
  }

  /// A generic private helper to wrap data source calls.
  ///
  /// This centralizes the try-catch logic, reducing code duplication and making
  /// the repository methods cleaner and focused on their primary task.
  Future<Either<Failure, T>> _tryCatch<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on CacheException catch (e) {
      log(e.message);
      return Left(CacheFailure(message: e.message));
    } on FormatException catch (e) {
      // Example of handling another specific exception type
      return Left(
        UnknownFailure(message: 'Data formatting error: ${e.message}'),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Mistake>>> getAllMistakes({
    TrackingType? type, // <-- NOW OPTIONAL
    int? fromPage,
    int? toPage,
  }) {
    return _tryCatch<List<Mistake>>(() async {
      final mistakeModels = await _localDataSource.getAllMistakes(
        type: type, // Pass it down
        fromPage: fromPage,
        toPage: toPage,
      );
      return mistakeModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<BarChartDatas>>> getErrorAnalysisChartData({
    required ChartFilter filter,
  }) {
    return _tryCatch<List<BarChartDatas>>(() async {
      final chartData = await _localDataSource.getErrorAnalysisChartData(
        filter: filter,
      );
      return chartData;
    });
  }

  @override
  Future<Either<Failure, FollowUpPlanEntity>> getFollowUpPlan() async {
    try {
      final FollowUpPlanModel planModel = await _studentLocalDataSource
          .getFollowUpPlan();
      return Right(planModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<TrackingEntity>>> getFollowUpTrackings() async {
    try {
      // await _syncService.performTrackingsSync();
      final List<TrackingModel> trackingModels = await _studentLocalDataSource
          .getFollowUpTrackings();
      final trackingEntities = trackingModels
          .map((model) => model.toEntity())
          .toList();
      return Right(trackingEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
    Future<Either<Failure, Unit>> saveDraftMistakes({
    required List<Mistake> mistakes,
  }) async {
    return _tryCatch<Unit>(() async {
     final mistakeModels = mistakes.map((e)=>MistakeModel.fromEntity(e)).toList();
       await _localDataSource.saveDraftMistakes(
        mistakes: mistakeModels,
      );
      return unit;
    });
  }
}
