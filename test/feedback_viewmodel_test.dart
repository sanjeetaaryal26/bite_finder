import 'package:birdle/data/models/feedback_model.dart';
import 'package:birdle/data/sources/mock_restaurant_data.dart';
import 'package:birdle/presentation/viewmodels/feedback_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_repositories.dart';

void main() {
  group('FeedbackViewModel', () {
    test('load fetches restaurants and user submissions', () async {
      final restaurantRepo = FakeRestaurantRepository()..restaurants = MockRestaurantData.restaurants.take(2).toList();
      final feedbackRepo = FakeFeedbackRepository()
        ..userFeedback = const [
          FeedbackModel(
            id: 'fb1',
            userId: 'u1',
            restaurantId: null,
            type: FeedbackType.feedback,
            message: 'Good app',
            createdAt: '2026-03-07T10:00:00.000Z',
          ),
        ];
      final vm = FeedbackViewModel(feedbackRepo, restaurantRepo);

      await vm.load('u1');

      expect(vm.isLoading, false);
      expect(vm.restaurants.length, 2);
      expect(vm.submissions.length, 1);
      expect(restaurantRepo.getRestaurantsCalls, 1);
      expect(feedbackRepo.getFeedbackByUserCalls, 1);
    });

    test('submit trims message, stores feedback, and refreshes submissions', () async {
      final restaurantRepo = FakeRestaurantRepository()..restaurants = MockRestaurantData.restaurants.take(1).toList();
      final feedbackRepo = FakeFeedbackRepository();
      final vm = FeedbackViewModel(feedbackRepo, restaurantRepo);

      final ok = await vm.submit(
        userId: 'u1',
        restaurantId: 'r1',
        type: FeedbackType.complaint,
        message: '   delayed order   ',
      );

      expect(ok, true);
      expect(feedbackRepo.addFeedbackCalls, 1);
      expect(feedbackRepo.lastAddedFeedback, isNotNull);
      expect(feedbackRepo.lastAddedFeedback!.message, 'delayed order');
      expect(vm.submissions.length, 1);
      expect(vm.submissions.first.type, FeedbackType.complaint);
    });

    test('submit returns false when repository add fails', () async {
      final restaurantRepo = FakeRestaurantRepository();
      final feedbackRepo = FakeFeedbackRepository()..throwOnAddFeedback = true;
      final vm = FeedbackViewModel(feedbackRepo, restaurantRepo);

      final ok = await vm.submit(
        userId: 'u1',
        restaurantId: null,
        type: FeedbackType.feedback,
        message: 'Some feedback text',
      );

      expect(ok, false);
      expect(vm.isLoading, false);
      expect(vm.error, isNull);
    });
  });
}
