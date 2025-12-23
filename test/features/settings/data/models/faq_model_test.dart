// test/features/settings/data/models/faq_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/features/settings/data/models/faq_model.dart';

void main() {
  const tFaqModel = FaqModel(
    id: 1,
    question: 'Q1',
    answer: 'A1',
    viewCount: 10,
    isActive: 1,
    displayOrder: 1,
  );

  const tFaqJson = {
    'id': 1,
    'question': 'Q1',
    'answer': 'A1',
    'view_count': 10,
    'is_active': 1,
    'display_order': 1,
  };

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Act
      final result = FaqModel.fromJson(tFaqJson);

      // Assert
      expect(result, equals(tFaqModel));
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tFaqModel.toJson();

      // Assert
      expect(result, equals(tFaqJson));
    });
  });

  group('FaqResponseModel', () {
    const tFaqResponseModel = FaqResponseModel(
      success: true,
      message: 'success',
      data: [tFaqModel],
    );

    const tFaqResponseJson = {
      'success': true,
      'message': 'success',
      'data': [tFaqJson],
    };

    test('should parse FaqResponseModel from JSON', () {
      // Act
      final result = FaqResponseModel.fromJson(tFaqResponseJson);

      // Assert
      expect(result, equals(tFaqResponseModel));
    });
  });
}
