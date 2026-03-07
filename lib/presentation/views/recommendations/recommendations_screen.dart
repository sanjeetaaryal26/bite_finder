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
  static const _recommendedRestaurantImages = [
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
                          final recommendedImage = _recommendedRestaurantImages[index % _recommendedRestaurantImages.length];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              imageOverride: recommendedImage,
                              onTap: () => context.push('/restaurant/${restaurant.id}'),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
