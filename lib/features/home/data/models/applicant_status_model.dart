import 'applicant_rejection_model.dart';

class ApplicantStatusModel {
  final bool exists;
  final String role;
  final String status;
  final bool movedToStudentsTable;
  final ApplicantRejectionModel? rejection;

  ApplicantStatusModel({
    required this.exists,
    required this.role,
    required this.status,
    required this.movedToStudentsTable,
    this.rejection,
  });

  factory ApplicantStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ApplicantStatusModel(
        exists: false,
        role: 'Undifind',
        status: 'Undifind',
        movedToStudentsTable: true,
        rejection: null,
      );
    }

    final rejectionJson = json['rejection'] as Map<String, dynamic>?;

    return ApplicantStatusModel(
      exists: json['exists'] as bool? ?? false,
      role: json['role'] as String? ?? 'Undifind',
      status: json['status'] as String? ?? 'Undifind',
      movedToStudentsTable: json['movedToStudentsTable'] as bool? ?? false,
      rejection: ApplicantRejectionModel.fromJson(rejectionJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'exists': exists,
    'role': role,
    'status': status,
    'movedToStudentsTable': movedToStudentsTable,
    'rejection': rejection?.toJson(),
  };
}
