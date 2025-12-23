// test/features/auth/data/models/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:shafeea/features/auth/data/models/user_model.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    phone: '+1234567890',
    avatar: 'https://example.com/avatar.png',
  );

  group('UserModel', () {
    test('should be a subclass of UserEntity', () {
      // Assert
      expect(tUserModel, isA<UserEntity>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is complete', () {
        // Arrange - Use test fixture from helper
        final Map<String, dynamic> jsonMap = tUserJson;

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result, tUserModel);
      });

      test('should handle null avatar field correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '+1234567890',
          'avatar': null,
        };

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result.avatar, null);
        expect(result.id, 1);
        expect(result.name, 'Test User');
      });

      test('should parse integers and strings correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tUserJson;

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result.id, isA<int>());
        expect(result.name, isA<String>());
        expect(result.email, isA<String>());
        expect(result.phone, isA<String>());
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tUserModel.toJson();

        // Assert
        final expectedJsonMap = {
          'id': 1,
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '+1234567890',
          'avatar': 'https://example.com/avatar.png',
        };
        expect(result, expectedJsonMap);
      });

      test('should include null values in JSON', () {
        // Arrange
        const modelWithNullAvatar = UserModel(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          phone: '+1234567890',
          avatar: null,
        );

        // Act
        final result = modelWithNullAvatar.toJson();

        // Assert
        expect(result['avatar'], null);
        expect(result.containsKey('avatar'), true);
      });
    });

    group('fromMap', () {
      test('should return a valid model when Map is complete', () {
        // Arrange
        final Map<String, dynamic> map = tUserJson;

        // Act
        final result = UserModel.fromMap(map);

        // Assert
        expect(result, tUserModel);
      });
    });

    group('toMap', () {
      test('should return a Map containing proper data', () {
        // Act
        final result = tUserModel.toMap();

        // Assert
        expect(result, tUserJson);
      });
    });

    group('toUserEntity', () {
      test('should convert UserModel to UserEntity correctly', () {
        // Act
        final result = tUserModel.toUserEntity();

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, tUserModel.id);
        expect(result.name, tUserModel.name);
        expect(result.email, tUserModel.email);
        expect(result.phone, tUserModel.phone);
        expect(result.avatar, tUserModel.avatar);
      });

      test('should preserve all fields when converting to entity', () {
        // Arrange
        const modelWithNullAvatar = UserModel(
          id: 2,
          name: 'Another User',
          email: 'another@example.com',
          phone: '+9876543210',
          avatar: null,
        );

        // Act
        final result = modelWithNullAvatar.toUserEntity();

        // Assert
        expect(result.id, 2);
        expect(result.name, 'Another User');
        expect(result.avatar, null);
      });
    });

    group('JSON round-trip', () {
      test(
        'should maintain data integrity through fromJson -> toJson cycle',
        () {
          // Arrange
          final originalJson = tUserJson;

          // Act
          final model = UserModel.fromJson(originalJson);
          final resultJson = model.toJson();

          // Assert
          expect(resultJson, originalJson);
        },
      );

      test(
        'should maintain data integrity through toJson -> fromJson cycle',
        () {
          // Act
          final json = tUserModel.toJson();
          final model = UserModel.fromJson(json);

          // Assert
          expect(model, tUserModel);
        },
      );
    });
  });
}
