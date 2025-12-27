import 'package:shafeea/features/home/data/models/student_model.dart';

import '../../../../core/models/active_status.dart';
import '../../../../core/models/gender.dart';
import '../../domain/entities/student_applicant.dart';

class StudentApplicantModel extends StudentApplicantEntity {
  const StudentApplicantModel({
    required super.name,
    required super.email,
    required super.password,
    required super.bio,
    required super.qualifications,
    super.memorizationLevel,
    super.gender,
    super.birthDate,
    super.phone,
    super.phoneZone,
    super.whatsapp,
    super.whatsappZone,
    super.country,
    super.residence,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'bio': bio,
      'qualifications': qualifications,
      'memorization_level': memorizationLevel ?? 0,
      'gender': gender?.label ?? Gender.male.label,
      'birth_date': birthDate,
      'phone': phone,
      'phone_zone': phoneZone,
      'whatsapp': whatsapp,
      'whatsapp_zone': whatsappZone,
      'country': country,
      'residence': residence,
    };
  }

  factory StudentApplicantModel.fromEntity(StudentApplicantEntity entity) {
    return StudentApplicantModel(
      name: entity.name,
      email: entity.email,
      password: entity.password,
      bio: entity.bio,
      qualifications: entity.qualifications,
      memorizationLevel: entity.memorizationLevel,
      gender: entity.gender,
      birthDate: entity.birthDate,
      phone: entity.phone,
      phoneZone: entity.phoneZone,
      whatsapp: entity.whatsapp,
      whatsappZone: entity.whatsappZone,
      country: entity.country,
      residence: entity.residence,
    );
  }

  // to Student Model
  StudentModel toStudentModel(String id) {
    return StudentModel(
      id: id,
      name: name,
      email: email,
      bio: bio,
      memorizationLevel: memorizationLevel.toString(),
      gender: gender ?? Gender.male,
      birthDate: birthDate ?? DateTime.now().toString(),
      phone: phone ?? '',
      phoneZone: phoneZone,
      whatsappPhone: whatsapp,
      whatsappZone: whatsappZone,
      country: country ?? '',
      residence: residence ?? '',
      experienceYears: 0,
      city: '',
      qualification: qualifications,
      status: ActiveStatus.inactive,
      isDeleted: false,
    );
  }
}
