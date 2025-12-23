// test/features/daily_tracking/data/repositories/quran_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/exceptions.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/daily_tracking/data/repositories/quran_repository_impl.dart';
import 'package:shafeea/features/daily_tracking/data/models/ayah_model.dart';
import 'package:shafeea/features/daily_tracking/data/models/surah_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late QuranRepositoryImpl repository;
  late MockQuranLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockQuranLocalDataSource();
    repository = QuranRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const tAyahModel = AyahModel(
    number: 1,
    text: 'Test Ayah',
    textEmlaey: 'Test Ayah',
    numberInSurah: 1,
    page: 1,
    surahNumber: 1,
    juz: 1,
  );

  const tSurahModel = SurahModel(
    number: 1,
    name: 'Al-Baqarah',
    englishName: 'Al-Baqarah',
    englishNameTranslation: 'The Cow',
    numberOfAyahs: 286,
    firstPageStrtsAt: 2,
    revelationType: 'Medinan',
  );

  final tAyah = tAyahModel.toEntity();
  final tSurah = tSurahModel.toEntity();

  group('getPageDataya', () {
    test(
      'should return list of ayahs when call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getPageAyahs(any()),
        ).thenAnswer((_) async => [tAyahModel]);

        // act
        final result = await repository.getPageData(1);

        // assert
        verify(() => mockLocalDataSource.getPageAyahs(1));
        expect(result, Right([tAyah]));
      },
    );

    test(
      'should return CacheFailure when call to local data source throws CacheException',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getPageAyahs(any()),
        ).thenThrow(CacheException(message: 'Cache Error'));

        // act
        final result = await repository.getPageData(1);

        // assert
        expect(result, const Left(CacheFailure(message: 'Cache Error')));
      },
    );
  });

  group('getSurahsList', () {
    test(
      'should return list of surahs when call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getSurahsList(),
        ).thenAnswer((_) async => [tSurahModel]);

        // act
        final result = await repository.getSurahsList();

        // assert
        verify(() => mockLocalDataSource.getSurahsList());
        expect(result, Right([tSurah]));
      },
    );
  });

  group('getMistakesAyahsList', () {
    test(
      'should return list of ayahs when call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getMistakesAyahs(any()),
        ).thenAnswer((_) async => [tAyahModel]);

        // act
        final result = await repository.getMistakesAyahsList([1]);

        // assert
        verify(() => mockLocalDataSource.getMistakesAyahs([1]));
        expect(result, Right([tAyah]));
      },
    );
  });
}
