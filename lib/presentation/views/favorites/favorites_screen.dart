import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/state_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().load(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoritesViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: vm.isLoading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: () => vm.load(userId))
              : vm.favorites.isEmpty
                  ? const EmptyState(message: 'No favorite restaurants yet.')
                  : RefreshIndicator(
                      onRefresh: () => vm.refresh(userId),
                      child: ListView.builder(
                        itemCount: vm.favorites.length,
                        itemBuilder: (context, index) {
                          final restaurant = vm.favorites[index];
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
