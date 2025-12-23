// test/core/network/network_info_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/network/network_info_impl.dart';

import '../../helpers/test_helper.dart';

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    networkInfo = NetworkInfoImpl(connectionChecker: mockInternetConnection);
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnection.hasInternetAccess',
      () async {
        // arrange
        final tHasInternetAccessFuture = Future.value(true);
        when(
          () => mockInternetConnection.hasInternetAccess,
        ).thenAnswer((_) => tHasInternetAccessFuture);

        // act
        final result = networkInfo.isConnected;

        // assert
        verify(() => mockInternetConnection.hasInternetAccess);
        expect(result, tHasInternetAccessFuture);
      },
    );
  });
}
