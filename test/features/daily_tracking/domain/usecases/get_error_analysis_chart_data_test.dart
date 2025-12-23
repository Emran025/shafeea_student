// test/features/daily_tracking/domain/usecases/get_error_analysis_chart_data_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/models/chart_data_point.dart';
import 'package:shafeea/core/models/bar_chart_datas.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_error_analysis_chart_data.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetErrorAnalysisChartData usecase;
  late MockTrackingRepository mockTrackingRepository;

  setUp(() {
    mockTrackingRepository = MockTrackingRepository();
    usecase = GetErrorAnalysisChartData(mockTrackingRepository);
  });

  const tFilter = ChartFilter(timePeriod: 'month');
  final tChartData = [
    const BarChartDatas(
      data: [ChartDataPoint(value: 5, label: 'Jan')],
      xAxisLabel: 'Months',
      yAxisLabel: 'Errors',
    ),
  ];

  test('should get error analysis chart data from the repository', () async {
    // arrange
    when(
      () => mockTrackingRepository.getErrorAnalysisChartData(
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => Right(tChartData));

    // act
    final result = await usecase(
      const GetErrorAnalysisChartDataParams(filter: tFilter),
    );

    // assert
    expect(result, Right(tChartData));
    verify(
      () => mockTrackingRepository.getErrorAnalysisChartData(filter: tFilter),
    );
    verifyNoMoreInteractions(mockTrackingRepository);
  });
}
