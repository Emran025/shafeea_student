// test/features/settings/domain/usecases/save_theme_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/settings/domain/usecases/save_theme.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SaveTheme useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = SaveTheme(mockRepository);
  });

  const tThemeType = AppThemeType.dark;

  test('should save theme via repository', () async {
    // Arrange
    when(
      () => mockRepository.saveTheme(any()),
    ).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase(const SaveThemeParams(themeType: tThemeType));

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.saveTheme(tThemeType)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when saving theme fails', () async {
    // Arrange
    when(
      () => mockRepository.saveTheme(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));

    // Act
    final result = await useCase(const SaveThemeParams(themeType: tThemeType));

    // Assert
    expect(result, const Left(ServerFailure(message: 'error')));
    verify(() => mockRepository.saveTheme(tThemeType)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
