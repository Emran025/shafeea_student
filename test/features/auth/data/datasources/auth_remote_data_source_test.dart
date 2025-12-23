// test/features/auth/data/datasources/auth_remote_data_source_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/api/end_ponits.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:shafeea/features/auth/data/models/auth_response_model.dart';
import 'package:shafeea/features/auth/data/models/device_info_model.dart';
import 'package:shafeea/features/auth/data/models/login_request_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiConsumer mockApi;

  setUp(() {
    mockApi = MockApiConsumer();
    dataSource = AuthRemoteDataSourceImpl(mockApi);
  });

  group('logIn', () {
    const tLoginRequestModel = LogInRequestModel(
      logIn: 'test@example.com',
      password: 'Password123!',
      deviceInfo: DeviceInfoModel(
        deviceId: 'id',
        deviceModel: 'model',
        manufacturer: 'auth',
        osVersion: '1',
        appVersion: '1',
        timezone: 'UTC',
        locale: 'en',
        pushNotificationToken: 'token',
      ),
    );

    test(
      'should perform a POST request on a destination URL with login credentials',
      () async {
        // Arrange
        when(
          () => mockApi.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => tAuthResponseJson);

        // Act
        await dataSource.logIn(requestModel: tLoginRequestModel);

        // Assert
        verify(
          () => mockApi.post(EndPoint.logIn, data: tLoginRequestModel.toJson()),
        ).called(1);
      },
    );

    test(
      'should return AuthResponseModel when the response code is 2xx (success)',
      () async {
        // Arrange
        when(
          () => mockApi.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => tAuthResponseJson);

        // Act
        final result = await dataSource.logIn(requestModel: tLoginRequestModel);

        // Assert
        expect(result, isA<AuthResponseModel>());
        expect(result.accessToken, 'test_access_token_123456');
      },
    );

    test(
      'should throw a ServerException when the response is not 2xx',
      () async {
        // Arrange
        when(
          () => mockApi.post(any(), data: any(named: 'data')),
        ).thenThrow(ServerException(message: 'error', statusCode: '500'));

        // Act
        final call = dataSource.logIn;

        // Assert
        expect(
          () => call(requestModel: tLoginRequestModel),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
