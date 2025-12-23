// test/features/auth/data/datasources/auth_local_data_source_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:shafeea/features/auth/data/models/user_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockPrefs;
  late MockFlutterSecureStorage mockSecure;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockSecure = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(
      sharedPreferences: mockPrefs,
      secureStorage: mockSecure,
    );
  });

  group('getUser', () {
    const tUserId = '1';
    final tUserModel = UserModel.fromMap(tUserJson);

    test(
      'should return UserModel from SharedPreferences when there is one in the cache',
      () async {
        // Arrange
        when(() => mockPrefs.getString('CURRENT_USER_ID')).thenReturn(tUserId);
        when(
          () => mockPrefs.getString('CACHED_USERS_LIST'),
        ).thenReturn(json.encode([tUserJson]));

        // Act
        final result = await dataSource.getUser();

        // Assert
        verify(() => mockPrefs.getString('CURRENT_USER_ID'));
        verify(() => mockPrefs.getString('CACHED_USERS_LIST'));
        expect(result, equals(tUserModel));
      },
    );

    test('should return null when there is no cached value', () async {
      // Arrange
      when(() => mockPrefs.getString(any())).thenReturn(null);

      // Act
      final result = await dataSource.getUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('cacheUser', () {
    final tUserModel = UserModel.fromMap(tUserJson);

    test('should call SharedPreferences to cache the data', () async {
      // Arrange
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      await dataSource.cacheUser(tUserModel);

      // Assert
      verify(() => mockPrefs.setString('CACHED_USERS_LIST', any()));
      verify(
        () => mockPrefs.setString('CURRENT_USER_ID', tUserModel.id.toString()),
      );
    });

    test(
      'should throw a CacheException when there is an error caching data',
      () async {
        // Arrange
        when(() => mockPrefs.setString(any(), any())).thenThrow(Exception());

        // Act
        final call = dataSource.cacheUser;

        // Assert
        expect(() => call(tUserModel), throwsA(isA<CacheException>()));
      },
    );
  });

  group('getAccessToken', () {
    test('should return access token from Secure Storage', () async {
      // Arrange
      final tTokenList = [
        {'uid': '1', 'token': 'abc'},
      ];
      when(
        () => mockSecure.read(key: 'ACCESS_TOKENS_LIST'),
      ).thenAnswer((_) async => json.encode(tTokenList));

      // Act
      final result = await dataSource.getAccessToken();

      // Assert
      expect(result, 'abc');
    });
  });
}
