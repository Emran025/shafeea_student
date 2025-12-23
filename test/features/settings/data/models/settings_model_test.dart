// test/features/settings/data/models/settings_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/settings/data/models/settings_model.dart';
import 'package:shafeea/features/settings/domain/entities/settings_entity.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

void main() {
  const tSettingsModel = SettingsModel(
    themeType: AppThemeType.dark,
    notificationsEnabled: true,
    analyticsEnabled: false,
  );

  const tSettingsJson = {
    'themeType': 1, // index for dark
    'notificationsEnabled': true,
    'analyticsEnabled': false,
  };

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Act
      final result = SettingsModel.fromJson(tSettingsJson);

      // Assert
      expect(result, equals(tSettingsModel));
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSettingsModel.toJson();

      // Assert
      expect(result, equals(tSettingsJson));
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // Act
      final result = tSettingsModel.toEntity();

      // Assert
      expect(result, isA<SettingsEntity>());
      expect(result.themeType, equals(AppThemeType.dark));
    });
  });

  group('fromEntity', () {
    test('should create model from entity', () {
      // Arrange
      const tEntity = SettingsEntity(
        themeType: AppThemeType.light,
        notificationsEnabled: false,
        analyticsEnabled: true,
      );

      // Act
      final result = SettingsModel.fromEntity(tEntity);

      // Assert
      expect(result.themeType, equals(AppThemeType.light));
      expect(result.notificationsEnabled, isFalse);
    });
  });
}
