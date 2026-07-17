import 'package:shafeea/features/home/data/models/student_model.dart';

import '../../../../core/models/sync_queue_model.dart';
import '../../../settings/domain/entities/import_export.dart';
import '../models/assigned_halaqas_model.dart';
import '../models/follow_up_plan_model.dart';
import '../models/student_info_model.dart';

import '../models/tracking_model.dart';

/// Defines the abstract contract for the local data source of students.
///
/// This interface specifies all methods required for managing student data and
/// their synchronization state within the local SQLite database. It operates
/// exclusively with data layer models.
abstract interface class StudentLocalDataSource {
  /// Retrieves all pending operations from the sync queue.
  Future<List<SyncQueueModel>> getPendingSyncOperations();

  /// Retrieves the timestamp of the most recently modified record.
  /// This is used for delta synchronization.
  Future<int> getLastSyncTimestampFor();
  Future<void> updateLastSyncTimestampFor(int timestamp);

  // You would also have methods to mark operations as 'in_progress' or 'failed'.

  /// Creates a new student or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertStudent(StudentModel student);
  // You would also have methods to mark operations as 'in_progress' or 'failed'.

  /// Creates a new student or updates an existing one in the local database.
  ///
  /// The implementation should use a conflict resolution algorithm like
  /// `ConflictAlgorithm.replace` to handle both insertion and update
  /// (upsert) in a single operation.
  /// Throws a [CacheException] if the upsert operation fails.
  Future<void> upsertHalqaStudent(
    AssignedHalaqasModel student,
    String studentId,
  );
  Future<void> upsertFollowUpPlans(FollowUpPlanModel student);
  Future<void> upsertStudentInfo(StudentInfoModel student);
  Future<void> saveLocalPlan(FollowUpPlanModel plan);

  /// Performs a "soft delete" on a student record in the local database.
  ///
  /// Instead of physically removing the record, this method should mark the
  /// student as deleted (e.g., by setting an `isDeleted` flag to true).
  /// Throws a [CacheException] if the update operation fails.
  Future<void> deleteStudent();

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if not.
  /// This method is used to retrieve a specific student's details.
  /// @param studentId The unique identifier of the student.
  /// @returns A [StudentModel] representing the student.
  Future<StudentModel> getStudent();
  Future<AssignedHalaqasModel> getAssignedHalaqa();
  Future<StudentInfoModel> getStudentInfo();
  Future<FollowUpPlanModel> getFollowUpPlan();

  /// {@template get_local_follow_up_trackings}
  /// Fetches the cached list of daily tracking records for a specific enrollment.
  ///
  /// - [enrollmentId]: The local database ID for the student's enrollment.
  ///
  /// Returns a `Future` that completes with a list of [TrackingModel].
  /// The list will be empty if no cached data is found.
  ///
  /// Throws a [CacheException] if a database error occurs.
  /// {@endtemplate}
  Future<List<TrackingModel>> getFollowUpTrackings();

  /// {@template cache_follow_up_trackings}
  /// Caches a list of daily tracking records.
  ///
  /// This method performs a "clean and write" operation within a single transaction:
  /// it first deletes all existing tracking data for the given enrollment,
  /// then inserts the new data. This ensures the cache is always a mirror of the latest server data.
  ///
  /// - [enrollmentId]: The local database ID for the student's enrollment.
  /// - [trackings]: The list of [TrackingModel] objects to cache.
  ///
  /// Throws a [CacheException] if the database transaction fails.
  /// {@endtemplate}
  Future<void> cacheFollowUpTrackings({required List<TrackingModel> trackings});

  /// Fetches all follow-up tracking records for all students.
  ///
  /// Returns a `Future` that completes with a `Map` where each key is a
  /// student's UUID and the value is a list of their [TrackingModel]s.
  /// The map will be empty if no tracking data is found.
  ///
  /// Throws a [CacheException] if a database error occurs.
  Future<Map<String, List<TrackingModel>>> getAllFollowUpTrackings();

  /// Imports a list of follow-up tracking records into the local database.
  ///
  /// - [trackings]: A map where each key is a student's UUID and the value is a
  ///   list of their [TrackingModel]s.
  /// - [conflictResolution]: The strategy to use when a record with the same
  ///   student UUID and date already exists.
  ///
  /// Returns a `Future` that completes with `unit` on success, or a `Failure`
  /// on error.
  Future<void> importFollowUpTrackings({
    required Map<String, List<TrackingModel>> trackings,
    required ConflictResolution conflictResolution,
  });
}
