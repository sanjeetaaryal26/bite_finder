import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/recommendations_viewmodel.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/state_widgets.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsViewModel>().load(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecommendationsViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Recommended for You')),
      body: vm.isLoading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: () => vm.load(userId))
              : vm.recommendations.isEmpty
                  ? const EmptyState(message: 'No recommendations available yet.')
                  : RefreshIndicator(
                      onRefresh: () => vm.refresh(userId),
                      child: ListView.builder(
                        itemCount: vm.recommendations.length,
                        itemBuilder: (context, index) {
                          final restaurant = vm.recommendations[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              onTap: () => context.push('/restaurant/${restaurant.id}'),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
