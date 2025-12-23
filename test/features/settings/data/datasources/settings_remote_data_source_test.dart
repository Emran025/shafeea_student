// test/features/settings/data/datasources/settings_remote_data_source_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/api/end_ponits.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/settings/data/datasources/settings_remote_data_source_impl.dart';
import 'package:shafeea/features/settings/data/models/faq_model.dart';
import 'package:shafeea/features/settings/data/models/user_profile_model.dart';
import 'package:shafeea/features/settings/domain/entities/user_profile_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SettingsRemoteDataSourceImpl dataSource;
  late MockApiConsumer mockApiConsumer;

  setUp(() {
    mockApiConsumer = MockApiConsumer();
    dataSource = SettingsRemoteDataSourceImpl(api: mockApiConsumer);
  });

  group('getFaqs', () {
    const tPage = 1;
    final tFaqResponseJson = {
      'success': true,
      'message': 'success',
      'data': [
        {
          'id': 1,
          'question': 'Q1',
          'answer': 'A1',
          'view_count': 10,
          'is_active': 1,
          'display_order': 1,
        },
      ],
    };

    test('should perform a GET request on faqs endpoint', () async {
      // Arrange
      when(
        () => mockApiConsumer.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => tFaqResponseJson);

      // Act
      await dataSource.getFaqs(tPage);

      // Assert
      verify(
        () => mockApiConsumer.get(
          EndPoint.faqs,
          queryParameters: {'page': tPage},
        ),
      ).called(1);
    });

    test(
      'should return FaqResponseModel when the response code is 200',
      () async {
        // Arrange
        when(
          () => mockApiConsumer.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tFaqResponseJson);

        // Act
        final result = await dataSource.getFaqs(tPage);

        // Assert
        expect(result, equals(FaqResponseModel.fromJson(tFaqResponseJson)));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // Arrange
        when(
          () => mockApiConsumer.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(ServerException(message: 'error'));

        // Act
        final call = dataSource.getFaqs;

        // Assert
        expect(() => call(tPage), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getUserProfile', () {
    final tSessionsResponseJson = {
      'success': true,
      'data': [
        {
          'id': 'session-1',
          'device_name': 'Pixel 6',
          'ip_address': '127.0.0.1',
          'last_active': '2024-01-01',
          'is_current': true,
        },
      ],
    };

    final tUserResponseJson = {
      'success': true,
      'data': {
        'user': {
          'id': 1,
          'name': 'Test user',
          'email': 'test@email.com',
          'phone': '123',
        },
      },
    };

    test(
      'should perform GET requests on sessions and accountProfile endpoints',
      () async {
        // Arrange
        when(
          () => mockApiConsumer.get(EndPoint.sessions),
        ).thenAnswer((_) async => tSessionsResponseJson);
        when(
          () => mockApiConsumer.get(EndPoint.accountProfile),
        ).thenAnswer((_) async => tUserResponseJson);

        // Act
        await dataSource.getUserProfile();

        // Assert
        verify(() => mockApiConsumer.get(EndPoint.sessions)).called(1);
        verify(() => mockApiConsumer.get(EndPoint.accountProfile)).called(1);
      },
    );

    test('should return UserProfileModel on success', () async {
      // Arrange
      when(
        () => mockApiConsumer.get(EndPoint.sessions),
      ).thenAnswer((_) async => tSessionsResponseJson);
      when(
        () => mockApiConsumer.get(EndPoint.accountProfile),
      ).thenAnswer((_) async => tUserResponseJson);

      // Act
      final result = await dataSource.getUserProfile();

      // Assert
      expect(result, isA<UserProfileModel>());
      expect(result.user.name, equals('Test user'));
      expect(result.activeSessions.length, equals(1));
    });
  });

  group('updateUserProfile', () {
    const tUserProfile = UserProfileEntity(
      user: UserEntity(
        id: 1,
        name: 'name',
        email: 'email',
        phone: '123',
        avatar: 'avatar',
      ),
      activeSessions: [],
    );

    test('should perform a PATCH request on userProfile endpoint', () async {
      // Arrange
      when(
        () => mockApiConsumer.patch(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => {});

      // Act
      await dataSource.updateUserProfile(tUserProfile);

      // Assert
      verify(
        () => mockApiConsumer.patch(
          EndPoint.userProfile,
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });
}
