import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart';
// import '../../../../core/models/user_role.dart';
import '../../../../core/models/sync_queue_model.dart';
import '../../../daily_tracking/data/models/mistake_model.dart';
import '../../../settings/domain/entities/import_export.dart';
import '../models/assigned_halaqas_model.dart';
import '../models/follow_up_plan_model.dart';
import '../models/student_info_model.dart';
import '../models/student_model.dart';
import '../models/tracking_detail_model.dart';
import '../models/tracking_model.dart';
import 'student_local_data_source.dart';

/// The name of the table that stores user data, including students.

/// The concrete implementation of [StudentLocalDataSource] using SQLite.
///
/// This class handles all direct database interactions for student data,
/// such as querying, inserting, updating, and deleting records. It operates
/// exclusively with [StudentModel] objects.

/// Table and column name constants to prevent typos.
const String _kUsersTable = 'users';
const String _kHalqaStudentsTable = 'halqa_students';
const String _kFollowUpPlansTable = 'follow_up_plans';
const String _kPlanDetailsTable = 'plan_details';
const String _kPendingOperationsTable = 'pending_operations';
const String _kMistakesTable = 'mistakes';
const String _kSyncMetadataTable = 'sync_metadata';

// At the top of StudentLocalDataSourceImpl.dart

const String _kDailyTrackingTable = 'daily_tracking';
const String _kDailyTrackingDetailTable = 'daily_tracking_detail';

@LazySingleton(as: StudentLocalDataSource)
final class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final Database _db;
  final AuthLocalDataSource _authLocalDataSource;

  /// A broadcast StreamController that acts as a simple notification bus.
  /// When data in the students table changes (e.g., after a sync), we add an
  /// event to this controller to trigger all active listeners to re-fetch.
  final _dbChangeNotifier = StreamController<void>.broadcast();

  StudentLocalDataSourceImpl({
    required Database database,
    required AuthLocalDataSource authLocalDataSource,
  }) : _db = database,
       _authLocalDataSource = authLocalDataSource;

  // =========================================================================
  //                             Generic Data Helpers
  // =========================================================================

  /// ... (your existing _fetchMappedIds helper method) ...
  /// Returns a `Map<K, V>` linking each key to its corresponding value.
  Future<Map<K, V>> _fetchMappedIds<K, V>({
    required DatabaseExecutor dbExecutor,
    required String tableName,
    required String keyColumn,
    required String valueColumn,
    required List<K> keys,
    String? additionalWhere,
    List<Object?>? additionalArgs,
  }) async {
    if (keys.isEmpty) {
      return {};
    }

    // بناء جملة WHERE الأساسية
    String whereClause =
        '$keyColumn IN (${List.filled(keys.length, '?').join(',')})';
    List<Object?> whereArgs = [...keys];

    // إضافة أي شروط إضافية
    if (additionalWhere != null && additionalWhere.isNotEmpty) {
      whereClause += ' AND $additionalWhere';
      if (additionalArgs != null) {
        whereArgs.addAll(additionalArgs);
      }
    }

    try {
      final maps = await dbExecutor.query(
        tableName,
        columns: [keyColumn, valueColumn],
        where: whereClause,
        whereArgs: whereArgs,
      );
      return {for (var map in maps) map[keyColumn] as K: map[valueColumn] as V};
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to bulk fetch mapped IDs from $tableName: ${e.toString()}',
      );
    }
  }

  /// **(NEW GENERIC HELPER)** A generic and powerful helper to fetch and group
  /// child records for a "one-to-many" relationship using a bulk `IN` clause.
  ///
  /// This is the most efficient way to resolve one-to-many relationships,
  /// avoiding the "N+1 query problem".
  ///
  /// - [dbExecutor]: The database executor (`_db` or a transaction `txn`).
  /// - [tableName]: The name of the child table to query (e.g., `_kDailyTrackingDetailTable`).
  /// - [foreignKeyColumn]: The name of the foreign key column in the child table (e.g., 'trackingId').
  /// - [foreignKeys]: The list of parent keys to search for.
  /// - [fromMap]: A function that converts a raw `Map<String, dynamic>` to the desired model type `T`.
  /// - [additionalWhere]: An optional additional WHERE clause.
  /// - [additionalArgs]: Arguments for the additional WHERE clause.
  ///
  /// Returns a `Map<K, List<T>>` linking each foreign key to a list of its corresponding child models.
  Future<Map<K, List<T>>> _fetchGroupedByForeignKey<K, T>({
    required DatabaseExecutor dbExecutor,
    required String tableName,
    required String foreignKeyColumn,
    required List<K> foreignKeys,
    required T Function(Map<String, dynamic> map) fromMap,
    String? additionalWhere,
    List<Object?>? additionalArgs,
  }) async {
    if (foreignKeys.isEmpty) {
      return {};
    }

    // Build the primary WHERE clause
    String whereClause =
        '$foreignKeyColumn IN (${List.filled(foreignKeys.length, '?').join(',')})';
    List<Object?> whereArgs = [...foreignKeys];

    // Append any additional conditions
    if (additionalWhere != null && additionalWhere.isNotEmpty) {
      whereClause += ' AND $additionalWhere';
      if (additionalArgs != null) {
        whereArgs.addAll(additionalArgs);
      }
    }

    try {
      // Fetch all relevant child rows in a single query
      final maps = await dbExecutor.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
      );

      // Group the raw maps by their foreign key
      final groupedRawMaps = groupBy<Map<String, dynamic>, K>(
        maps,
        (map) => map[foreignKeyColumn] as K,
      );

      // Convert the raw maps into typed models within their groups
      return groupedRawMaps.map((key, value) {
        final models = value.map(fromMap).toList();
        return MapEntry(key, models);
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to bulk fetch grouped data from $tableName: ${e.toString()}',
      );
    }
  }

  Future<List<int>> _fetchStudentIdsByUuids({
    required DatabaseExecutor dbExecutor,
    required List<String> uuids,
  }) async {
    final Map<String, int> uuidToStudentIdMap =
        await _fetchMappedIds<String, int>(
          dbExecutor: dbExecutor,
          tableName: _kUsersTable,
          keyColumn: 'uuid',
          valueColumn: 'id',
          keys: uuids,
          additionalWhere: 'isDeleted = ?',
          additionalArgs: [0],
        );
    final List<int> orderedIds = [];
    for (final uuid in uuids) {
      final id = uuidToStudentIdMap[uuid];
      if (id == null) {
        throw CacheException(
          message:
              'Could not find a matching database ID for student UUID: $uuid',
        );
      }
      orderedIds.add(id);
    }

    return orderedIds;
  }

  Future<List<int>> _fetchEnrollmentIdsByStudentIds({
    required DatabaseExecutor dbExecutor,
    required List<int> studentIds,
    String? additionalWhere,
    List<Object?>? additionalArgs,
  }) async {
    final Map<int, int> uuidToStudentIdMap = await _fetchMappedIds<int, int>(
      dbExecutor: dbExecutor,
      tableName: _kHalqaStudentsTable,
      keyColumn: 'studentId',
      valueColumn: 'id',
      keys: studentIds,
      additionalWhere: additionalWhere,
      additionalArgs: additionalArgs,
    );

    final List<int> orderedIds = [];
    for (final uuid in studentIds) {
      final id = uuidToStudentIdMap[uuid];
      if (id == null) {
        throw CacheException(
          message:
              'Could not find a matching database ID for enrollmentIds UUID: $uuid',
        );
      }
      orderedIds.add(id);
    }
    return orderedIds;
  }

  /// Fetches a list of integer IDs corresponding to a list of student UUIDs.
  /// IMPORTANT: This function guarantees that the returned list of IDs will be
  /// in the *exact same order* as the input list of UUIDs.
  /// It throws an exception if any UUID is not found.
  Future<List<int>> _fetchEnrollmentIdbyStudentUuids({
    required DatabaseExecutor dbExecutor,
    required List<String> uuids,
  }) async {
    if (uuids.isEmpty) {
      return [];
    }

    final uuidToStudentIdMap = await _fetchStudentIdsByUuids(
      dbExecutor: dbExecutor,
      uuids: uuids,
    );

    return await _fetchEnrollmentIdsByStudentIds(
      dbExecutor: dbExecutor,
      studentIds: uuidToStudentIdMap,
      additionalWhere: 'isDeleted = ?',
      additionalArgs: [0],
    );
  }

  /// **(NEW SPECIALIZED FETCHER)** A specialized fetcher that uses the generic helper
  /// to get all tracking details grouped by their parent `trackingId`.
  ///
  /// - [dbExecutor]: The database executor (`_db` or a transaction `txn`).
  /// - [trackingIds]: A list of parent IDs from the `daily_tracking` table.
  ///
  /// Returns a `Map` where each key is a parent `trackingId` and the value is a
  /// `List` of all corresponding [TrackingDetailModel]s.
  Future<Map<int, List<TrackingDetailModel>>>
  _fetchAllTrackingDetailsGroupedByParentId({
    required DatabaseExecutor dbExecutor,
    required List<int> trackingIds,
  }) async {
    if (trackingIds.isEmpty) {
      return {};
    }

    // 1. Fetch all raw detail maps for the given parent tracking IDs.
    final detailMaps = await dbExecutor.query(
      _kDailyTrackingDetailTable,
      where:
          'trackingId IN (${List.filled(trackingIds.length, '?').join(',')})',
      whereArgs: trackingIds,
    );

    if (detailMaps.isEmpty) {
      return {};
    }
    // 2. Efficiently fetch all mistakes for all the details we just found in one go.
    final detailIds = detailMaps.map((d) => d['id'] as int).toList();

    final mistakesByDetailId =
        await _fetchGroupedByForeignKey<int, MistakeModel>(
          dbExecutor: dbExecutor,
          tableName: _kMistakesTable,
          foreignKeyColumn: 'trackingDetailId',
          foreignKeys: detailIds,
          fromMap: MistakeModel.fromMap,
        );

    // 3. Assemble the final, complete TrackingDetailModel objects.
    final List<TrackingDetailModel> fullDetails = detailMaps.map((detailMap) {
      final detailId = detailMap['id'] as int;
      final associatedMistakes = mistakesByDetailId[detailId] ?? [];

      // Call the updated constructor with both the map and the mistakes list.

      return TrackingDetailModel.fromMap(detailMap, associatedMistakes);
    }).toList();

    // 4. Group the fully assembled models by their parent trackingId for the final result.
    return groupBy<TrackingDetailModel, int>(
      fullDetails,
      (detail) => detail.trackingId,
    );
  }

  // =========================================================================
  //                             Synchronization Methods
  // =========================================================================

  @override
  Future<int> getLastSyncTimestampFor() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final result = await _db.query(
      _kSyncMetadataTable,
      columns: ['last_server_sync_timestamp'],
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
    );
    if (result.isNotEmpty) {
      return result.first['last_server_sync_timestamp'] as int;
    }
    return 0;
  }

  @override
  Future<void> updateLastSyncTimestampFor(int timestamp) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    await _db.insert(_kSyncMetadataTable, {
      'last_server_sync_timestamp': timestamp,
      'tenant_id': tenantId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> upsertStudent(StudentModel student) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final studentMap = student.toMap();
      studentMap['tenant_id'] = tenantId;
      studentMap['id'] = tenantId;
      studentMap['uuid'] = tenantId;
      _db.insert(
        _kUsersTable,
        studentMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save student (${student.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> upsertHalqaStudent(
    AssignedHalaqasModel student,
    String studentId,
  ) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final studentMap = student.toMap(user.id);
      studentMap['tenant_id'] = tenantId;
      _db.insert(
        _kHalqaStudentsTable,
        studentMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to save  Assigned student in Halaqas (${student.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> upsertFollowUpPlans(FollowUpPlanModel followUpPlan) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";

    try {
      await _db.transaction((txn) async {
        final studentEnrollmentDbId = (await _fetchEnrollmentIdsByStudentIds(
          dbExecutor: txn,
          studentIds: [user.id],
          additionalWhere: 'isDeleted = ?',
          additionalArgs: [0],
        )).first;

        final followUpPlanMap = followUpPlan.toPlanDbMap(studentEnrollmentDbId);
        followUpPlanMap['tenant_id'] = tenantId;
        await txn.insert(
          _kFollowUpPlansTable,
          followUpPlanMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.update(
          _kPlanDetailsTable,
          {
            'isDeleted': 1,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'planUuid = ?',
          whereArgs: [followUpPlan.planId],
        );

        for (final detail in followUpPlan.details) {
          final detailMap = detail.toMap(planUuid: followUpPlan.planId);
          detailMap['tenant_id'] = tenantId;
          await txn.insert(
            _kPlanDetailsTable, // جدول التفاصيل
            detailMap, // تمرير planId للربط
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save student followUpPlan (): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> upsertStudentInfo(StudentInfoModel studentInfo) async {
    try {
      await upsertStudent(studentInfo.studentModel);
      await upsertHalqaStudent(
        studentInfo.assignedHalaqa,
        studentInfo.studentModel.id,
      );
      await upsertFollowUpPlans(studentInfo.followUpPlan);
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to save student all infos  (${studentInfo.studentModel.id}): ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteStudent() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final studentInfo = await getStudentInfo();
      await _db.transaction((txn) async {
        final studentDbId = (await _fetchStudentIdsByUuids(
          dbExecutor: _db,
          uuids: [tenantId],
        )).first;
        final studentEnrollmentDbId = (await _fetchEnrollmentIdsByStudentIds(
          dbExecutor: txn,
          studentIds: [studentDbId],
          additionalWhere: 'isDeleted = ?',
          additionalArgs: [0],
        )).first;

        final batch = txn.batch();
        _softDeleteStudentData(
          batch,
          studentInfo,
          studentDbId,
          studentEnrollmentDbId,
        );
        await batch.commit(noResult: true);
      });
      _dbChangeNotifier.add(null);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to delete student ($tenantId): ${e.toString()}',
      );
    }
  }

  void _softDeleteStudentData(
    Batch batch,
    StudentInfoModel studentInfo,
    int studentId,
    int enrollmentId,
  ) {
    batch.update(
      _kUsersTable,
      {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
      where: ' id = ?',
      whereArgs: [studentId],
    );
    if (studentInfo.assignedHalaqa.halaqaId == '0') {
      batch.update(
        _kHalqaStudentsTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},

        where: "halqaId = ? AND studentId = ? AND assignedAt = ?",
        whereArgs: [
          studentId,
          studentInfo.assignedHalaqa.halaqaId,
          studentInfo.assignedHalaqa.enrolledAt,
        ],
      );
    } else {
      batch.update(
        _kHalqaStudentsTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: "id = ?",
        whereArgs: [enrollmentId],
      );
    }
    final followUpPlan = studentInfo.followUpPlan;
    if (followUpPlan.details.isEmpty && followUpPlan.planId == '0') {
      batch.update(
        _kPlanDetailsTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: 'planUuid = ?',
        whereArgs: [followUpPlan.planId],
      );
    } else {
      batch.update(
        _kPlanDetailsTable,
        {'isDeleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
        where: 'planUuid = ?',
        whereArgs: [followUpPlan.planId],
      );
    }
  }

  @override
  Future<List<SyncQueueModel>> getPendingSyncOperations() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final maps = await _db.query(
        _kPendingOperationsTable,
        where: 'status = ? AND tenant_id = ?',
        whereArgs: ['pending', tenantId],
        orderBy: 'created_at ASC',
      );
      return maps.map(SyncQueueModel.fromMap).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get pending operations: ${e.toString()}',
      );
    }
  }

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if   not.
  @override
  Future<StudentModel> getStudent() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final maps = await _db.query(
        _kUsersTable,
        where: 'id = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [tenantId, 0, tenantId],
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'Student not found with ID: $tenantId');
      }

      return StudentModel.fromMap(maps.first, fromDb: true);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch student by ID ($tenantId): ${e.toString()}',
      );
    }
  }

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if   not.
  @override
  Future<AssignedHalaqasModel> getAssignedHalaqa() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final studentDbId = (await _fetchStudentIdsByUuids(
        dbExecutor: _db,
        uuids: [tenantId],
      )).first;

      final maps = await _db.query(
        _kHalqaStudentsTable,
        where: 'studentId = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [studentDbId, 0, tenantId],
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'Student not found with ID: $tenantId');
      }

      return AssignedHalaqasModel.fromMap(maps.first);
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch student by ID ($tenantId): ${e.toString()}',
      );
    }
  }

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if   not.
  @override
  Future<FollowUpPlanModel> getFollowUpPlan() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final studentnrollmentDbId = (await _fetchEnrollmentIdbyStudentUuids(
        dbExecutor: _db,
        uuids: [tenantId],
      )).first;

      final planMaps = await _db.query(
        _kFollowUpPlansTable,
        where: 'enrollmentId = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [studentnrollmentDbId, 0, tenantId],
      );

      if (planMaps.isEmpty) {
        throw CacheException(message: 'Follow-up plan not found');
      }
      final planUuid = planMaps.first['uuid'] as String;

      final detailsMaps = await _db.query(
        _kPlanDetailsTable,
        where: 'planUuid = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [planUuid, 0, tenantId],
      );

      return FollowUpPlanModel.fromMaps(
        planMap: planMaps.first,
        detailsMaps: detailsMaps,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch student by ID : ${e.toString()}',
      );
    }
  }

  /// Fetches a single student by their ID from the local database.
  /// Returns a [StudentModel] if found, or throws a [CacheException] if   not.
  @override
  Future<StudentInfoModel> getStudentInfo() async {
    try {
      final user = await getStudent();

      final assignedHalaqa = await getAssignedHalaqa();
      final followUpPlan = await getFollowUpPlan();

      return StudentInfoModel(
        studentModel: user,
        assignedHalaqa: assignedHalaqa,
        followUpPlan: followUpPlan,
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch student by ID : ${e.toString()}',
      );
    }
  }
  // =========================================================================
  //                       Follow-up Tracking Data Access
  // =========================================================================

  /// {@macro get_local_follow_up_trackings}
  @override
  Future<List<TrackingModel>> getFollowUpTrackings() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      // 1. Fetch the parent enrollment ID first.
      final enrollmentIds = await _fetchEnrollmentIdbyStudentUuids(
        dbExecutor: _db,
        uuids: [tenantId],
      );

      // If no enrollment record exists locally, there can be no trackings.
      if (enrollmentIds.isEmpty) {
        return [];
      }
      final enrollmentId = enrollmentIds.first;

      // 2. Fetch all parent tracking records for the given enrollment.
      final trackingMaps = await _db.query(
        _kDailyTrackingTable,
        where: 'enrollmentId = ? AND tenant_id = ?',
        whereArgs: [enrollmentId, tenantId],
        orderBy: 'trackDate DESC',
      );

      if (trackingMaps.isEmpty) {
        return [];
      }

      // 3. Efficiently fetch all child details for the retrieved trackings.
      final trackingIds = trackingMaps.map((map) => map['id'] as int).toList();
      final detailsByTrackingId =
          await _fetchAllTrackingDetailsGroupedByParentId(
            dbExecutor: _db,
            trackingIds: trackingIds,
          );

      // 4. Assemble the final models with their corresponding details.
      return trackingMaps.map((trackingMap) {
        final currentTrackingId = trackingMap['id'] as int;
        final currentDetailModels =
            detailsByTrackingId[currentTrackingId] ?? [];

        return TrackingModel.fromMap(trackingMap, currentDetailModels);
      }).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to fetch follow-up trackings from cache: ${e.toString()}',
      );
    }
  }

  // Replace the existing cacheFollowUpTrackings with this updated version.
  @override
  Future<void> cacheFollowUpTrackings({
    required List<TrackingModel> trackings,
  }) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    await _db.delete(_kDailyTrackingTable);
    await _db.delete(_kDailyTrackingDetailTable);

    // ROBUSTNESS: Verify the parent enrollment record exists locally first.
    final enrollmentIds = await _fetchEnrollmentIdbyStudentUuids(
      dbExecutor: _db,
      uuids: [tenantId],
    );

    if (enrollmentIds.isEmpty) {
      throw CacheException(
        message:
            'Cannot cache trackings. Parent enrollment for student UUID $tenantId not found.',
      );
    }
    final enrollmentId = enrollmentIds.first;

    try {
      // ATOMICITY: Perform the entire operation within a single transaction.
      await _db.transaction((txn) async {
        // Step 1: Cleanly delete old data. ON DELETE CASCADE will handle children.

        // Step 2: Iterate through the new tracking data from the server.
        for (final trackingModel in trackings) {
          // 2a. Insert the parent `daily_tracking` record and get its new local ID.
          final trackingMap = trackingModel.toMap(enrollmentId);
          log("$trackingMap");
          trackingMap['tenant_id'] = tenantId;
          final newParentTrackingId = await txn.insert(
            _kDailyTrackingTable,
            trackingMap,
          );

          if (trackingModel.details.isNotEmpty) {
            // Use a batch for inserting the mistakes for maximum efficiency.
            final mistakesBatch = txn.batch();

            for (final detailModel in trackingModel.details) {
              // 2b. Insert the `daily_tracking_detail` record and get its new local ID.
              final detailMap = detailModel.toMap(newParentTrackingId);
              detailMap['tenant_id'] = tenantId;
              final newDetailId = await txn.insert(
                _kDailyTrackingDetailTable,
                detailMap,
              );

              // 2c. If this detail has mistakes, add them to the batch.
              if (detailModel.mistakes.isNotEmpty) {
                for (final mistakeModel in detailModel.mistakes) {
                  // The `toMap` function needs the LOCAL ID of its parent detail.
                  final mistakeMap = mistakeModel.toMap(newDetailId);
                  mistakeMap['tenant_id'] = tenantId;
                  mistakesBatch.insert(_kMistakesTable, mistakeMap);
                }
              }
            }

            // Commit all mistakes for this tracking day in one go.
            await mistakesBatch.commit(noResult: true);
          }
        }
      });

      // Notify listeners that data has changed.
      _dbChangeNotifier.add(null);
    } on DatabaseException catch (e) {
      throw CacheException(
        message:
            'Failed to cache follow-up trackings in transaction: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, List<TrackingModel>>> getAllFollowUpTrackings() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      // 1. Fetch all student enrollments along with their UUIDs.
      final enrollmentMaps = await _db.rawQuery(
        '''
        SELECT HS.id, U.uuid
        FROM $_kHalqaStudentsTable HS
        JOIN $_kUsersTable U ON HS.studentId = U.id
        WHERE U.isDeleted = ? AND U.tenant_id = ?
      ''',
        [0, tenantId],
      );

      if (enrollmentMaps.isEmpty) {
        return {};
      }

      final enrollmentIds = enrollmentMaps
          .map((map) => map['id'] as int)
          .toList();
      final studentUuidByEnrollmentId = {
        for (var map in enrollmentMaps) map['id'] as int: map['uuid'] as String,
      };

      // 2. Fetch all tracking records for these enrollments.
      final trackingMaps = await _db.query(
        _kDailyTrackingTable,
        where:
            'enrollmentId IN (${List.filled(enrollmentIds.length, '?').join(',')}) AND tenant_id = ?',
        whereArgs: [...enrollmentIds, tenantId],
      );

      if (trackingMaps.isEmpty) {
        return {};
      }

      // 3. Efficiently fetch all child details and group them by trackingId.
      final trackingIds = trackingMaps.map((map) => map['id'] as int).toList();
      final detailsByTrackingId =
          await _fetchAllTrackingDetailsGroupedByParentId(
            dbExecutor: _db,
            trackingIds: trackingIds,
          );

      // 4. Assemble the final models.
      final allTrackings = trackingMaps.map((trackingMap) {
        final trackingId = trackingMap['id'] as int;
        final details = detailsByTrackingId[trackingId] ?? [];
        return TrackingModel.fromMap(trackingMap, details);
      }).toList();

      // 5. Group the assembled models by student UUID.
      final trackingsByStudentUuid = <String, List<TrackingModel>>{};
      for (final tracking in allTrackings) {
        final studentUuid = studentUuidByEnrollmentId[tracking.enrollmentId];
        if (studentUuid != null) {
          (trackingsByStudentUuid[studentUuid] ??= []).add(tracking);
        }
      }

      return trackingsByStudentUuid;
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch all follow-up trackings: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> importFollowUpTrackings({
    required Map<String, List<TrackingModel>> trackings,
    required ConflictResolution conflictResolution,
  }) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      await _db.transaction((txn) async {
        for (final entry in trackings.entries) {
          final studentId = entry.key;
          final studentTrackings = entry.value;

          final enrollmentIds = await _fetchEnrollmentIdbyStudentUuids(
            dbExecutor: txn,
            uuids: [studentId],
          );
          if (enrollmentIds.isEmpty) {
            // Handle case where student is not found
            continue;
          }
          final enrollmentId = enrollmentIds.first;

          for (final trackingModel in studentTrackings) {
            final trackingMap = trackingModel.toMap(enrollmentId);
            trackingMap['tenant_id'] = tenantId;

            final newParentTrackingId = await txn.insert(
              _kDailyTrackingTable,
              trackingMap,
              conflictAlgorithm:
                  conflictResolution == ConflictResolution.overwrite
                  ? ConflictAlgorithm.replace
                  : ConflictAlgorithm.ignore,
            );

            if (newParentTrackingId == 0) continue;

            for (final detailModel in trackingModel.details) {
              final detailMap = detailModel.toMap(newParentTrackingId);
              detailMap['tenant_id'] = tenantId;
              final newDetailId = await txn.insert(
                _kDailyTrackingDetailTable,
                detailMap,
              );

              for (final mistakeModel in detailModel.mistakes) {
                final mistakeMap = mistakeModel.toMap(newDetailId);
                mistakeMap['tenant_id'] = tenantId;
                await txn.insert(_kMistakesTable, mistakeMap);
              }
            }
          }
        }
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to import follow-up trackings: ${e.toString()}',
      );
    }
  }
}
