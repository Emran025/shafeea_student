import 'package:flutter/foundation.dart';

@immutable
class AssignedHalaqasEntity {
  final String id;
  final String name;
  final String avatar;
  final String enrolledAt;
  final String? enrollmentId;
  final String halaqaId;

  const AssignedHalaqasEntity({
    required this.id,
    this.enrollmentId,
    required this.halaqaId,
    required this.name,
    required this.avatar,
    required this.enrolledAt,
  });
}
