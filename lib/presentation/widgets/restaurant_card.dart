import 'package:flutter/material.dart';

import '../../data/models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;
  final String? imageOverride;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.imageOverride,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackImage = restaurant.photos.isNotEmpty ? restaurant.photos.first : '';
    final selectedImage = (imageOverride != null && imageOverride!.trim().isNotEmpty)
        ? imageOverride!.trim()
        : fallbackImage.trim();
    final isAssetImage = selectedImage.startsWith('assets/');
    final cardWidth = MediaQuery.of(context).size.width;
    final imageHeight = (cardWidth * 0.5).clamp(170.0, 240.0).toDouble();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: selectedImage.isEmpty
                    ? Container(
                        height: imageHeight,
                        width: double.infinity,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.restaurant, size: 40),
                      )
                    : (isAssetImage
                        ? Image.asset(
                            selectedImage,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            selectedImage,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                height: imageHeight,
                                width: double.infinity,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const Icon(Icons.restaurant, size: 40),
                            ),
                          )),
              ),
              const SizedBox(height: 10),
              Text(
                restaurant.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                restaurant.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${restaurant.ratingAvg} (${restaurant.ratingCount})'),
                  const SizedBox(width: 10),
                  Text(restaurant.priceRange),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Specialty: ${restaurant.specialties.join(', ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
