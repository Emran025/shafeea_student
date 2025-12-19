import 'package:equatable/equatable.dart';

class StudentApplicant extends Equatable {
  final String name;
  final String email;
  final String password;
  final String bio;
  final String qualifications;
  final int? memorizationLevel;
  final String? gender;
  final String? birthDate;
  final String? phone;
  final String? phoneZone;
  final String? whatsapp;
  final String? whatsappZone;
  final String? country;
  final String? residence;

  const StudentApplicant({
    required this.name,
    required this.email,
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
  });

  @override
  List<Object?> get props => [email, name, phone];
}