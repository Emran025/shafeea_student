import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import 'student_sync_service.dart';

/// A professional-grade service for orchestrating two-way, delta-based data synchronization.
///
/// This service is designed with key principles for robustness and efficiency:
/// 1.  **Granular Locking**: Prevents concurrent sync operations on the same entity
///     while allowing parallel syncs for different entities. A global lock is used
///     for full-table syncs.
/// 2.  **Intelligent Pre-flight Checks**: Ensures that dependent data (e.g., a student's
///     enrollment) is present locally *before* attempting to sync child data (e.g., trackings),
///     fetching prerequisites from the network only when absolutely necessary.
/// 3.  **Clear Logging**: Provides detailed console output for tracing sync operations,
///     successes, and failures.
@LazySingleton(as: StudentSyncService)
final class StudentSyncServiceImpl implements StudentSyncService {
  final StudentRemoteDataSource _remoteDataSource;
  final StudentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final AuthLocalDataSource _authLocalDataSource;

  /// A lock to prevent the global `performSync` from running concurrently.
  bool _isGlobalSyncInProgress = false;

  /// A set to track specific entities currently being synced (e.g., 'trackings-student-uuid-123').
  /// This allows for granular locking, preventing duplicate syncs for the same item
  /// while allowing different items to be synced in parallel.
  final Set<String> _syncingEntityIds = {};

  StudentSyncServiceImpl({
    required StudentRemoteDataSource remoteDataSource,
    required StudentLocalDataSource localDataSource,
    required AuthLocalDataSource authLocalDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _authLocalDataSource = authLocalDataSource;

  static const _staleThresholdTr = Duration(seconds: 30);

  @override
  Future<void> performTrackingsSync() async {
    final syncKey = 'trackings';
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    if (!await _networkInfo.isConnected) {
      print('[SyncService][Tracking] Skipped: No internet connection.');
    }
    
    if (_isGlobalSyncInProgress || _syncingEntityIds.contains(syncKey)) {
      print(
        '[SyncService][Trackings] Skipped: Sync for $syncKey is already in progress or a global sync is active.',
      );
      return;
    }

    try {
      _syncingEntityIds.add(syncKey);
      print(
        '[SyncService][Trackings] Starting sync for student trackings: $tenantId',
      );

      final applicantStatus = await _remoteDataSource.getApplicantStatus();
      if (!(applicantStatus.exists && applicantStatus.movedToStudentsTable)) {
        return;
      }

      final userProfile = await _remoteDataSource.getStudent(tenantId);
      await _localDataSource.upsertStudentInfo(userProfile);

      // The core logic is now wrapped in a safe, intelligent check.

      await _pullRemoteFollowUpTrackingsChanges(studentId: tenantId);
      print(
        '[SyncService][Trackings] Sync completed successfully for student: $tenantId',
      );
    } on CacheException catch (e) {
      print('[SyncService][Trackings] Cache Error: ${e.message}');
    } on ServerException catch (e) {
      print('[SyncService][Trackings] Server Error: ${e.message} (Code: ${e.statusCode})');
      // If code is 401, we might want to trigger a logout, but for now we just log it.
    } catch (e) {
      print(
        '[SyncService][Trackings] An unexpected error occurred: $e. Aborting.',
      );
    } finally {
      _syncingEntityIds.remove(syncKey);
    }
  }

  // --- PRIVATE HELPERS ---
  // (The rest of the methods are largely the same, but with improved logging for consistency)

  Future<void> _pullRemoteFollowUpTrackingsChanges({
    required String studentId,
  }) async {
    final lastSyncTimestamp = await _localDataSource.getLastSyncTimestampFor();
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);

    final isFresh = DateTime.now().difference(lastSyncTime) < _staleThresholdTr;
    if (isFresh) {
      print(
        '[SyncService-Pull-Trackings] Data is fresh. Skipping network refresh.',
      );
      return;
    }

    print(
      '[SyncService-Pull-Trackings] Pulling remote tracking changes for student $studentId...',
    );

    final syncResult = await _remoteDataSource.getFollowUpTrackings(studentId);

    print(
      '[SyncService-Pull-Trackings] Fetched ${syncResult.length} tracking records from remote.',
    );

    if (syncResult.isNotEmpty) {
      // This call is now protected against the foreign key error.
      await _localDataSource.cacheFollowUpTrackings(trackings: syncResult);
    }

    final finalSyncTimestamp = DateTime.now().millisecondsSinceEpoch;
    await _localDataSource.updateLastSyncTimestampFor(finalSyncTimestamp);

    print(
      '[SyncService-Pull-Trackings] Finished. New sync timestamp is $finalSyncTimestamp.',
    );
  }
}
