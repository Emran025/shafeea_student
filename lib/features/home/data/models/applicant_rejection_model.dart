class ApplicantRejectionModel {
  final String? reason;
  final dynamic schoolId;

  ApplicantRejectionModel({this.reason, this.schoolId});

  factory ApplicantRejectionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ApplicantRejectionModel();
    return ApplicantRejectionModel(
      reason: json['reason'] as String?,
      schoolId: json['school_id'],
    );
  }

  Map<String, dynamic> toJson() => {'reason': reason, 'school_id': schoolId};
}
