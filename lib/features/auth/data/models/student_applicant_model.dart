import '../../domain/entities/student_applicant.dart';

class StudentApplicantModel extends StudentApplicant {
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
      'password_confirmation': password, // تأكيد كلمة المرور مطلوب في Laravel
      'bio': bio,
      'qualifications': qualifications,
      'memorization_level': memorizationLevel,
      'gender': gender,
      'birth_date': birthDate,
      'phone': phone,
      'phone_zone': phoneZone,
      'whatsapp': whatsapp,
      'whatsapp_zone': whatsappZone,
      'country': country,
      'residence': residence,
      // الحقول الأخرى...
    };
  }
}