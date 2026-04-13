// test/features/home/data/models/student_info_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/home/data/models/student_info_model.dart';
import 'package:shafeea/features/home/domain/entities/student_info_entity.dart';


void main() {
  const tHalaqaJson = {
    'id': 1,
    'name': 'Halaqa Test',
    'avatar': 'avatar',
    'enrolledAt': '2024-01-01',
  };

  const tFollowUpPlanJson = {
    'planId': 101,
    'frequency': 'daily',
    'details': [],
  };

  final tStudentInfoMap = {
    'uuid': '1',
    'name': 'Test Student',
    'halaqa': tHalaqaJson,
    'followUpPlan': tFollowUpPlanJson,
  };

  group('StudentInfoModel', () {
    test('fromJson should return a valid model', () async {
      // Act
      final result = StudentInfoModel.fromJson(tStudentInfoMap);

      // Assert
      expect(result.studentModel.id, '1');
      expect(result.assignedHalaqa.name, 'Halaqa Test');
      expect(result.followUpPlan.serverPlanId, '101');
    });

    test('toStudentInfoEntity should return a valid domain entity', () async {
      // Arrange
      final model = StudentInfoModel.fromJson(tStudentInfoMap);

      // Act
      final result = model.toStudentInfoEntity();

      // Assert
      expect(result, isA<StudentInfoEntity>());
      expect(result.studentDetailEntity.id, '1');
    });
  });
}
