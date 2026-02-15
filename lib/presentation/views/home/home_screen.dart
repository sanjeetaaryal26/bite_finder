import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/state_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().load(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Restaurants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, cuisine, specialty, bestseller',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          vm.updateQuery('', userId);
                          setState(() {});
                        },
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) => vm.updateQuery(v.trim(), userId),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CuisineChip(
                  label: 'All',
                  selected: vm.selectedCuisine == 'All',
                  onTap: () => vm.updateCuisine('All', userId),
                ),
                ...AppConstants.cuisines.map(
                  (c) => _CuisineChip(
                    label: c,
                    selected: vm.selectedCuisine == c,
                    onTap: () => vm.updateCuisine(c, userId),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: vm.sortBy,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: AppConstants.sortOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        vm.updateSort(value, userId);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Checkbox(
                      value: vm.highRatingOnly,
                      onChanged: (_) => vm.toggleHighRating(userId),
                    ),
                    const Text('>= 4.0'),
                  ],
                ),
                IconButton(
                  tooltip: 'Reset filters',
                  onPressed: () {
                    _searchController.clear();
                    vm.resetFilters(userId);
                    setState(() {});
                  },
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: vm.isLoading
                  ? const LoadingState()
                  : vm.error != null
                      ? ErrorState(message: vm.error!, onRetry: () => vm.load(userId))
                      : vm.restaurants.isEmpty
                          ? const EmptyState(message: 'No restaurants found for current filters.')
                          : ListView.builder(
                              key: ValueKey('${vm.query}_${vm.selectedCuisine}_${vm.sortBy}_${vm.highRatingOnly}'),
                              itemCount: vm.restaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = vm.restaurants[index];
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
          ),
        ],
      ),
    );
  }
}

class _CuisineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CuisineChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
