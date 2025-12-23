// test/features/auth/data/models/login_request_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/auth/data/models/device_info_model.dart';
import 'package:shafeea/features/auth/data/models/login_request_model.dart';
import 'package:shafeea/features/auth/domain/entities/device_info_entity.dart';
import 'package:shafeea/features/auth/domain/entities/login_credentials_entity.dart';

void main() {
  group('LogInRequestModel', () {
    const tCredentials = LogInCredentialsEntity(
      logIn: 'test@example.com',
      password: 'Password123!',
    );

    const tDeviceInfoEntity = DeviceInfoEntity(
      deviceId: 'test-device-id-12345',
      deviceModel: 'Pixel 6',
      manufacturer: 'Google',
      osVersion: '13',
      appVersion: '1.0.0',
      timezone: 'UTC',
      locale: 'en_US',
      pushNotificationToken: 'fcm_token_123',
    );

    const tDeviceInfoModel = DeviceInfoModel(
      deviceId: 'test-device-id-12345',
      deviceModel: 'Pixel 6',
      manufacturer: 'Google',
      osVersion: '13',
      appVersion: '1.0.0',
      timezone: 'UTC',
      locale: 'en_US',
      pushNotificationToken: 'fcm_token_123',
    );

    const tLoginRequestModel = LogInRequestModel(
      logIn: 'test@example.com',
      password: 'Password123!',
      deviceInfo: tDeviceInfoModel,
    );

    group('fromEntities', () {
      test('should combine credentials and device info correctly', () {
        // Act
        final result = LogInRequestModel.fromEntities(
          credentials: tCredentials,
          deviceInfo: tDeviceInfoEntity,
        );

        // Assert
        expect(result.logIn, tCredentials.logIn);
        expect(result.password, tCredentials.password);
        expect(result.deviceInfo.deviceModel, tDeviceInfoEntity.deviceModel);
        expect(result.deviceInfo.deviceId, tDeviceInfoEntity.deviceId);
      });

      test('should convert DeviceInfoEntity to DeviceInfoModel', () {
        // Act
        final result = LogInRequestModel.fromEntities(
          credentials: tCredentials,
          deviceInfo: tDeviceInfoEntity,
        );

        // Assert
        expect(result.deviceInfo, isA<DeviceInfoModel>());
      });
    });

    group('toJson', () {
      test('should produce correct request payload structure', () {
        // Act
        final result = tLoginRequestModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['login'], 'test@example.com');
        expect(result['password'], 'Password123!');
        expect(result['device_info'], isA<Map<String, dynamic>>());
      });

      test(
        'should nest device info under device_info key with correct API names',
        () {
          // Act
          final result = tLoginRequestModel.toJson();

          // Assert
          final deviceInfoJson = result['device_info'] as Map<String, dynamic>;
          expect(deviceInfoJson['device_id'], 'test-device-id-12345');
          expect(deviceInfoJson['model'], 'Pixel 6');
          expect(deviceInfoJson['manufacturer'], 'Google');
          expect(deviceInfoJson['os_version'], '13');
          expect(deviceInfoJson['app_version'], '1.0.0');
          expect(deviceInfoJson['timezone'], 'UTC');
          expect(deviceInfoJson['locale'], 'en_US');
          expect(deviceInfoJson['fcm_token'], 'fcm_token_123');
        },
      );
    });
  });
}
