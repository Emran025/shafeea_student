// test/features/settings/data/models/user_profile_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/auth/data/models/user_model.dart';
import 'package:shafeea/features/settings/data/models/user_profile_model.dart';
import 'package:shafeea/features/settings/data/models/user_session_model.dart';
import 'package:shafeea/features/settings/domain/entities/user_profile_entity.dart';

import 'package:shafeea/features/auth/data/models/device_info_model.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    name: 'Test user',
    email: 'test@email.com',
    phone: '123',
  );

  final tDeviceInfoModel = DeviceInfoModel(
    deviceId: 'id',
    deviceModel: 'Pixel 6',
    manufacturer: 'Google',
    osVersion: '12',
    appVersion: '1.0.0',
    timezone: 'UTC',
    locale: 'en',
    pushNotificationToken: 'token',
  );

  final tSessionModel = UserSessionModel(
    id: 'session-1',
    isCurrentDevice: true,
    lastAccessedAt: DateTime.parse('2024-01-01'),
    deviceInfo: tDeviceInfoModel,
  );

  final tUserProfileModel = UserProfileModel(
    user: tUserModel,
    activeSessions: [tSessionModel],
  );

  final tUserProfileJson = {
    'user': {
      'id': 1,
      'name': 'Test user',
      'email': 'test@email.com',
      'phone': '123',
    },
    'active_sessions': [
      {
        'id': 'session-1',
        'is_current_device': true,
        'last_accessed_at': '2024-01-01T00:00:00.000',
        'device_info': {
          'device_id': 'id',
          'device_model': 'Pixel 6',
          'manufacturer': 'Google',
          'os_version': '12',
          'app_version': '1.0.0',
          'timezone': 'UTC',
          'locale': 'en',
          'push_notification_token': 'token',
        },
      },
    ],
  };

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Act
      final result = UserProfileModel.fromJson(tUserProfileJson);

      // Assert
      expect(result.user, equals(tUserModel));
      expect(result.activeSessions, equals([tSessionModel]));
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // Act
      final result = tUserProfileModel.toEntity();

      // Assert
      expect(result, isA<UserProfileEntity>());
      expect(result.user.name, equals(tUserModel.name));
    });
  });

  group('toJson', () {
    test(
      'should return JSON containing only user data (security decision)',
      () {
        // Act
        final result = tUserProfileModel.toJson();

        // Assert
        expect(result, equals({'user': tUserModel.toJson()}));
      },
    );
  });
}
