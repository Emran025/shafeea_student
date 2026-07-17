import '../../domain/entities/school_entity.dart';

/// Data-layer model for a school returned by `GET /api/v1/schools`.
class SchoolModel extends SchoolEntity {
  const SchoolModel({
    required super.id,
    required super.name,
    super.logo,
    super.city,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      city: json['city'] as String?,
    );
  }

  SchoolEntity toEntity() => SchoolEntity(
        id: id,
        name: name,
        logo: logo,
        city: city,
      );
}
