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
      deviceId: "AE3A.240806.043",
      deviceModel: "sdk_gphone64_x86_64",
      manufacturer: "Google",
      osVersion: "Android 15 (SDK 35)",
      appVersion: "1.0.0+1",
      timezone: "Asia/Riyadh",
      locale: "en_US",
      pushNotificationToken: "dummy_push_token_for_development_env",
    );

    final tDeviceInfoModel = DeviceInfoModel.fromEntity(tDeviceInfoEntity);

    final tLoginRequestModel = LogInRequestModel(
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

      test('should preserve all credential fields', () {
        // Arrange
        const credentials = LogInCredentialsEntity(
          logIn: 'another@example.com',
          password: 'AnotherPassword456!',
        );

        // Act
        final result = LogInRequestModel.fromEntities(
          credentials: credentials,
          deviceInfo: tDeviceInfoEntity,
        );

        // Assert
        expect(result.logIn, 'another@example.com');
        expect(result.password, 'AnotherPassword456!');
      });

      test('should preserve all device info fields', () {
        // Arrange
        const deviceInfo = tDeviceInfoEntity;

        // Act
        final result = LogInRequestModel.fromEntities(
          credentials: tCredentials,
          deviceInfo: deviceInfo,
        );

        // Assert
        expect(result.deviceInfo.deviceModel, tDeviceInfoEntity.deviceModel);
        expect(result.deviceInfo.deviceId, tDeviceInfoEntity.deviceId);
        expect(result.deviceInfo.osVersion, tDeviceInfoEntity.osVersion);
        expect(result.deviceInfo.appVersion, tDeviceInfoEntity.appVersion);
        expect(result.deviceInfo.manufacturer, tDeviceInfoEntity.manufacturer);
        expect(result.deviceInfo.timezone, tDeviceInfoEntity.timezone);
        expect(result.deviceInfo.locale, tDeviceInfoEntity.locale);
        expect(
          result.deviceInfo.pushNotificationToken,
          tDeviceInfoEntity.pushNotificationToken,
        );
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

      test('should nest device info under device_info key', () {
        // Act
        final result = tLoginRequestModel.toJson();

        // Assert
        final deviceInfoJson = result['device_info'] as Map<String, dynamic>;
        expect(deviceInfoJson['device_id'], tDeviceInfoEntity.deviceId);
        expect(deviceInfoJson['model'], tDeviceInfoEntity.deviceModel);
        expect(deviceInfoJson['manufacturer'], tDeviceInfoEntity.manufacturer);
        expect(deviceInfoJson['os_version'], tDeviceInfoEntity.osVersion);
        expect(deviceInfoJson['app_version'], tDeviceInfoEntity.appVersion);
        expect(deviceInfoJson['timezone'], tDeviceInfoEntity.timezone);
        expect(deviceInfoJson['locale'], tDeviceInfoEntity.locale);
        expect(
          deviceInfoJson['fcm_token'],
          tDeviceInfoEntity.pushNotificationToken,
        );
      });

      test('should include all required fields in JSON', () {
        // Act
        final result = tLoginRequestModel.toJson();

        // Assert
        expect(result.containsKey('login'), true);
        expect(result.containsKey('password'), true);
        expect(result.containsKey('device_info'), true);
      });

      test('should handle special characters in credentials', () {
        // Arrange
        final specialModel = LogInRequestModel(
          logIn: 'user+tag@example.com',
          password: 'P@ssw0rd!#\$%',
          deviceInfo: tDeviceInfoModel,
        );

        // Act
        final result = specialModel.toJson();

        // Assert
        expect(result['login'], 'user+tag@example.com');
        expect(result['password'], 'P@ssw0rd!#\$%');
      });
    });

    group('Complete flow', () {
      test('should create valid JSON payload from entities', () {
        // Act
        final model = LogInRequestModel.fromEntities(
          credentials: tCredentials,
          deviceInfo: tDeviceInfoEntity,
        );
        final json = model.toJson();

        // Assert - Verify complete structure
        expect(json['login'], tCredentials.logIn);
        expect(json['password'], tCredentials.password);

        final deviceInfo = json['device_info'] as Map<String, dynamic>;
        expect(deviceInfo['device_id'], tDeviceInfoEntity.deviceId);
        expect(deviceInfo['model'], tDeviceInfoEntity.deviceModel);
        expect(deviceInfo['manufacturer'], tDeviceInfoEntity.manufacturer);
        expect(deviceInfo['os_version'], tDeviceInfoEntity.osVersion);
        expect(deviceInfo['app_version'], tDeviceInfoEntity.appVersion);
        expect(deviceInfo['timezone'], tDeviceInfoEntity.timezone);
        expect(deviceInfo['locale'], tDeviceInfoEntity.locale);
        expect(
          deviceInfo['fcm_token'],
          tDeviceInfoEntity.pushNotificationToken,
        );
      });
    });
  });
}
