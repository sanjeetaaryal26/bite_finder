import 'package:birdle/data/models/feedback_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackModel', () {
    test('fromJson maps complaint type correctly', () {
      final model = FeedbackModel.fromJson({
        'id': 'fb1',
        'userId': 'u1',
        'restaurantId': 'r1',
        'type': 'complaint',
        'message': 'Service was very slow',
        'createdAt': '2026-03-07T10:00:00.000Z',
      });

      expect(model.type, FeedbackType.complaint);
      expect(model.restaurantId, 'r1');
    });

    test('fromJson defaults unknown type to feedback', () {
      final model = FeedbackModel.fromJson({
        'id': 'fb2',
        'userId': 'u1',
        'restaurantId': null,
        'type': 'unknown',
        'message': 'Great app',
        'createdAt': '2026-03-07T10:00:00.000Z',
      });

      expect(model.type, FeedbackType.feedback);
      expect(model.restaurantId, isNull);
    });

    test('toJson preserves nullable restaurantId and type name', () {
      const model = FeedbackModel(
        id: 'fb3',
        userId: 'u2',
        restaurantId: null,
        type: FeedbackType.feedback,
        message: 'Nice recommendations',
        createdAt: '2026-03-07T11:00:00.000Z',
      );

      final json = model.toJson();
      expect(json['type'], 'feedback');
      expect(json['restaurantId'], isNull);
      expect(json['message'], 'Nice recommendations');
    });
  });
}
