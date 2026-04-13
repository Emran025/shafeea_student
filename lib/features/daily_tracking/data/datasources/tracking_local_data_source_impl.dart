import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:uuid/uuid.dart';

// Core imports
import 'package:shafeea/core/database/app_database.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/models/tracking_type.dart';

// Models
import 'package:shafeea/features/home/data/models/tracking_detail_model.dart';
import 'package:shafeea/features/daily_tracking/data/models/mistake_model.dart';

// The contract it implements
import 'package:shafeea/features/daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:shafeea/core/models/bar_chart_datas.dart';
import 'package:shafeea/core/models/chart_data_point.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';
import '../../domain/entities/stop_point.dart';
import 'tracking_local_data_source.dart';
import 'package:shafeea/core/models/mistake_type.dart';

// Models

// Table and column name constants for consistency.
const String _kDailyTrackingTable = 'daily_tracking';
const String _kHalqaStudentsTable = 'halqa_students';

const String _kDailyTrackingDetailTable = 'daily_tracking_detail';
const String _kMistakesTable = 'mistakes';

/// The concrete implementation of [TrackingLocalDataSource].
///
/// This class handles all direct database interactions for the interactive
/// recitation tracking feature. It manages "draft" sessions, saves progress,
/// finalizes reports, and queues operations for synchronization, all while
/// maintaining data integrity through transactions and robust error handling.
@LazySingleton(as: TrackingLocalDataSource)
final class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  final AppDatabase _appDb;
  final QuranLocalDataSource _quranDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  TrackingLocalDataSourceImpl(
    this._appDb,
    this._quranDataSource,
    this._authLocalDataSource,
  );

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
              'Could not find a matching database ID for enrollmentIds studentId: $uuid',
        );
      }
      orderedIds.add(id);
    }
    return orderedIds;
  }

  Future<int> _fetchStudentIdByUuid({
    required DatabaseExecutor dbExecutor,
    required String uuid,
  }) async {
    final maps = await dbExecutor.query(
      'users',
      columns: ['id'],
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw CacheException(
        message: 'Could not find local student ID for server user_id: $uuid',
      );
    }
    return maps.first['id'] as int;
  }
  // =========================================================================
  //                             Core Public Methods
  // =========================================================================

  @override
  Future<Map<TrackingType, TrackingDetailModel>>
  getOrCreateTodayDraftTrackingDetails() async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      // 1. Resolve the local database ID for the current user.
      // In the local DB, the server's user_id is stored in the 'uuid' column.
      final localStudentId = await _fetchStudentIdByUuid(
        dbExecutor: db,
        uuid: user.id.toString(),
      );

      // 2. Fetch the enrollment ID for this student.
      final studentEnrollmentDbId = (await _fetchEnrollmentIdsByStudentIds(
        dbExecutor: db,
        studentIds: [localStudentId],
        additionalWhere: 'isDeleted = ?',
        additionalArgs: [0],
      )).first;
      
      final trackingRecord = await _findOrCreateParentDraftTracking(
        db,
        studentEnrollmentDbId,
        tenantId,
      );
      final trackingId = trackingRecord['id'] as int;

      var detailMaps = await db.query(
        _kDailyTrackingDetailTable,
        where: 'trackingId = ?',
        whereArgs: [trackingId],
      );
      if (detailMaps.length < 3) {
        final lastUnitsMap = await _getLastCompletedUnitIds(
          db,
          studentEnrollmentDbId,
          tenantId,
        );
        await _createMissingDetails(
          db,
          trackingId,
          tenantId,
          startUnits: lastUnitsMap,
        );
        detailMaps = await db.query(
          _kDailyTrackingDetailTable,
          where: 'trackingId = ?',
          whereArgs: [trackingId],
        );
      }

      final List<TrackingDetailModel> fullDetails =
          await _fetchDetailsWithMistakes(db, detailMaps);
      return {for (var detail in fullDetails) detail.trackingTypeId: detail};
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to get/create tracking details: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveDraftTrackingDetails(
    List<TrackingDetailModel> details,
  ) async {
    if (details.isEmpty) return;
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final detail in details) {
          batch.update(
            _kDailyTrackingDetailTable,
            detail.toMap(detail.trackingId),
            where: 'id = ?',
            whereArgs: [detail.id],
          );
          batch.delete(
            _kMistakesTable,
            where: 'trackingDetailId = ?',
            whereArgs: [detail.id],
          );
          for (final mistake in detail.mistakes) {
            final mistakeMap = mistake.toMap(detail.id);
            mistakeMap['tenant_id'] = tenantId;
            batch.insert(_kMistakesTable, mistakeMap);
          }
        }
        await batch.commit(noResult: true);
      });
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to save draft tracking progress: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveDraftMistakes({required List<MistakeModel> mistakes}) async {
    if (mistakes.isEmpty) return;

    final db = await _appDb.database;
    final user = await _authLocalDataSource.getUser();

    // Ensure user exists to avoid null pointer exceptions
    if (user == null) return;

    final tenantId = user.id.toString();

    try {
      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final mistake in mistakes) {
          // 1. Add Delete operation to batch
          // Optimization: Added tenantId to the WHERE clause for data safety
          batch.delete(
            _kMistakesTable,
            where:
                'ayahId_quran = ? AND wordIndex = ? AND tenant_id = ? And trackingDetailId IS NULL',
            whereArgs: [mistake.ayahIdQuran, mistake.wordIndex, tenantId],
          );

          // 2. Prepare the map
          final mistakeMap = mistake.toMap(null); // trackingDetailId is null
          mistakeMap['tenant_id'] = tenantId;

          // 3. Add Insert operation to batch
          batch.insert(_kMistakesTable, mistakeMap);
        }

        // 4. Final Commit: Execute everything in one single atomic operation
        await batch.commit(noResult: true);
      });
    } on DatabaseException catch (e) {
      // Log error here (e.g., Firebase Crashlytics)
      throw CacheException(
        message: 'Failed to save draft tracking progress: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MistakeModel>> getAllMistakes({
    TrackingType? type,
    int? fromPage,
    int? toPage,
  }) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";

    final localStudentId = await _fetchStudentIdByUuid(
      dbExecutor: db,
      uuid: user.id.toString(),
    );

    final studentEnrollmentDbId = (await _fetchEnrollmentIdsByStudentIds(
      dbExecutor: db,
      studentIds: [localStudentId],
      additionalWhere: 'isDeleted = ?',
      additionalArgs: [0],
    )).first;

    try {
      String baseQuery =
          '''
      SELECT m.*
      FROM $_kMistakesTable AS m
      INNER JOIN $_kDailyTrackingDetailTable AS tdt ON m.trackingDetailId = tdt.id
      INNER JOIN $_kDailyTrackingTable AS dt ON tdt.trackingId = dt.id
      INNER JOIN quran AS q ON m.ayahId_quran = q.id 
      WHERE dt.enrollmentId = ? AND dt.tenant_id = ?
        -- AND tdt.status = 'completed'
    ''';

      List<dynamic> arguments = [studentEnrollmentDbId, tenantId];

      // ================== DYNAMIC TYPE FILTERING ==================
      if (type != null) {
        baseQuery += ' AND tdt.typeId = ?';
        arguments.add(type.id);
      }
      // ==========================================================

      if (fromPage != null) {
        baseQuery += ' AND q.page >= ?';
        arguments.add(fromPage);
      }

      if (toPage != null) {
        baseQuery += ' AND q.page <= ?';
        arguments.add(toPage);
      }

      // Add ordering to make the result predictable and easy to group
      baseQuery += ' ORDER BY tdt.typeId, dt.trackDate DESC';

      final List<Map<String, dynamic>> results = await db.rawQuery(
        baseQuery,
        arguments,
      );
      return results.map((map) => MistakeModel.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch all mistakes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BarChartDatas>> getErrorAnalysisChartData({
    required ChartFilter filter,
  }) async {
    final db = await _appDb.database;
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    final localStudentId = await _fetchStudentIdByUuid(
      dbExecutor: db,
      uuid: user.id.toString(),
    );
    final studentEnrollmentDbId = (await _fetchEnrollmentIdsByStudentIds(
      dbExecutor: db,
      studentIds: [localStudentId],
      additionalWhere: 'isDeleted = ?',
      additionalArgs: [0],
    )).first;
    try {
      if (filter.dimension == FilterDimension.time) {
        return _fetchDataByTime(db, studentEnrollmentDbId, tenantId, filter);
      } else {
        return _fetchDataByQuantity(
          db,
          studentEnrollmentDbId,
          tenantId,
          filter,
        );
      }
    } on DatabaseException catch (e) {
      throw CacheException(
        message: 'Failed to fetch error analysis data: ${e.toString()}',
      );
    }
  }

  Future<List<BarChartDatas>> _fetchDataByTime(
    Database db,
    int enrollmentId,
    String tenantId,
    ChartFilter filter,
  ) async {
    String dateFormat;
    bool isQuarter = filter.timePeriod == 'quarter';

    if (isQuarter) {
      dateFormat = '%Y-%m'; // Fetch by month, then group by quarter in Dart
    } else {
      switch (filter.timePeriod) {
        case 'year':
          dateFormat = '%Y';
          break;
        case 'week':
          dateFormat = '%Y-%W';
          break;
        default:
          dateFormat = '%Y-%m';
      }
    }

    final query =
        '''
      SELECT
        m.mistakeTypeId,
        COUNT(m.id) as mistakeCount,
        STRFTIME('$dateFormat', dt.trackDate) as period
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ? AND dt.tenant_id = ?
      GROUP BY period, m.mistakeTypeId
      ORDER BY period ASC;
    ''';

    final trackingType = TrackingType.values.firstWhere(
      (e) => e.toString().endsWith(filter.trackingType),
    );
    final results = await db.rawQuery(query, [
      enrollmentId,
      trackingType.id,
      tenantId,
    ]);
    if (results.isEmpty) return [];

    if (isQuarter) {
      return _groupMonthsIntoQuarters(results);
    }

    // Group by period (for non-quarter filters)
    final groupedByPeriod = groupBy<Map<String, dynamic>, String>(
      results,
      (row) => row['period'],
    );

    final List<BarChartDatas> chartDataList = [];
    for (final period in groupedByPeriod.keys) {
      final periodMistakes = groupedByPeriod[period]!;
      final dataPoints = _calculateDataPoints(periodMistakes);

      DateTime? periodDate;
      if (filter.timePeriod == 'year') {
        periodDate = DateTime.tryParse('$period-01-01');
      } else if (filter.timePeriod == 'week') {
        final parts = period.split('-');
        final year = int.parse(parts[0]);
        final week = int.parse(parts[1]);
        // This is an approximation: the first day of the week.
        periodDate = DateTime(year, 1, 1).add(Duration(days: (week - 1) * 7));
      } else {
        periodDate = DateTime.tryParse('$period-01');
      }

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: ' أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodDate: periodDate,
        ),
      );
    }
    return chartDataList;
  }

  List<BarChartDatas> _groupMonthsIntoQuarters(
    List<Map<String, dynamic>> monthlyResults,
  ) {
    final groupedByQuarter = groupBy<Map<String, dynamic>, String>(
      monthlyResults,
      (row) {
        final yearMonth = (row['period'] as String).split('-');
        final month = int.parse(yearMonth[1]);
        final quarter = (month - 1) ~/ 3 + 1;
        return '${yearMonth[0]}-Q$quarter';
      },
    );

    final List<BarChartDatas> chartDataList = [];
    for (final quarter in groupedByQuarter.keys) {
      final quarterMistakes = groupedByQuarter[quarter]!;
      final dataPoints = _calculateDataPoints(quarterMistakes);

      final year = int.parse(quarter.split('-Q')[0]);
      final quarterNum = int.parse(quarter.split('-Q')[1]);
      final month = (quarterNum - 1) * 3 + 1;
      final periodDate = DateTime(year, month, 1);

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: 'أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodDate: periodDate,
        ),
      );
    }
    return chartDataList;
  }

  List<ChartDataPoint> _calculateDataPoints(
    List<Map<String, dynamic>> mistakes,
  ) {
    return MistakeType.values.where((e) => e != MistakeType.none).map((
      mistakeType,
    ) {
      final count = mistakes
          .where((r) => r['mistakeTypeId'] == mistakeType.id)
          .fold<int>(0, (sum, r) => sum + (r['mistakeCount'] as int));
      return ChartDataPoint(
        label: mistakeType.labelAr,
        value: count.toDouble(),
      );
    }).toList();
  }

  Future<List<BarChartDatas>> _fetchDataByQuantity(
    Database db,
    int enrollmentId,
    String tenantId,
    ChartFilter filter,
  ) async {
    final trackingType = TrackingType.values.firstWhere(
      (e) => e.toString().endsWith(filter.trackingType),
    );
    final allMistakesQuery =
        '''
      SELECT m.mistakeTypeId, m.ayahId_quran
      FROM $_kMistakesTable AS m
      JOIN $_kDailyTrackingDetailTable AS dtd ON m.trackingDetailId = dtd.id
      JOIN $_kDailyTrackingTable AS dt ON dtd.trackingId = dt.id
      WHERE dt.enrollmentId = ? AND dtd.typeId = ? AND dt.tenant_id = ?;
    ''';
    final mistakeResults = await db.rawQuery(allMistakesQuery, [
      enrollmentId,
      trackingType.id,
      tenantId,
    ]);
    if (mistakeResults.isEmpty) return [];

    // 2. Get Ayah details from Quran DB
    final ayahIds = mistakeResults
        .map((r) => r['ayahId_quran'] as int)
        .toSet()
        .toList();
    final ayahs = await _quranDataSource.getMistakesAyahs(ayahIds);
    final ayahMap = {for (var ayah in ayahs) ayah.number: ayah};

    // 3. Group mistakes by the quantitative unit
    String Function(int) getGroupingKey;
    switch (filter.quantityUnit) {
      case 'juz':
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.juz.toString() ?? '0';
        break;
      case 'hizb':
        getGroupingKey = (ayahId) => (ayahMap[ayahId]?.juz ?? 0 / 2).toString();
        break;
      case 'page':
      default:
        getGroupingKey = (ayahId) => ayahMap[ayahId]?.page.toString() ?? '0';
        break;
    }

    final groupedMistakes = groupBy<Map<String, dynamic>, String>(
      mistakeResults,
      (row) => getGroupingKey(row['ayahId_quran']),
    );

    final List<BarChartDatas> chartDataList = [];
    final sortedKeys = groupedMistakes.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    for (final key in sortedKeys) {
      final groupMistakes = groupedMistakes[key]!;
      final dataPoints = MistakeType.values
          .where((e) => e != MistakeType.none)
          .map((mistakeType) {
            final count = groupMistakes
                .where((r) => r['mistakeTypeId'] == mistakeType.id)
                .length;
            return ChartDataPoint(
              label: mistakeType.labelAr,
              value: count.toDouble(),
            );
          })
          .toList();

      chartDataList.add(
        BarChartDatas(
          data: dataPoints,
          xAxisLabel: 'أنواع الأخطاء',
          yAxisLabel: 'العدد',
          periodLabel: _getFormattedPeriodLabel(filter.quantityUnit, key),
        ),
      );
    }

    return chartDataList;
  }

  String _getFormattedPeriodLabel(String quantityUnit, String key) {
    switch (quantityUnit) {
      case 'juz':
        return 'الجزء $key';
      case 'hizb':
        return 'الحزب $key';
      case 'page':
        return 'صفحة $key';
      default:
        return 'الفترة $key';
    }
  }

  // =========================================================================
  //                             Private Helper Methods
  // =========================================================================

  /// Finds the most recent draft tracking record for a student, or creates a new one for today if none exists.
  Future<Map<String, dynamic>> _findOrCreateParentDraftTracking(
    Database db,
    int enrollmentId,
    String tenantId,
  ) async {
    final lastDraft = await db.query(
      _kDailyTrackingTable,
      where: 'enrollmentId = ? AND status = ? AND tenant_id = ?',
      whereArgs: [enrollmentId, 'draft', tenantId],
      orderBy: 'trackDate DESC',
      limit: 1,
    );
    if (lastDraft.isNotEmpty) {
      return lastDraft.first;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final newRecord = {
      'uuid': const Uuid().v4(),
      'enrollmentId': enrollmentId,
      'trackDate': today,
      'status': 'draft',
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'tenant_id': tenantId,
    };
    final newId = await db.insert(_kDailyTrackingTable, newRecord);
    return (await db.query(
      _kDailyTrackingTable,
      where: 'id = ?',
      whereArgs: [newId],
    )).first;
  }

  /// Creates default detail rows for a new parent tracking record, intelligently setting the start point for each.
  Future<void> _createMissingDetails(
    Database db,
    int trackingId,
    String tenantId, {
    required Map<TrackingType, StopPoint> startUnits,
  }) async {
    final batch = db.batch();
    for (final type in TrackingType.values) {
      final startPoint = startUnits[type] ?? StopPoint();
      final startUnitId = startPoint.unitIndex;
      final startUnitGap = startPoint.gap;
      batch.insert(_kDailyTrackingDetailTable, {
        'uuid': const Uuid().v4(),
        'trackingId': trackingId,
        'typeId': type.id,
        'status': 'draft',
        'fromTrackingUnitId': startUnitId,
        'toTrackingUnitId': startUnitId,
        'gap': startUnitGap,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
        'tenant_id': tenantId,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a map of the last `toTrackingUnitId` for each tracking type individually from the student's past COMPLETED sessions.
  Future<Map<TrackingType, StopPoint>> _getLastCompletedUnitIds(
    Database db,
    int enrollmentId,
    String tenantId,
  ) async {
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT tdt.typeId, tdt.toTrackingUnitId, gap
      FROM $_kDailyTrackingDetailTable AS tdt
      INNER JOIN (
          SELECT tdt_inner.typeId, MAX(dt_inner.trackDate) AS max_date
          FROM $_kDailyTrackingDetailTable AS tdt_inner
          INNER JOIN $_kDailyTrackingTable AS dt_inner ON tdt_inner.trackingId = dt_inner.id
          WHERE dt_inner.enrollmentId = ? AND tdt_inner.status = 'completed' AND tdt_inner.toTrackingUnitId IS NOT NULL AND dt_inner.tenant_id = ?
          GROUP BY tdt_inner.typeId
      ) AS max_dates ON tdt.typeId = max_dates.typeId
      INNER JOIN $_kDailyTrackingTable AS dt ON tdt.trackingId = dt.id AND dt.trackDate = max_dates.max_date
      WHERE dt.enrollmentId = ? AND dt.tenant_id = ? -- AND tdt.status = 'completed'
    ''',
      [enrollmentId, tenantId, enrollmentId, tenantId],
    );

    if (results.isEmpty) return {};
    return {
      for (var row in results)
        TrackingType.fromId(row['typeId'] as int): StopPoint(
          unitIndex: row['toTrackingUnitId'] as int,
          gap: row['gap'] as double,
        ),
    };
  }

  /// Assembles fully formed `TrackingDetailModel` objects by fetching and attaching their child `MistakeModel`s.
  Future<List<TrackingDetailModel>> _fetchDetailsWithMistakes(
    DatabaseExecutor db,
    List<Map<String, dynamic>> detailMaps,
  ) async {
    if (detailMaps.isEmpty) return [];
    final detailIds = detailMaps.map((d) => d['id'] as int).toList();
    final mistakesByDetailId =
        await _fetchGroupedByForeignKey<int, MistakeModel>(
          dbExecutor: db,
          tableName: _kMistakesTable,
          foreignKeyColumn: 'trackingDetailId',
          foreignKeys: detailIds,
          fromMap: MistakeModel.fromMap,
        );
    return detailMaps.map((detailMap) {
      final detailId = detailMap['id'] as int;
      final mistakes = mistakesByDetailId[detailId] ?? [];
      return TrackingDetailModel.fromMap(detailMap, mistakes);
    }).toList();
  }

  /// Generic helper to fetch and group child records efficiently.
  Future<Map<K, List<T>>> _fetchGroupedByForeignKey<K, T>({
    required DatabaseExecutor dbExecutor,
    required String tableName,
    required String foreignKeyColumn,
    required List<K> foreignKeys,
    required T Function(Map<String, dynamic> map) fromMap,
  }) async {
    if (foreignKeys.isEmpty) return {};
    final maps = await dbExecutor.query(
      tableName,
      where:
          '$foreignKeyColumn IN (${List.filled(foreignKeys.length, '?').join(',')})',
      whereArgs: foreignKeys,
    );
    final groupedRawMaps = groupBy<Map<String, dynamic>, K>(
      maps,
      (map) => map[foreignKeyColumn] as K,
    );
    return groupedRawMaps.map(
      (key, value) => MapEntry(key, value.map(fromMap).toList()),
    );
  }
}
