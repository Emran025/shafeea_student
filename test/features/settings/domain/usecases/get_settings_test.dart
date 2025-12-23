// test/features/settings/domain/usecases/get_settings_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/core/usecases/usecase.dart';
import 'package:shafeea/features/settings/domain/entities/settings_entity.dart';
import 'package:shafeea/features/settings/domain/usecases/get_settings.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetSettings(mockRepository);
  });

  const tSettings = SettingsEntity(
    themeType: AppThemeType.light,
    notificationsEnabled: true,
    analyticsEnabled: false,
  );

  test('should get settings from the repository', () async {
    // Arrange
    when(
      () => mockRepository.getSettings(),
    ).thenAnswer((_) async => const Right(tSettings));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, const Right(tSettings));
    verify(() => mockRepository.getSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    when(
      () => mockRepository.getSettings(),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, const Left(ServerFailure(message: 'error')));
    verify(() => mockRepository.getSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
