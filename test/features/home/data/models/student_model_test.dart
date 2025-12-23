// test/features/home/data/models/student_model_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/features/home/data/models/student_model.dart';
import 'package:shafeea/features/home/domain/entities/student_entity.dart';


void main() {
  final tStudentModel = StudentModel(
    id: '1',
    name: 'Test Student',
    avatar: 'avatar',
    status: ActiveStatus.active,
    gender: Gender.male,
    birthDate: '2000-01-01',
    email: 'test@test.com',
    phone: '123',
    experienceYears: 1,
    country: 'EG',
    residence: 'Cairo',
    city: 'Cairo',
    qualification: 'degree',
    memorizationLevel: 'all',
    isDeleted: false,
    availableTime: '10:00',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  group('StudentModel', () {
    test('should be a subclass of StudentDetailEntity', () async {
      // Assert
      expect(tStudentModel.toDetailEntity(), isA<StudentDetailEntity>());
    });

    test('fromMap should return a valid model from JSON', () async {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'uuid': '1',
        'name': 'Test Student',
        'avatar': 'avatar',
        'status': 'active',
        'gender': 1,
        'birthDate': '2000-01-01',
        'email': 'test@test.com',
        'phone': '123',
        'experienceYears': 1,
        'country': 'EG',
        'residence': 'Cairo',
        'city': 'Cairo',
        'qualification': 'degree',
        'memorizationLevel': 'all',
        'isDeleted': false,
        'availableTime': '10:00',
        'createdAt': '2024-01-01',
        'lastModified': '2024-01-01',
      };

      // Act
      final result = StudentModel.fromMap(jsonMap);

      // Assert
      expect(result, tStudentModel);
    });

    test('toMap should return a JSON map containing the proper data', () async {
      // Act
      final result = tStudentModel.toMap();

      // Assert
      expect(result['uuid'], '1');
      expect(result['name'], 'Test Student');
      expect(result['status'], 'Active');
    });

    test('toDetailEntity should return a valid domain entity', () async {
      // Act
      final result = tStudentModel.toDetailEntity();

      // Assert
      expect(result.id, '1');
      expect(result.name, 'Test Student');
      expect(result.availableTime, const TimeOfDay(hour: 10, minute: 0));
    });
  });
}
