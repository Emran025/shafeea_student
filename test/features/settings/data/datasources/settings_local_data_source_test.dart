// test/features/settings/data/datasources/settings_local_data_source_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/features/settings/data/datasources/settings_local_data_source_impl.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SettingsLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late MockAppDatabase mockAppDatabase;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockAppDatabase = MockAppDatabase();
    dataSource = SettingsLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
      appDatabase: mockAppDatabase,
    );
  });

  group('getSettings', () {
    test('should return SettingsModel from SharedPreferences', () async {
      // Arrange
      when(
        () => mockSharedPreferences.getString(any()),
      ).thenReturn(AppThemeType.dark.name);
      when(
        () => mockSharedPreferences.getBool('NOTIFICATIONS_ENABLED'),
      ).thenReturn(true);
      when(
        () => mockSharedPreferences.getBool('ANALYTICS_ENABLED'),
      ).thenReturn(false);

      // Act
      final result = await dataSource.getSettings();

      // Assert
      expect(result.themeType, equals(AppThemeType.dark));
      expect(result.notificationsEnabled, isTrue);
      expect(result.analyticsEnabled, isFalse);
    });

    test(
      'should return default settings when SharedPreferences is empty',
      () async {
        // Arrange
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);
        when(() => mockSharedPreferences.getBool(any())).thenReturn(null);

        // Act
        final result = await dataSource.getSettings();

        // Assert
        expect(result.themeType, equals(AppThemeType.light));
        expect(result.notificationsEnabled, isTrue);
        expect(result.analyticsEnabled, isFalse);
      },
    );

    test('should throw CacheException when an error occurs', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any())).thenThrow(Exception());

      // Act
      final call = dataSource.getSettings;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('saveTheme', () {
    test('should call SharedPreferences to save theme name', () async {
      // Arrange
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      await dataSource.saveTheme(AppThemeType.dark);

      // Assert
      verify(
        () => mockSharedPreferences.setString(
          'APP_THEME',
          AppThemeType.dark.name,
        ),
      ).called(1);
    });
  });
}
