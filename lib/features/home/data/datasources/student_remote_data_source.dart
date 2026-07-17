import '../models/follow_up_plan_model.dart';
import '../models/student_info_model.dart';
import '../models/student_model.dart';
import '../models/tracking_model.dart';
import '../models/applicant_status_model.dart';

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies the methods for fetching and manipulating student
/// data from the remote API. All methods must return data layer models (e.g.,
/// [StudentModel]) and are expected to throw a [ServerException] upon API failure.

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies all methods for interacting with the student-related
/// endpoints of the remote API. It is designed to support a robust, two-way
/// synchronization mechanism.

abstract interface class StudentRemoteDataSource {
  /// Fetches a single student by their unique identifier (UUID).
  /// - [studentData]: A map containing the student's UUID and other identifying information.
  /// Returns the [StudentModel] for the specified student.
  Future<StudentInfoModel> getStudent(String studentData);

  /// Pushes a create or update operation for a single student to the server.
  ///
  /// This is the core method for the "push" stage of synchronization.
  /// - [studentData]: A map containing the full data of the student to be created or updated.
  ///
  /// Returns the final, server-confirmed [StudentModel].
  Future<StudentModel> upsertStudent(StudentModel studentData);

  // You can add other methods like:
  // Future<StudentModel> updateStudent({required String id, required Map<String, dynamic> studentData});
  // Future<void> deleteStudent({required String id});
  /// Deletes a student by their ID via the remote API.
  /// - [studentId]: The ID of the student to delete.
  /// Returns a [Future] that completes when the deletion is successful.
  Future<void> deleteStudent(String studentId);
  Future<List<TrackingModel>> getFollowUpTrackings(String studentId);
  Future<ApplicantStatusModel> getApplicantStatus();
  Future<FollowUpPlanModel> createPlan({
    required String studentId,
    required FollowUpPlanModel plan,
    required String halaqahId,
  });
}
