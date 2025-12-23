// test/features/daily_tracking/domain/usecases/get_mistakes_ayahs_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/features/daily_tracking/domain/entities/ayah.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_mistakes_ayahs.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetMistakesAyahs usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetMistakesAyahs(repository: mockQuranRepository);
  });

  const tAyahs = [
    Ayah(
      number: 1,
      text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      textEmlaey: 'بسم الله الرحمن الرحيم',
      numberInSurah: 1,
      page: 1,
      surahNumber: 1,
      juz: 1,
      sajda: false,
    ),
  ];

  test('should get mistakes ayahs list from the repository', () async {
    // arrange
    when(
      () => mockQuranRepository.getMistakesAyahsList(any()),
    ).thenAnswer((_) async => const Right(tAyahs));

    // act
    final result = await usecase(
      const GetMistakesAyahsParams(ayahsNumbers: [1]),
    );

    // assert
    expect(result, const Right(tAyahs));
    verify(() => mockQuranRepository.getMistakesAyahsList([1]));
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
