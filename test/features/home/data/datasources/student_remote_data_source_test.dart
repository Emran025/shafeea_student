// test/features/home/data/datasources/student_remote_data_source_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/api/end_ponits.dart';
import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/features/home/data/datasources/student_remote_data_source_impl.dart';
import 'package:shafeea/features/home/data/models/student_info_model.dart';
import 'package:shafeea/features/home/data/models/student_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late StudentRemoteDataSourceImpl dataSource;
  late MockApiConsumer mockApi;

  setUp(() {
    mockApi = MockApiConsumer();
    dataSource = StudentRemoteDataSourceImpl(apiConsumer: mockApi);
  });

  group('getStudent', () {
    const tStudentId = '1';
    final tStudentInfoJson = {
      'data': {
        'uuid': '1',
        'name': 'Test Student',
        'halaqa': {'id': 1},
        'followUpPlan': {'PlanId': 101},
      },
    };

    test(
      'should perform a GET request on a destination URL with student ID',
      () async {
        // Arrange
        when(
          () => mockApi.get(any()),
        ).thenAnswer((_) async => tStudentInfoJson);

        // Act
        await dataSource.getStudent(tStudentId);

        // Assert
        verify(
          () => mockApi.get(
            EndPoint.userProfile.replaceFirst('{id}', tStudentId),
          ),
        );
      },
    );

    test(
      'should return StudentInfoModel when the response code is 2xx',
      () async {
        // Arrange
        when(
          () => mockApi.get(any()),
        ).thenAnswer((_) async => tStudentInfoJson);

        // Act
        final result = await dataSource.getStudent(tStudentId);

        // Assert
        expect(result, isA<StudentInfoModel>());
        expect(result.studentModel.id, tStudentId);
      },
    );
  });

  group('upsertStudent', () {
    final tStudentModel = StudentModel(
      id: '1',
      name: 'Test',
      gender: Gender.male,
      birthDate: '2000',
      email: 'a@a.com',
      phone: '12',
      experienceYears: 1,
      country: 'EG',
      residence: 'C',
      city: 'C',
      status: ActiveStatus.active,
      memorizationLevel: 'All',
      qualification: 'B',
      isDeleted: false,
    );

    test('should perform a POST request', () async {
      // Arrange
      when(
        () => mockApi.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => {'uuid': '1', 'name': 'Test'});

      // Act
      await dataSource.upsertStudent(tStudentModel);

      // Assert
      verify(
        () => mockApi.post(
          EndPoint.userProfile.replaceFirst('{id}', tStudentModel.id),
          data: tStudentModel,
        ),
      );
    });
  });
}
