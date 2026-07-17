import 'package:equatable/equatable.dart';
import 'package:shafeea/core/models/gender.dart';

class StudentApplicantEntity extends Equatable {
  final String name;
  final String email;
  final String username;
  final String password;
  final String bio;
  final String qualifications;
  final int? memorizationLevel;
  final Gender? gender;
  final String? birthDate;
  final String? phone;
  final String? phoneZone;
  final String? whatsapp;
  final String? whatsappZone;
  final String? country;
  final String? residence;
  final int? schoolId;

  const StudentApplicantEntity({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.bio,
    required this.qualifications,
    this.memorizationLevel,
    this.gender,
    this.birthDate,
    this.phone,
    this.phoneZone,
    this.whatsapp,
    this.whatsappZone,
    this.country,
    this.residence,
    this.schoolId,
  });

  @override
  List<Object?> get props => [email, username, name, phone, schoolId];
}