import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/state_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _featuredRestaurantImages = [
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/01_yala_layeku_kitchen.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/02_sanju_restaurant_pokhara.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/03_everest_steak_house.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/04_fujiyama_japanese_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/05_pokhara_takali_kitchen.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/06_yin_yang_restaurant_exterior.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/07_fewa_view_lodge_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/08_highway_restaurant_gunadi.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/09_bhojan_griha_dinner_42.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/10_bhojan_griha_dinner_26.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/11_pokhara_typical_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/12_lake_fewa_pokhara_restaurant_view.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/13_pokhara_street_food.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/14_momo_nepal.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/15_plateful_of_momo.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/16_nepali_momo.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/17_dal_bhat_tarkari_nepal.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/18_newari_food.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/19_traditional_newari_thali.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/20_nepali_dal_bhat_tarkari.jpg',
  ];

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
      context.read<ThemeViewModel>().applyCuisine(context.read<HomeViewModel>().selectedCuisine);
      context.read<HomeViewModel>().load(userId);
    });
  }

  Future<void> _onCuisineSelected(BuildContext context, String cuisine, String userId) async {
    context.read<ThemeViewModel>().applyCuisine(cuisine);
    await context.read<HomeViewModel>().updateCuisine(cuisine, userId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Restaurants')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
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
                          selectedColor: ThemeViewModel.colorForCuisine('All'),
                          onTap: () => _onCuisineSelected(context, 'All', userId),
                        ),
                        ...AppConstants.cuisines.map(
                          (c) => _CuisineChip(
                            label: c,
                            selected: vm.selectedCuisine == c,
                            selectedColor: ThemeViewModel.colorForCuisine(c),
                            onTap: () => _onCuisineSelected(context, c, userId),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: constraints.maxWidth < 700
                        ? Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth < 360 ? constraints.maxWidth : constraints.maxWidth - 32,
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
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  Checkbox(
                                    value: vm.highRatingOnly,
                                    onChanged: (_) => vm.toggleHighRating(userId),
                                  ),
                                  const Text('>= 4.0'),
                                  IconButton(
                                    tooltip: 'Reset filters',
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<ThemeViewModel>().reset();
                                      vm.resetFilters(userId);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.restart_alt),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
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
                                  context.read<ThemeViewModel>().reset();
                                  vm.resetFilters(userId);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.restart_alt),
                              ),
                            ],
                          ),
                  ),
                  if (vm.locationError != null && vm.sortBy == 'Nearest')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Nearest unavailable: ${vm.locationError}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
                      ),
                    ),
                  if (vm.isLoading && vm.restaurants.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  Expanded(
                    child: vm.isLoading && vm.restaurants.isEmpty
                        ? const LoadingState()
                        : vm.restaurants.isEmpty
                            ? const EmptyState(message: 'No restaurants found for current filters.')
                            : ListView.builder(
                                key: ValueKey('${vm.query}_${vm.selectedCuisine}_${vm.sortBy}_${vm.highRatingOnly}'),
                                itemCount: vm.restaurants.length,
                                itemBuilder: (context, index) {
                                  final restaurant = vm.restaurants[index];
                                  final useFeaturedImages = vm.query.trim().isEmpty;
                                  final featuredImage = useFeaturedImages
                                      ? _featuredRestaurantImages[index % _featuredRestaurantImages.length]
                                      : null;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    child: RestaurantCard(
                                      restaurant: restaurant,
                                      imageOverride: featuredImage,
                                      onTap: () => context.push('/restaurant/${restaurant.id}'),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CuisineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _CuisineChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selected: selected,
        selectedColor: selectedColor,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? selectedColor : Colors.black26,
        ),
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
