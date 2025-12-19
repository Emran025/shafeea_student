import 'package:injectable/injectable.dart';
import 'package:shafeea/core/api/api_consumer.dart';
import 'package:shafeea/core/api/end_ponits.dart';

import 'package:shafeea/features/home/data/models/student_model.dart';
import '../models/student_info_model.dart';
import '../models/tracking_model.dart';
import '../models/applicant_status_model.dart';
import 'student_remote_data_source.dart';

/// The concrete implementation of [StudentRemoteDataSource].
///
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// API endpoints, and parse the raw JSON responses into strongly-typed data models.
/// It relies on the [ApiConsumer] to handle underlying network errors and exceptions.

/// to perform all student-related data operations, including the complex
/// two-way synchronization logic.
@LazySingleton(as: StudentRemoteDataSource)
final class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiConsumer _apiConsumer;

  StudentRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;

  @override
  Future<StudentInfoModel> getStudent(String studentId) async {
    // The studentData is expected to be a UUID or similar identifier.
    final responseJson = await _apiConsumer.get(
      EndPoint.userProfile.replaceAll('{id}', studentId.toString()),
      // Example: '/students/some-uuid'
    );

    // Validate the response format.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid student response format: Expected a student object map.',
      );
    }

    // Parse and return the StudentModel.
    return StudentInfoModel.fromJson(responseJson['data']);
  }

  @override
  Future<StudentModel> upsertStudent(StudentModel studentData) async {
    // The API should handle both create (if no ID) and update (if ID exists)
    // with a single endpoint for simplicity.

    final responseJson = await _apiConsumer.post(
      EndPoint.userProfile.replaceAll('{id}', studentData.id),
      // Example: '/students/upsert'
      data: studentData,
    );

    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid upsert response format: Expected a student object map.',
      );
    }

    // The server returns the final state of the object, which we parse and return.
    return StudentModel.fromMap(responseJson);
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    // A DELETE request is sent to a URL that includes the student's ID.
    await _apiConsumer.delete(
      EndPoint.userProfile.replaceAll('{id}', studentId.toString()),
      // Example: DELETE /students/some-uuid
    );
    // On a successful 2xx response, we expect no content, so the method returns void.
  }

  // =========================================================================
  // Professional Implementation of getFollowUpTrackings
  // =========================================================================

  /// {@macro get_follow_up_trackings}
  @override
  Future<List<TrackingModel>> getFollowUpTrackings(String studentId) async {
    // 1. Prepare the dynamic endpoint path by replacing the placeholder.
    final String path = EndPoint.studentTrackings.replaceAll(
      '{id}',
      studentId.toString(),
    );

    // 2. Perform the API call. The ApiConsumer handles generic network errors.
    final responseJson = await _apiConsumer.get(path);

    // 3. Robustly validate the response structure.
    // The API is expected to return a Map with a 'data' key.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid API response: Expected a root JSON object but got another type.',
      );
    }

    // 4. Safely extract the list of data.
    // This pattern prevents crashes if 'data' is missing or not a list.
    final List<dynamic> trackingsListJson =
        responseJson['data'] as List<dynamic>? ?? [];

    // 5. Resiliently parse each item in the list into a TrackingModel.
    // A single malformed item in the list will be ignored instead of
    // crashing the entire process.
    return trackingsListJson
        .map((trackingJson) {
          try {
            if (trackingJson is! Map<String, dynamic>) {
              // Log this malformed item for debugging purposes.
              // For example: logger.warning('Skipping invalid item in tracking list: $trackingJson');
              return null;
            }
            return TrackingModel.fromJson(trackingJson);
          } catch (e) {
            // Log the parsing error for a specific item.
            // For example: logger.error('Failed to parse tracking item', error: e, stackTrace: stackTrace);
            return [];
          }
        })
        .whereType<TrackingModel>()
        .toList();
  }

  /// Fetches the current authenticated user's applicant status from the API.
  ///
  /// Calls `GET ${EndPoint.applicantStatus}` and parses the response into
  /// an [ApplicantStatusModel]. This method is defensive and will tolerate
  /// missing fields, returning reasonable defaults.
  @override
  Future<ApplicantStatusModel> getApplicantStatus() async {
    final responseJson = await _apiConsumer.get(EndPoint.applicantStatus);

    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid applicant status response: expected JSON object.',
      );
    }

    // The API returns the payload under `data` key in success responses.
    final data = responseJson['data'] as Map<String, dynamic>?;

    // If data is null, return the default 'not found' model.
    if (data == null) {
      return ApplicantStatusModel.fromJson(null);
    }

    // Normalize `rejection` which may be null or an object
    final rejectionJson = data['rejection'] as Map<String, dynamic>?;

    return ApplicantStatusModel.fromJson({
      'exists': data['exists'] ?? true,
      'role': data['role'] ?? 'applicant',
      'status': data['status'] ?? (data['status'] as String? ?? 'Undifind'),
      'moved_to_students_table': data['moved_to_students_table'] ?? false,
      'rejection': rejectionJson,
    });
  }
}
