// test/features/daily_tracking/domain/usecases/get_surahs_list_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/usecases/usecase.dart';
import 'package:shafeea/features/daily_tracking/domain/entities/surah.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_surahs_list.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetSurahsList usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetSurahsList(repository: mockQuranRepository);
  });

  const tSurahs = [
    Surah(
      number: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatiha',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 7,
      firstPageStrtsAt: 1,
      revelationType: 'Meccan',
    ),
  ];

  test('should get surahs list from the repository', () async {
    // arrange
    when(
      () => mockQuranRepository.getSurahsList(),
    ).thenAnswer((_) async => const Right(tSurahs));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tSurahs));
    verify(() => mockQuranRepository.getSurahsList());
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
