import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/restaurant_detail_viewmodel.dart';
import '../../widgets/state_widgets.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _reviewFormKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 5;
  bool _loaded = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantDetailViewModel>().load(
            restaurantId: widget.restaurantId,
            userId: userId,
          );
    });
  }

  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus();
    if (!_reviewFormKey.currentState!.validate()) return;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    final vm = context.read<RestaurantDetailViewModel>();
    final ok = await vm.addReview(
      userId: userId,
      rating: _rating,
      comment: _reviewController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review added')));
    } else if (vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final userId = context.watch<AuthViewModel>().currentUser!.id;

    if (vm.isLoading && vm.restaurant == null) {
      return const Scaffold(body: LoadingState());
    }

    if (vm.error != null && vm.restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: vm.error!,
          onRetry: () => vm.load(restaurantId: widget.restaurantId, userId: userId),
        ),
      );
    }

    final restaurant = vm.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(message: 'Restaurant not found'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [
          IconButton(
            onPressed: () => vm.toggleFavorite(userId),
            icon: Icon(vm.isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: restaurant.photos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(restaurant.photos[index], fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(restaurant.description),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${restaurant.ratingAvg} (${restaurant.ratingCount} reviews)'),
                const SizedBox(width: 12),
                Text(restaurant.priceRange),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: restaurant.specialties.map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 8),
            Text('Services: ${restaurant.services.join(', ')}'),
            const SizedBox(height: 16),
            Text('Bestselling Items', style: Theme.of(context).textTheme.titleMedium),
            ...restaurant.bestSellers.map((item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(item),
                )),
            const Divider(height: 26),
            Text('Add Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Form(
              key: _reviewFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _rating,
                    decoration: const InputDecoration(labelText: 'Rating'),
                    items: [1, 2, 3, 4, 5]
                        .map((r) => DropdownMenuItem(value: r, child: Text('$r stars')))
                        .toList(),
                    onChanged: (v) => setState(() => _rating = v ?? 5),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Comment'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Comment is required';
                      if (v.trim().length < 5) return 'Comment is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: vm.isLoading ? null : _submitReview,
                    child: const Text('Submit Review'),
                  ),
                ],
              ),
            ),
            const Divider(height: 26),
            Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (vm.reviews.isEmpty)
              const Text('No reviews yet. Be the first to review.')
            else
              ...vm.reviews.map(
                (review) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(review.rating.toString())),
                    title: Text(review.comment),
                    subtitle: Text('Posted on ${review.createdAt.split('T').first}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
