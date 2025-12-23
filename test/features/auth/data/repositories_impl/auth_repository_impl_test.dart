// test/features/auth/data/repositories_impl/auth_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/data/models/auth_response_model.dart';
import 'package:shafeea/features/auth/data/models/user_model.dart';
import 'package:shafeea/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:shafeea/features/auth/domain/entities/login_credentials_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockStudentLocalDataSource mockStudentLocalDataSource;
  late MockDeviceInfoService mockDeviceInfoService;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockStudentLocalDataSource = MockStudentLocalDataSource();
    mockDeviceInfoService = MockDeviceInfoService();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      studentLocalDataSource: mockStudentLocalDataSource,
      deviceInfoService: mockDeviceInfoService,
      networkInfo: mockNetworkInfo,
    );
  });

  group('logIn', () {
    const tCredentials = LogInCredentialsEntity(
      logIn: 'test@example.com',
      password: 'Password123!',
    );
    final tUserModel = UserModel.fromMap(tUserJson);
    final tAuthResponseModel = AuthResponseModel.fromJson(tAuthResponseJson);
    final tUserEntity = tUserModel.toUserEntity();

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockDeviceInfoService.getDeviceInfo(),
      ).thenAnswer((_) async => tDeviceInfoEntity);
      when(
        () => mockRemoteDataSource.logIn(
          requestModel: any(named: 'requestModel'),
        ),
      ).thenAnswer((_) async => tAuthResponseModel);
      when(
        () => mockLocalDataSource.cacheUser(any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockLocalDataSource.cacheAuthTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async => {});

      // Act
      await repository.logIn(credentials: tCredentials);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            () => mockDeviceInfoService.getDeviceInfo(),
          ).thenAnswer((_) async => tDeviceInfoEntity);
          when(
            () => mockRemoteDataSource.logIn(
              requestModel: any(named: 'requestModel'),
            ),
          ).thenAnswer((_) async => tAuthResponseModel);
          when(
            () => mockLocalDataSource.cacheUser(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockLocalDataSource.cacheAuthTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
            ),
          ).thenAnswer((_) async => {});

          // Act
          final result = await repository.logIn(credentials: tCredentials);

          // Assert
          verify(
            () => mockRemoteDataSource.logIn(
              requestModel: any(named: 'requestModel'),
            ),
          );
          expect(result, equals(Right(tUserEntity)));
        },
      );

      test(
        'should cache the user and tokens locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            () => mockDeviceInfoService.getDeviceInfo(),
          ).thenAnswer((_) async => tDeviceInfoEntity);
          when(
            () => mockRemoteDataSource.logIn(
              requestModel: any(named: 'requestModel'),
            ),
          ).thenAnswer((_) async => tAuthResponseModel);
          when(
            () => mockLocalDataSource.cacheUser(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockLocalDataSource.cacheAuthTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
            ),
          ).thenAnswer((_) async => {});

          // Act
          await repository.logIn(credentials: tCredentials);

          // Assert
          verify(() => mockLocalDataSource.cacheUser(tAuthResponseModel.user));
          verify(
            () => mockLocalDataSource.cacheAuthTokens(
              accessToken: tAuthResponseModel.accessToken,
              refreshToken: tAuthResponseModel.refreshToken,
            ),
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            () => mockDeviceInfoService.getDeviceInfo(),
          ).thenAnswer((_) async => tDeviceInfoEntity);
          when(
            () => mockRemoteDataSource.logIn(
              requestModel: any(named: 'requestModel'),
            ),
          ).thenThrow(
            ServerException(message: 'server error', statusCode: '500'),
          );

          // Act
          final result = await repository.logIn(credentials: tCredentials);

          // Assert
          expect(
            result,
            equals(
              const Left(
                ServerFailure(message: 'server error', statusCode: '500'),
              ),
            ),
          );
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return network failure when the device is offline',
        () async {
          // Act
          final result = await repository.logIn(credentials: tCredentials);

          // Assert
          expect(
            result,
            equals(
              const Left(NetworkFailure(message: 'No Internet Connection')),
            ),
          );
        },
      );
    });
  });
}
