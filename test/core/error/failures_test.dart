// test/core/error/failures_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/core/error/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure should support value equality', () {
      expect(
        const ServerFailure(message: 'Error'),
        const ServerFailure(message: 'Error'),
      );
    });

    test('DataFailure should support value equality', () {
      expect(
        const DataFailure(message: 'Error'),
        const DataFailure(message: 'Error'),
      );
    });

    test('NetworkFailure should support value equality', () {
      expect(
        const NetworkFailure(message: 'Error'),
        const NetworkFailure(message: 'Error'),
      );
    });

    test('CacheFailure should support value equality', () {
      expect(
        const CacheFailure(message: 'Error'),
        const CacheFailure(message: 'Error'),
      );
    });

    test('UnknownFailure should support value equality', () {
      expect(
        const UnknownFailure(message: 'Error'),
        const UnknownFailure(message: 'Error'),
      );
    });

    test('toString should return correct format', () {
      expect(
        const ServerFailure(message: 'Error').toString(),
        'ServerFailure: Error (Code: null)',
      );
    });
  });
}
