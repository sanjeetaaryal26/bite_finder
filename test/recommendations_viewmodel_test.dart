import 'package:birdle/data/sources/mock_restaurant_data.dart';
import 'package:birdle/presentation/viewmodels/recommendations_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_repositories.dart';

void main() {
  group('RecommendationsViewModel', () {
    test('load populates recommendation list', () async {
      final repo = FakeRestaurantRepository()..recommendations = MockRestaurantData.restaurants.take(3).toList();
      final vm = RecommendationsViewModel(repo);

      await vm.load('user-1');

      expect(vm.isLoading, false);
      expect(vm.recommendations.length, 3);
      expect(repo.getRecommendationsCalls, 1);
    });

    test('refresh triggers repository call again', () async {
      final repo = FakeRestaurantRepository()..recommendations = MockRestaurantData.restaurants.take(1).toList();
      final vm = RecommendationsViewModel(repo);

      await vm.refresh('user-1');
      await vm.refresh('user-1');

      expect(repo.getRecommendationsCalls, 2);
    });

    test('load handles repository exception gracefully', () async {
      final repo = FakeRestaurantRepository()..throwOnGetRecommendations = true;
      final vm = RecommendationsViewModel(repo);

      await vm.load('user-1');

      expect(vm.isLoading, false);
      expect(vm.recommendations, isEmpty);
      expect(vm.error, isNull);
    });
  });
}
