// test/features/auth/data/models/auth_response_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/auth/data/models/auth_response_model.dart';
import 'package:shafeea/features/auth/data/models/user_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    phone: '+1234567890',
    avatar: 'https://example.com/avatar.png',
  );

  const tAuthResponseModel = AuthResponseModel(
    accessToken: 'test_access_token_123456',
    refreshToken: 'test_refresh_token_abcdef',
    role: 1,
    user: tUserModel,
  );

  group('AuthResponseModel', () {
    group('fromJson', () {
      test('should return a valid model when JSON is complete', () {
        // Arrange - Use test fixture from helper
        final Map<String, dynamic> jsonMap = tAuthResponseJson;

        // Act
        final result = AuthResponseModel.fromJson(jsonMap);

        // Assert
        expect(result.accessToken, 'test_access_token_123456');
        expect(result.refreshToken, 'test_refresh_token_abcdef');
        expect(result.role, 1);
        expect(result.user.id, 1);
        expect(result.user.email, 'test@example.com');
      });

      test('should parse nested user object correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tAuthResponseJson;

        // Act
        final result = AuthResponseModel.fromJson(jsonMap);

        // Assert
        expect(result.user, isA<UserModel>());
        expect(result.user.name, 'Test User');
      });

      test('should handle all token fields correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'access_token': 'access_abc123',
          'refreshToken': 'refresh_xyz789',
          'role': 2,
          'user': tUserJson,
        };

        // Act
        final result = AuthResponseModel.fromMap(jsonMap);

        // Assert
        expect(result.accessToken, 'access_abc123');
        expect(result.refreshToken, 'refresh_xyz789');
        expect(result.role, 2);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tAuthResponseModel.toJson();

        // Assert
        expect(result['access_token'], 'test_access_token_123456');
        expect(result['refreshToken'], 'test_refresh_token_abcdef');
        expect(result['role'], 1);
        expect(result['user'], isA<Map<String, dynamic>>());
      });

      test('should serialize nested user object correctly', () {
        // Act
        final result = tAuthResponseModel.toJson();

        // Assert
        final userJson = result['user'] as Map<String, dynamic>;
        expect(userJson['id'], 1);
        expect(userJson['name'], 'Test User');
        expect(userJson['email'], 'test@example.com');
      });
    });

    group('JSON round-trip', () {
      test(
        'should maintain data integrity through fromJson -> toJson cycle',
        () {
          // Arrange
          final originalJson = tAuthResponseJson;

          // Act
          final model = AuthResponseModel.fromJson(originalJson);
          final resultJson = model.toJson();

          // Assert
          expect(resultJson, originalJson);
        },
      );

      test(
        'should maintain data integrity through toJson -> fromJson cycle',
        () {
          // Act
          final json = tAuthResponseModel.toJson();
          final model = AuthResponseModel.fromJson(json);

          // Assert
          expect(model.accessToken, tAuthResponseModel.accessToken);
          expect(model.refreshToken, tAuthResponseModel.refreshToken);
          expect(model.user.email, tAuthResponseModel.user.email);
        },
      );
    });

    group('Edge cases', () {
      test('should handle different role values', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'access_token': 'token_123',
          'refreshToken': 'refresh_456',
          'role': 3,
          'user': tUserJson,
        };

        // Act
        final result = AuthResponseModel.fromMap(jsonMap);

        // Assert
        expect(result.role, 3);
      });

      test('should handle long token strings', () {
        // Arrange
        final longToken = 'a' * 500; // Very long token
        final Map<String, dynamic> jsonMap = {
          'access_token': longToken,
          'refreshToken': 'refresh_token',
          'role': 1,
          'user': tUserJson,
        };

        // Act
        final result = AuthResponseModel.fromMap(jsonMap);

        // Assert
        expect(result.accessToken, longToken);
        expect(result.accessToken.length, 500);
      });
    });
  });
}
