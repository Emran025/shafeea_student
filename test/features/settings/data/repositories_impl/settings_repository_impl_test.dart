// test/features/settings/data/repositories_impl/settings_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/settings/data/models/faq_model.dart';
import 'package:shafeea/features/settings/data/models/settings_model.dart';
import 'package:shafeea/features/settings/data/repositories_impl/settings_repository_impl.dart';
import 'package:shafeea/features/settings/domain/entities/faq_entity.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockLocalDataSource;
  late MockSettingsRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockSettingsLocalDataSource();
    mockRemoteDataSource = MockSettingsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = SettingsRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getSettings', () {
    const tSettingsModel = SettingsModel(
      themeType: AppThemeType.light,
      notificationsEnabled: true,
      analyticsEnabled: false,
    );

    test(
      'should return local settings data when fetching is successful',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.getSettings(),
        ).thenAnswer((_) async => tSettingsModel);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result, equals(const Right(tSettingsModel)));
        verify(() => mockLocalDataSource.getSettings()).called(1);
      },
    );

    test(
      'should return CacheFailure when fetching local settings fails',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.getSettings(),
        ).thenThrow(CacheException(message: 'error'));

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result, equals(const Left(CacheFailure(message: 'error'))));
      },
    );
  });

  group('getFaqs', () {
    const tPage = 1;
    const tFaqModel = FaqModel(
      id: 1,
      question: 'Q1',
      answer: 'A1',
      viewCount: 10,
      isActive: 1,
      displayOrder: 1,
    );
    const tFaqResponseModel = FaqResponseModel(
      success: true,
      message: 'success',
      data: [tFaqModel],
    );
    final tFaqEntityList = [
      const FaqEntity(id: 1, question: 'Q1', answer: 'A1', viewCount: 10),
    ];

    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getFaqs(any()),
        ).thenAnswer((_) async => tFaqResponseModel);

        // Act
        final result = await repository.getFaqs(tPage);

        // Assert
        expect(result, equals(Right(tFaqEntityList)));
        verify(() => mockRemoteDataSource.getFaqs(tPage)).called(1);
      },
    );

    test(
      'should return ServerFailure when the call to remote data source is unsuccessful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getFaqs(any()),
        ).thenThrow(ServerException(message: 'error'));

        // Act
        final result = await repository.getFaqs(tPage);

        // Assert
        expect(
          result,
          equals(const Left(ServerFailure(message: 'Failed to fetch FAQs.'))),
        );
      },
    );
  });
}
