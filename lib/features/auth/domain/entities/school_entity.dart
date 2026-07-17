import 'package:equatable/equatable.dart';

/// Domain entity representing a school available for selection
/// during student registration.
class SchoolEntity extends Equatable {
  final int id;
  final String name;
  final String? logo;
  final String? city;

  const SchoolEntity({
    required this.id,
    required this.name,
    this.logo,
    this.city,
  });

  @override
  List<Object?> get props => [id, name, logo, city];
}
